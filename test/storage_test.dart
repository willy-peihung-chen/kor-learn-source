import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/lessons.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/data/word_levels.dart';
import 'package:hangul_app/logic/quiz_generator.dart';
import 'package:hangul_app/logic/srs.dart';
import 'package:hangul_app/state/app_state.dart';
import 'package:hangul_app/storage/progress_data.dart';
import 'package:hangul_app/storage/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 29, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<SharedPrefsProgressRepository> newRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsProgressRepository(prefs);
  }

  group('ProgressData JSON', () {
    test('空白資料往返後仍是空白', () {
      final back = ProgressData.fromJson(ProgressData().toJson());
      expect(back.completedLessons, isEmpty);
      expect(back.learnedItems, isEmpty);
      expect(back.reviews, isEmpty);
      expect(back.attempts, isEmpty);
      expect(back.activity, isEmpty);
    });

    test('各欄位往返後內容相同', () {
      final data = ProgressData(
        completedLessons: <String>{'hangul-1'},
        learnedItems: <String>{'letter:ㅏ', 'letter:ㅓ'},
        reviews: <String, ReviewState>{
          'word:아이': Srs.review(
            itemId: 'word:아이',
            rating: ReviewRating.normal,
            now: now,
          ),
        },
        attempts: <QuizAttempt>[
          QuizAttempt(
            kind: QuizKind.letterName,
            itemId: 'letter:ㄱ',
            correct: false,
            at: now,
          ),
        ],
        activity: <ActivityEntry>[
          ActivityEntry(type: 'review', label: '單字複習', at: now, count: 3),
        ],
      );

      final back = ProgressData.fromJson(data.toJson());
      expect(back.completedLessons, <String>{'hangul-1'});
      expect(back.learnedItems, <String>{'letter:ㅏ', 'letter:ㅓ'});
      expect(back.reviews['word:아이']!.intervalDays, 1);
      expect(back.attempts.single.kind, QuizKind.letterName);
      expect(back.attempts.single.correct, isFalse);
      expect(back.activity.single.count, 3);
    });

    test('壞掉或未知的項目會被略過，其他資料照常讀取', () {
      final back = ProgressData.fromJson(<String, dynamic>{
        'completedLessons': <dynamic>['hangul-1', 42],
        'attempts': <dynamic>[
          <String, dynamic>{
            'kind': 'noSuchKind',
            'itemId': 'x',
            'correct': true,
            'at': now.toIso8601String(),
          },
          'not a map',
        ],
        'reviews': <dynamic>[
          <String, dynamic>{'itemId': 'word:아이'},
        ],
      });
      expect(back.completedLessons, <String>{'hangul-1'});
      expect(back.attempts, isEmpty);
      expect(back.reviews, isEmpty);
    });

    test('trim 只保留最近的紀錄', () {
      final data = ProgressData(
        attempts: <QuizAttempt>[
          for (var i = 0; i < ProgressData.maxAttempts + 50; i++)
            QuizAttempt(
              kind: QuizKind.letterName,
              itemId: 'letter:$i',
              correct: true,
              at: now,
            ),
        ],
      )..trim();
      expect(data.attempts.length, ProgressData.maxAttempts);
      expect(data.attempts.first.itemId, 'letter:50');
    });
  });

  group('SharedPrefsProgressRepository', () {
    test('沒有資料時回傳空白紀錄', () async {
      final repo = await newRepository();
      final data = await repo.load();
      expect(data.completedLessons, isEmpty);
    });

    test('存檔後可以讀回', () async {
      final repo = await newRepository();
      await repo.save(ProgressData(completedLessons: <String>{'hangul-2'}));
      final data = await repo.load();
      expect(data.completedLessons, <String>{'hangul-2'});
    });

    test('內容損壞時回傳空白紀錄，並保留原始內容作備份', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsProgressRepository.storageKey: '{這不是 JSON',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsProgressRepository(prefs);
      final data = await repo.load();
      expect(data.completedLessons, isEmpty);
      expect(
        prefs.getString(SharedPrefsProgressRepository.corruptBackupKey),
        '{這不是 JSON',
      );
    });
  });

  group('重新啟動後學習紀錄仍存在', () {
    test('課程、複習、測驗紀錄都能在新的 AppState 讀回', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);

      // 學習一課
      final lesson = Lessons.all.first;
      for (final card in lesson.cards) {
        state.markLearned(card.id);
      }
      state.completeLesson(lesson);

      // 複習兩個單字
      state.rateWord(Catalog.words[0].id, ReviewRating.familiar);
      state.rateWord(Catalog.words[1].id, ReviewRating.unfamiliar);

      // 答一題錯的
      final generator = QuizGenerator();
      final question = generator.build(
        QuizSeed(QuizKind.letterName, Catalog.letters.first.id),
      )!;
      final wrongIndex = (question.correctIndex + 1) % question.options.length;
      expect(state.recordAnswer(question, wrongIndex), isFalse);

      await state.flush();

      // 模擬重新啟動：用同一份儲存建立全新的 AppState。
      final restarted = await AppState.load(
        await newRepository(),
        clock: () => now,
      );

      expect(restarted.isLessonCompleted(lesson.id), isTrue);
      expect(restarted.completedLessonCount, 1);
      expect(restarted.learnedCardCount(lesson), lesson.cards.length);
      expect(restarted.learnedCount, state.learnedCount);
      expect(restarted.isNewWord(Catalog.words[0].id), isFalse);
      expect(restarted.isNewWord(Catalog.words[2].id), isTrue);
      expect(restarted.mistakeSeeds.length, 1);
      expect(restarted.mistakeSeeds.single.itemId, Catalog.letters.first.id);
      expect(restarted.recentAccuracy, 0.0);
      expect(restarted.weakItems.single.itemId, Catalog.letters.first.id);
    });

    test('同一天連續的單字複習合併成一筆最近紀錄', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      state.rateWord(Catalog.words[0].id, ReviewRating.normal);
      state.rateWord(Catalog.words[1].id, ReviewRating.normal);
      state.rateWord(Catalog.words[2].id, ReviewRating.normal);
      final recent = state.recentActivity();
      expect(recent.length, 1);
      expect(recent.single.type, 'review');
      expect(recent.single.count, 3);
      await state.flush();
    });

    test('評「普通」之後，該單字不會馬上又出現在複習佇列', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      final id = state.buildReviewQueue().first;
      state.rateWord(id, ReviewRating.normal);
      expect(state.buildReviewQueue(), isNot(contains(id)));
      expect(state.dueCount, 0);
      await state.flush();
    });

    test('新單字的順序：全部時問候語先、其餘依等級；主題時和主題頁相同', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);

      final all = state.buildReviewQueue(newLimit: 2000);
      final expected = globalStudyOrder(Catalog.topics).map((w) => w.id);
      expect(all, expected.toList());
      expect(all.length, Catalog.words.length);
      // 問候語主題排最前面，接著第一個非問候語的字是 1 級。
      final greetings = Catalog.topicById('greetings')!;
      expect(all.take(greetings.words.length),
          greetings.words.map((w) => w.id));
      expect(wordLevelOf(Catalog.wordById(all[greetings.words.length])!),
          WordLevel.level1);

      final topic = Catalog.topics.firstWhere((t) => t.id == 'verbs_move');
      final topicQueue = state.buildReviewQueue(topicId: topic.id, newLimit: 200);
      expect(topicQueue, studyOrderOf(topic).map((w) => w.id).toList());
      await state.flush();
    });

    test('主題複習的「下一張到期時間」只看這個主題', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      final topicA = Catalog.topics[1];
      final topicB = Catalog.topics[2];
      // A 主題的字答錯：10 分鐘後到期；B 主題的字評普通：1 天後到期。
      state.rateWord(topicA.words.first.id, ReviewRating.unfamiliar);
      state.rateWord(topicB.words.first.id, ReviewRating.normal);
      expect(state.nextDueAt, now.add(Srs.relearnDelay));
      expect(state.nextDueAtOf(topicB.id), now.add(const Duration(days: 1)));
      expect(state.nextDueAtOf(topicA.id), now.add(Srs.relearnDelay));
      await state.flush();
    });
  });
}
