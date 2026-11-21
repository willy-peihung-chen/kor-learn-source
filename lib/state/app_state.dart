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

  // ---- 單字複習的額度（全 App 共用；單字頁與主題頁都從這裡算） ----

  /// 每天的新單字數（第一次評分的那天算一個）。
  static const int newWordsPerDay = 10;

  /// 按「今天再多學」一次增加的新單字數。
  static const int extraNewWordsStep = 10;

  /// 每一輪最多出的到期卡張數（不設每天上限，做完一輪可以再來一輪）。
  static const int dueCardsPerRound = 20;

  /// 到期卡超過這個數字時，暫停加新單字，先把積壓的複習做完。
  static const int backlogPauseThreshold = 100;

  /// 答「不熟悉」累計達到這個次數，標成「難記的字」。
  static const int hardWordLapses = 4;

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

  /// 新單字依學習順序排好、還沒評過的 id（全部或單一主題）。
  /// 一輪實際出幾個由 [newWordsAvailable] 決定，這裡不限數量。
  List<String> newWordIdsInOrder({String? topicId}) =>
      ReviewQueue.newIds(itemIds: _studyIdsOf(topicId), states: _data.reviews);

  /// 組一輪複習：到期卡（最早到期的先，最多 [dueCardsPerRound] 張），
  /// 再補今天還能學的新單字（[newWordsAvailable]）。
  List<String> buildReviewQueue({String? topicId}) => ReviewQueue.build(
        itemIds: _studyIdsOf(topicId),
        states: _data.reviews,
        now: now,
        newLimit: newWordsAvailable,
        dueLimit: dueCardsPerRound,
      );

  /// 今天第一次評分的單字數（同一個字重做不重複算；跨過午夜重新計算）。
  int get newWordsLearnedToday {
    final today = now;
    return _data.reviews.values
        .where((r) =>
            r.firstReviewedAt != null && isSameDay(r.firstReviewedAt!, today))
        .length;
  }

  /// 今天按「今天再多學」加上的額度。
  int get extraNewWordsToday =>
      _data.extraNewWordsDate == dayKey(now) ? _data.extraNewWords : 0;

  /// 今天的新單字總額度（每天固定額度＋今天加的）。
  int get newWordsQuotaToday => newWordsPerDay + extraNewWordsToday;

  /// 今天的新單字額度還剩幾個（不管有沒有暫停）。
  int get newWordsLeftToday {
    final left = newWordsQuotaToday - newWordsLearnedToday;
    return left < 0 ? 0 : left;
  }

  /// 到期卡積壓太多，暫停新單字。
  bool get newWordsPaused => dueCount > backlogPauseThreshold;

  /// 現在一輪可以加入的新單字數（額度用完或暫停時為 0）。
  int get newWordsAvailable => newWordsPaused ? 0 : newWordsLeftToday;

  /// 可以按「今天再多學」：額度用完、沒有暫停、而且還有沒學過的字。
  bool get canAddExtraNewWords => canAddExtraNewWordsOf(null);

  /// 同上，但只看指定主題（null 代表全部）還有沒有沒學過的字。
  bool canAddExtraNewWordsOf(String? topicId) =>
      !newWordsPaused &&
      newWordsLeftToday == 0 &&
      newWordIdsInOrder(topicId: topicId).isNotEmpty;

  /// 今天的新單字額度再加 [extraNewWordsStep] 個。
  void addExtraNewWordsToday() {
    final key = dayKey(now);
    _data.extraNewWords =
        (_data.extraNewWordsDate == key ? _data.extraNewWords : 0) +
            extraNewWordsStep;
    _data.extraNewWordsDate = key;
    _commit();
  }

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

  /// 答「不熟悉」累計 [hardWordLapses] 次以上的字。
  bool isHardWord(String wordId) =>
      (_data.reviews[wordId]?.lapses ?? 0) >= hardWordLapses;

  /// 某個字答「不熟悉」的累計次數（2 小時內重複答錯只算一次，見 [Srs.recentWindow]）。
  int lapsesOf(String wordId) => _data.reviews[wordId]?.lapses ?? 0;

  /// 難記的字：依答錯次數由多到少，同次數照教材順序。
  List<String> get hardWordIds {
    final ids = _wordIds.where(isHardWord).toList();
    final order = <String, int>{
      for (var i = 0; i < ids.length; i++) ids[i]: i,
    };
    ids.sort((a, b) {
      final byLapses = lapsesOf(b).compareTo(lapsesOf(a));
      return byLapses != 0 ? byLapses : order[a]!.compareTo(order[b]!);
    });
    return ids;
  }

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
    final previous = _data.reviews[wordId];
    _data.reviews[wordId] = Srs.review(
      previous: previous,
      itemId: wordId,
      rating: rating,
      now: current,
    );

    // 今天已經評過這個字（例如答錯後重做）：不再多算一張。
    final countedToday =
        previous != null && isSameDay(previous.lastReviewedAt, current);

    // 同一天連續的複習合併成一筆紀錄。
    final last = _data.activity.isEmpty ? null : _data.activity.last;
    if (last != null && last.type == 'review' && isSameDay(last.at, current)) {
      _data.activity[_data.activity.length - 1] = ActivityEntry(
        type: 'review',
        label: last.label,
        at: current,
        count: countedToday ? last.count : last.count + 1,
      );
    } else if (!countedToday) {
      // 中間做過別的事（例如測驗）時，今天已經算過的這張不另開一筆。
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
