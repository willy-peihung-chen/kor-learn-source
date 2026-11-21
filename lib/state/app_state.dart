import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../data/lessons.dart';
import '../data/quiz_types.dart';
import '../data/word_levels.dart';
import '../logic/progress_stats.dart';
import '../logic/quiz_generator.dart';
import '../logic/srs.dart';
import '../storage/progress_data.dart';
import '../storage/progress_repository.dart';
import '../util/format.dart';

/// App 的唯一狀態來源：把學習紀錄、排程邏輯與儲存接在一起。
/// UI 只讀取這裡的資料並呼叫這裡的方法。
class AppState extends ChangeNotifier {
  AppState({
    required ProgressRepository repository,
    ProgressData? data,
    DateTime Function()? clock,
    QuizGenerator? quizGenerator,
  })  : _repository = repository,
        _data = data ?? ProgressData(),
        _clock = clock ?? DateTime.now,
        quiz = quizGenerator ??
            QuizGenerator(wordPoolFor: Lessons.unitWordPoolFor);

  /// 從儲存讀回紀錄後建立狀態（App 重新啟動時走這條路）。
  static Future<AppState> load(
    ProgressRepository repository, {
    DateTime Function()? clock,
    QuizGenerator? quizGenerator,
  }) async {
    final data = await repository.load();
    return AppState(
      repository: repository,
      data: data,
      clock: clock,
      quizGenerator: quizGenerator,
    );
  }

  final ProgressRepository _repository;
  final ProgressData _data;
  final DateTime Function() _clock;
  final QuizGenerator quiz;

  /// 每一輪單字複習最多加入的新單字數。
  static const int newWordsPerRound = 10;

  Future<void> _saveChain = Future<void>.value();

  DateTime get now => _clock();

  /// 等待目前所有儲存動作完成（測試與關閉前使用）。
  Future<void> flush() => _saveChain;

  // ---- 課程 ----

  bool isLessonCompleted(String lessonId) =>
      _data.completedLessons.contains(lessonId);

  int get completedLessonCount =>
      Lessons.all.where((l) => isLessonCompleted(l.id)).length;

  /// 第一個尚未完成的課程；全部完成時為 null。
  Lesson? get nextLesson {
    for (final lesson in Lessons.all) {
      if (!isLessonCompleted(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }

  int learnedCardCount(Lesson lesson) =>
      lesson.cards.where((c) => _data.learnedItems.contains(c.id)).length;

  void markLearned(String itemId) {
    if (_data.learnedItems.add(itemId)) {
      _commit();
    }
  }

  void completeLesson(Lesson lesson) {
    _data.learnedItems.addAll(lesson.cards.map((c) => c.id));
    _data.completedLessons.add(lesson.id);
    _data.activity.add(
      ActivityEntry(type: 'lesson_completed', label: lesson.title, at: now),
    );
    _commit();
  }

  // ---- 單字複習 ----

  List<String> get _wordIds => Catalog.words.map((w) => w.id).toList();

  /// 指定主題（null 代表全部主題）的單字 id，順序依教材排列。
  List<String> _wordIdsOf(String? topicId) {
    if (topicId == null) {
      return _wordIds;
    }
    final topic = Catalog.topicById(topicId);
    return topic == null
        ? <String>[]
        : topic.words.map((w) => w.id).toList();
  }

  /// 全部主題學新字的順序（片語主題先，其餘依等級）；只算一次。
  late final List<String> _globalStudyIds =
      globalStudyOrder(Catalog.topics).map((w) => w.id).toList();

  /// 複習時新單字的出現順序：全部時依 [globalStudyOrder]，
  /// 單一主題時和主題頁畫面的順序相同（[studyOrderOf]）。
  List<String> _studyIdsOf(String? topicId) {
    if (topicId == null) {
      return _globalStudyIds;
    }
    final topic = Catalog.topicById(topicId);
    return topic == null
        ? <String>[]
        : studyOrderOf(topic).map((w) => w.id).toList();
  }

  List<String> buildReviewQueue({
    int newLimit = newWordsPerRound,
    String? topicId,
  }) =>
      ReviewQueue.build(
        itemIds: _studyIdsOf(topicId),
        states: _data.reviews,
        now: now,
        newLimit: newLimit,
      );

  int get dueCount => dueCountOf(null);

  /// 指定主題（null 代表全部）到期的單字卡數。
  int dueCountOf(String? topicId) => ReviewQueue.dueIds(
        itemIds: _wordIdsOf(topicId),
        states: _data.reviews,
        now: now,
      ).length;

  int get newWordCount =>
      ReviewQueue.newIds(itemIds: _wordIds, states: _data.reviews).length;

  bool isNewWord(String wordId) => !_data.reviews.containsKey(wordId);

  /// 已經評估過（複習過）的單字 id。
  List<String> get learnedWordIds =>
      _wordIds.where((id) => _data.reviews.containsKey(id)).toList();

  int get learnedWordCount => learnedWordIds.length;

  /// 某主題已評估過的單字數與總數。
  ({int learned, int total}) topicProgress(String topicId) {
    final ids = _wordIdsOf(topicId);
    final learned = ids.where((id) => _data.reviews.containsKey(id)).length;
    return (learned: learned, total: ids.length);
  }

  /// 已學過（看過說明卡）的文法點所包含的例句 id，混合測驗用。
  List<String> get learnedGrammarExampleIds => <String>[
        for (final point in Catalog.grammarPoints)
          if (_data.learnedItems.contains(point.cardId))
            for (var i = 0; i < point.examples.length; i++) point.exampleId(i),
      ];

  /// 尚未到期的卡片中，最早的下次複習時間；沒有時為 null。
  DateTime? get nextDueAt => nextDueAtOf(null);

  /// 指定主題（null 代表全部）尚未到期的卡片中，最早的下次複習時間。
  DateTime? nextDueAtOf(String? topicId) {
    final current = now;
    DateTime? earliest;
    for (final id in _wordIdsOf(topicId)) {
      final state = _data.reviews[id];
      if (state == null || state.isDue(current)) {
        continue;
      }
      if (earliest == null || state.dueAt.isBefore(earliest)) {
        earliest = state.dueAt;
      }
    }
    return earliest;
  }

  void rateWord(String wordId, ReviewRating rating) {
    final current = now;
    _data.reviews[wordId] = Srs.review(
      previous: _data.reviews[wordId],
      itemId: wordId,
      rating: rating,
      now: current,
    );

    // 同一天連續的複習合併成一筆紀錄。
    final last = _data.activity.isEmpty ? null : _data.activity.last;
    if (last != null && last.type == 'review' && isSameDay(last.at, current)) {
      _data.activity[_data.activity.length - 1] = ActivityEntry(
        type: 'review',
        label: last.label,
        at: current,
        count: last.count + 1,
      );
    } else {
      _data.activity.add(
        ActivityEntry(type: 'review', label: '單字複習', at: current),
      );
    }
    _commit();
  }

  // ---- 測驗 ----

  /// 記錄一題作答結果，回傳是否答對。
  bool recordAnswer(QuizQuestion question, int selected) {
    final correct = question.isCorrect(selected);
    _data.attempts.add(
      QuizAttempt(
        kind: question.kind,
        itemId: question.itemId,
        correct: correct,
        at: now,
      ),
    );
    _commit();
    return correct;
  }

  void finishQuiz(String title, int correct, int total) {
    _data.activity.add(
      ActivityEntry(type: 'quiz', label: '$title：$correct / $total', at: now),
    );
    _commit();
  }

  List<QuizSeed> get mistakeSeeds => ProgressStats.mistakeSeeds(_data.attempts);

  // ---- 統計（全部由實際紀錄計算） ----

  /// 已學習項目數：課程中看過的卡片 + 已評估過的單字卡。
  int get learnedCount => _data.learnedItems.length + _data.reviews.length;

  double? get recentAccuracy => ProgressStats.recentAccuracy(_data.attempts);

  int get recentAttemptCount =>
      _data.attempts.length > 20 ? 20 : _data.attempts.length;

  List<WeakItem> get weakItems => ProgressStats.weakItems(_data.attempts);

  List<ActivityEntry> recentActivity({int limit = 5}) {
    final reversed = _data.activity.reversed.take(limit);
    return reversed.toList();
  }

  bool didToday(String activityType) {
    final today = now;
    return _data.activity
        .any((a) => a.type == activityType && isSameDay(a.at, today));
  }

  // ---- 內部 ----

  void _commit() {
    _data.trim();
    notifyListeners();
    _saveChain = _saveChain
        .then((_) => _repository.save(_data))
        .catchError((Object error) {
      debugPrint('儲存學習紀錄失敗：$error');
    });
  }
}
