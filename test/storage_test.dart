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

    test('新單字的順序：全部時依等級（基本用語先）；主題時和主題頁相同', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);

      final all = state.newWordIdsInOrder();
      final expected = globalStudyOrder(Catalog.topics).map((w) => w.id);
      expect(all, expected.toList());
      expect(all.length, Catalog.words.length);
      // 「基本用語」排最前面，接著是 1 級。
      final firstLevels = all.map((id) => wordLevelOf(Catalog.wordById(id)!));
      expect(firstLevels.first, WordLevel.essential);
      var rank = 0;
      for (final level in firstLevels) {
        expect(level.index, greaterThanOrEqualTo(rank));
        rank = level.index;
      }
      // 「較少用」的字排在最後。
      expect(wordLevelOf(Catalog.wordById(all.last)!), WordLevel.later);

      final topic = Catalog.topics.firstWhere((t) => t.id == 'verbs_move');
      final topicQueue = state.newWordIdsInOrder(topicId: topic.id);
      expect(topicQueue, studyOrderOf(topic).map((w) => w.id).toList());
      await state.flush();
    });

    test('一輪的新單字是學習順序的前 10 個', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      expect(state.buildReviewQueue(),
          state.newWordIdsInOrder().take(AppState.newWordsPerDay).toList());
      await state.flush();
    });

    test('主題複習的「下一張到期時間」只看這個主題', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      final topicA = Catalog.topicById('numbers')!;
      final topicB = Catalog.topicById('time_day')!;
      // A 主題的字答錯：10 分鐘後到期；B 主題的字評普通：1 天後到期。
      state.rateWord(topicA.words.first.id, ReviewRating.unfamiliar);
      state.rateWord(topicB.words.first.id, ReviewRating.normal);
      expect(state.nextDueAt, now.add(Srs.relearnDelay));
      // 間隔 1 天的卡，明天 0 點起就可以複習。
      expect(state.nextDueAtOf(topicB.id), DateTime(2026, 10, 30));
      expect(state.nextDueAtOf(topicA.id), now.add(Srs.relearnDelay));
      await state.flush();
    });
  });

  group('每日額度（全 App 共用）', () {
    ReviewState dueState(String id, {DateTime? first}) => ReviewState(
          itemId: id,
          repetitions: 1,
          intervalDays: 1,
          ease: 2.3,
          lapses: 0,
          dueAt: now.subtract(const Duration(hours: 1)),
          lastReviewedAt: now.subtract(const Duration(days: 1)),
          firstReviewedAt: first,
        );

    test('主題複習和全部複習扣同一份新單字額度', () async {
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => now);
      final numbers = Catalog.topicById('numbers')!;
      final timeDay = Catalog.topicById('time_day')!;

      final topicQueue = state.buildReviewQueue(topicId: numbers.id);
      expect(topicQueue.length, AppState.newWordsPerDay);
      for (final id in topicQueue.take(4)) {
        state.rateWord(id, ReviewRating.normal);
      }
      expect(state.newWordsLearnedToday, 4);
      expect(state.newWordsLeftToday, AppState.newWordsPerDay - 4);

      final global = state.buildReviewQueue();
      expect(global.length, AppState.newWordsPerDay - 4);
      for (final id in global) {
        state.rateWord(id, ReviewRating.normal);
      }
      expect(state.newWordsLeftToday, 0);
      expect(state.buildReviewQueue(topicId: timeDay.id), isEmpty);
      expect(state.buildReviewQueue(), isEmpty);
      await state.flush();
    });

    test('額度用完後只出到期卡；答錯重做不重複計數', () async {
      var clock = now;
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => clock);
      final ids = state.buildReviewQueue();
      for (final id in ids) {
        state.rateWord(id, ReviewRating.unfamiliar);
      }
      expect(state.newWordsLearnedToday, AppState.newWordsPerDay);

      clock = now.add(const Duration(minutes: 11));
      final again = state.buildReviewQueue();
      expect(again.toSet(), ids.toSet()); // 只有到期卡，沒有新字
      for (final id in again) {
        state.rateWord(id, ReviewRating.normal);
      }
      expect(state.newWordsLearnedToday, AppState.newWordsPerDay);
      expect(state.buildReviewQueue(), isEmpty);
      await state.flush();
    });

    test('到期卡每輪最多 20 張，做完一輪可以再來一輪', () async {
      final ids = Catalog.words.take(45).map((w) => w.id).toList();
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(reviews: {for (final id in ids) id: dueState(id)}),
        clock: () => now,
      );
      final first = state.buildReviewQueue();
      final dueInFirst =
          first.where((id) => !state.isNewWord(id)).toList();
      expect(dueInFirst.length, AppState.dueCardsPerRound);
      for (final id in dueInFirst) {
        state.rateWord(id, ReviewRating.normal);
      }
      expect(state.dueCount, 45 - AppState.dueCardsPerRound);
      expect(
        state.buildReviewQueue().where((id) => !state.isNewWord(id)).length,
        AppState.dueCardsPerRound,
      );
      await state.flush();
    });

    test('到期超過 100 張時暫停新單字，降到 100 張以下就恢復', () async {
      final ids = Catalog.words.take(101).map((w) => w.id).toList();
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(reviews: {for (final id in ids) id: dueState(id)}),
        clock: () => now,
      );
      expect(state.dueCount, 101);
      expect(state.newWordsPaused, isTrue);
      expect(state.newWordsAvailable, 0);
      expect(state.canAddExtraNewWords, isFalse);
      final queue = state.buildReviewQueue();
      expect(queue.length, AppState.dueCardsPerRound);
      expect(queue.every((id) => !state.isNewWord(id)), isTrue);
      // 主題複習也一樣暫停新字。
      final topic = Catalog.topicById('numbers')!;
      expect(
        state.buildReviewQueue(topicId: topic.id)
            .every((id) => !state.isNewWord(id)),
        isTrue,
      );

      state.rateWord(queue.first, ReviewRating.normal); // 剩 100 張
      expect(state.newWordsPaused, isFalse);
      expect(state.newWordsAvailable, AppState.newWordsPerDay);
      await state.flush();
    });

    test('跨過午夜：新單字額度和「再多學」都重新計算', () async {
      var clock = DateTime(2026, 10, 29, 23, 50);
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => clock);
      for (final id in state.buildReviewQueue()) {
        state.rateWord(id, ReviewRating.normal);
      }
      expect(state.newWordsLeftToday, 0);
      expect(state.canAddExtraNewWords, isTrue);
      state.addExtraNewWordsToday();
      expect(state.newWordsQuotaToday,
          AppState.newWordsPerDay + AppState.extraNewWordsStep);
      expect(state.newWordsLeftToday, AppState.extraNewWordsStep);

      clock = DateTime(2026, 10, 30, 0, 5);
      expect(state.newWordsLearnedToday, 0);
      expect(state.extraNewWordsToday, 0);
      expect(state.newWordsLeftToday, AppState.newWordsPerDay);
      await state.flush();
    });

    test('「今天再多學」的額度重新啟動後還在，第二天就失效', () async {
      var clock = now;
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => clock);
      for (final id in state.buildReviewQueue()) {
        state.rateWord(id, ReviewRating.normal);
      }
      state.addExtraNewWordsToday();
      state.addExtraNewWordsToday();
      expect(state.newWordsLeftToday, AppState.extraNewWordsStep * 2);
      await state.flush();

      final restarted =
          await AppState.load(await newRepository(), clock: () => clock);
      expect(restarted.newWordsLeftToday, AppState.extraNewWordsStep * 2);
      expect(restarted.buildReviewQueue().length,
          AppState.extraNewWordsStep * 2);

      clock = now.add(const Duration(days: 1));
      expect(restarted.extraNewWordsToday, 0);
      expect(restarted.newWordsQuotaToday, AppState.newWordsPerDay);
    });

    test('讀舊紀錄（沒有 firstReviewedAt 與額度欄位）：今天的新字從 0 算', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsProgressRepository.storageKey: '{"version":1,"reviews":['
            '{"itemId":"${Catalog.words.first.id}","repetitions":1,'
            '"intervalDays":1,"ease":2.3,"lapses":0,'
            '"dueAt":"${now.add(const Duration(days: 1)).toUtc().toIso8601String()}",'
            '"lastReviewedAt":"${now.toUtc().toIso8601String()}"}]}',
      });
      final state = await AppState.load(await newRepository(), clock: () => now);
      expect(state.learnedWordCount, 1);
      expect(state.newWordsLearnedToday, 0);
      expect(state.extraNewWordsToday, 0);
      expect(state.newWordsLeftToday, AppState.newWordsPerDay);
      expect(state.buildReviewQueue().length, AppState.newWordsPerDay);
      expect(state.buildReviewQueue(), isNot(contains(Catalog.words.first.id)));
    });

    test('額度欄位壞掉時當作沒有加額度', () {
      final data = ProgressData.fromJson(<String, dynamic>{
        'extraNewWordsDate': 20261029,
        'extraNewWords': 'ten',
      });
      expect(data.extraNewWordsDate, isNull);
      expect(data.extraNewWords, 0);
    });

    test('最近紀錄的「複習 n 張」不把重做算進去', () async {
      var clock = now;
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => clock);
      final a = Catalog.words[0].id;
      final b = Catalog.words[1].id;
      state.rateWord(a, ReviewRating.unfamiliar);
      state.rateWord(b, ReviewRating.normal);
      clock = now.add(const Duration(minutes: 11));
      state.rateWord(a, ReviewRating.normal); // 重做
      expect(state.recentActivity().single.count, 2);

      // 中間做了測驗，再重做今天評過的字：不另開一筆複習紀錄。
      state.finishQuiz('混合測驗', 8, 10);
      clock = now.add(const Duration(minutes: 30));
      state.rateWord(a, ReviewRating.familiar);
      final recent = state.recentActivity();
      expect(recent.length, 2);
      expect(recent.first.type, 'quiz');
      expect(recent.last.count, 2);
      await state.flush();
    });
  });

  group('難記的字', () {
    test('答「不熟悉」累計 4 次（各隔開一段時間）才算難記；同一輪重做不累計', () async {
      var clock = now;
      final repo = await newRepository();
      final state = await AppState.load(repo, clock: () => clock);
      final id = Catalog.words[3].id;
      final other = Catalog.words[4].id;

      for (var i = 0; i < 3; i++) {
        clock = now.add(Duration(hours: 3 * i));
        state.rateWord(id, ReviewRating.unfamiliar);
        // 同一輪重做又答錯：不累計。
        clock = clock.add(const Duration(minutes: 11));
        state.rateWord(id, ReviewRating.unfamiliar);
      }
      expect(state.lapsesOf(id), 3);
      expect(state.isHardWord(id), isFalse);
      expect(state.hardWordIds, isEmpty);

      clock = now.add(const Duration(hours: 12));
      state.rateWord(id, ReviewRating.unfamiliar);
      expect(state.lapsesOf(id), AppState.hardWordLapses);
      expect(state.isHardWord(id), isTrue);
      expect(state.isHardWord(other), isFalse);
      expect(state.hardWordIds, <String>[id]);

      // 答對之後仍然算難記（失誤次數不會減少）。
      state.rateWord(id, ReviewRating.familiar);
      expect(state.isHardWord(id), isTrue);
      await state.flush();
    });

    test('難記的字依答錯次數由多到少排列', () {
      ReviewState withLapses(String id, int lapses) => ReviewState(
            itemId: id,
            repetitions: 1,
            intervalDays: 1,
            ease: 1.3,
            lapses: lapses,
            dueAt: now.add(const Duration(days: 1)),
            lastReviewedAt: now,
          );
      final w = Catalog.words;
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(reviews: <String, ReviewState>{
          w[0].id: withLapses(w[0].id, 4),
          w[1].id: withLapses(w[1].id, 6),
          w[2].id: withLapses(w[2].id, 3),
          w[3].id: withLapses(w[3].id, 4),
        }),
        clock: () => now,
      );
      expect(state.hardWordIds, <String>[w[1].id, w[0].id, w[3].id]);
    });
  });

  group('中文→韓文卡', () {
    ReviewState fwd(
      String id, {
      int interval = TwoWayQueue.unlockIntervalDays,
      Duration dueIn = const Duration(days: 2),
      int lapses = 0,
    }) =>
        ReviewState(
          itemId: id,
          repetitions: 2,
          intervalDays: interval,
          ease: 2.3,
          lapses: lapses,
          dueAt: now.add(dueIn),
          lastReviewedAt: now.subtract(const Duration(days: 1)),
          firstReviewedAt: now.subtract(const Duration(days: 5)),
        );

    test('紀錄往返後還在；沒有中文→韓文紀錄時不寫這一項；舊紀錄讀成空的', () {
      final id = Catalog.words.first.id;
      final data = ProgressData(
        reverseReviews: <String, ReviewState>{
          id: Srs.review(itemId: id, rating: ReviewRating.normal, now: now),
        },
      );
      final back = ProgressData.fromJson(data.toJson());
      expect(back.reverseReviews[id]!.intervalDays, 1);
      expect(back.reviews, isEmpty);
      expect(ProgressData().toJson().containsKey('reverseReviews'), isFalse);
      expect(
        ProgressData.fromJson(<String, dynamic>{'version': 1, 'reviews': <dynamic>[]})
            .reverseReviews,
        isEmpty,
      );
    });

    test('間隔達到門檻的字開啟中文→韓文卡；評過後當天不再出現，也不算新單字', () async {
      final w = Catalog.words.first.id;
      final repo = await newRepository();
      final state = AppState(
        repository: repo,
        data: ProgressData(reviews: <String, ReviewState>{w: fwd(w)}),
        clock: () => now,
      );
      final rev = CardId.reverse(w);
      final queue = state.buildReviewQueue();
      expect(queue.first, rev);
      expect(state.isNewCard(rev), isTrue);
      expect(state.isNewWord(w), isFalse);
      expect(state.dueCount, 0);

      state.rateCard(rev, ReviewRating.normal);
      expect(state.isNewCard(rev), isFalse);
      expect(state.reverseLearnedWordCount, 1);
      expect(state.newReverseLearnedToday, 1);
      expect(state.newWordsLearnedToday, 0);
      expect(state.learnedWordCount, 1);
      expect(state.buildReviewQueue(), isNot(contains(rev)));
      await state.flush();

      // 重新啟動後中文→韓文紀錄還在。
      final restarted = await AppState.load(await newRepository(), clock: () => now);
      expect(restarted.isNewCard(rev), isFalse);
      expect(restarted.reverseLearnedWordCount, 1);
    });

    test('今天練過中文→韓文，韓文→中文當天到期也留到明天', () async {
      var clock = now;
      final w = Catalog.words.first.id;
      final rev = CardId.reverse(w);
      // 韓文→中文今天到期（間隔 1 天以上，今天 0 點起就算到期）；
      // 中文→韓文今天已經練過。
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(
          reviews: <String, ReviewState>{
            // 今天晚上 8 點才到期：新的算法下今天就算到期。
            w: fwd(w, dueIn: const Duration(hours: 8)),
          },
          reverseReviews: <String, ReviewState>{
            w: ReviewState(
              itemId: w,
              repetitions: 1,
              intervalDays: 3,
              ease: 2.3,
              lapses: 0,
              dueAt: now.add(const Duration(days: 3)),
              lastReviewedAt: now.subtract(const Duration(hours: 1)),
              firstReviewedAt: now.subtract(const Duration(hours: 1)),
            ),
          },
        ),
        clock: () => clock,
      );
      expect(state.dueCount, 0);
      expect(state.buildReviewQueue(), isNot(contains(w)));
      expect(state.buildReviewQueue(), isNot(contains(rev)));
      expect(state.nextDueAt, DateTime(2026, 10, 30));

      clock = DateTime(2026, 10, 30, 8);
      expect(state.dueCount, 1);
      expect(state.buildReviewQueue().first, w);
      await state.flush();
    });

    test('中文→韓文新卡每天最多 ${AppState.newReverseCardsPerDay} 張，和新單字分開算', () async {
      final ids = Catalog.words.take(15).map((w) => w.id).toList();
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(reviews: {for (final id in ids) id: fwd(id)}),
        clock: () => now,
      );
      final queue = state.buildReviewQueue();
      final revs = queue.where(CardId.isReverse).toList();
      expect(revs.length, AppState.newReverseCardsPerDay);
      expect(queue.length - revs.length, AppState.newWordsPerDay);
      for (final id in revs) {
        state.rateCard(id, ReviewRating.normal);
      }
      expect(state.newReverseLeftToday, 0);
      expect(state.newWordsLeftToday, AppState.newWordsPerDay);
      expect(state.buildReviewQueue().where(CardId.isReverse), isEmpty);
      expect(state.unlockableReverseCardIds().length, 15 - AppState.newReverseCardsPerDay);
      await state.flush();
    });

    test('到期卡超過 100 張時，中文→韓文新卡也暫停', () {
      expect(Catalog.words.length, greaterThan(101));
      final due = Catalog.words.take(101).map((w) => w.id).toList();
      final extra = Catalog.words[101].id;
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(reviews: <String, ReviewState>{
          for (final id in due) id: fwd(id, dueIn: const Duration(hours: -1)),
          extra: fwd(extra),
        }),
        clock: () => now,
      );
      expect(state.newWordsPaused, isTrue);
      expect(state.newReverseAvailable, 0);
      expect(state.unlockableReverseCardIds(), <String>[CardId.reverse(extra)]);
      expect(state.buildReviewQueue().where(CardId.isReverse), isEmpty);
    });

    test('難記的字：兩個方向答錯次數合計', () {
      final w = Catalog.words.first.id;
      final state = AppState(
        repository: MemoryProgressRepository(),
        data: ProgressData(
          reviews: <String, ReviewState>{w: fwd(w, lapses: 2)},
          reverseReviews: <String, ReviewState>{
            w: fwd(w, interval: 1, lapses: 2),
          },
        ),
        clock: () => now,
      );
      expect(state.lapsesOf(w), 4);
      expect(state.isHardWord(w), isTrue);
      expect(state.hardWordIds, <String>[w]);
    });
  });

  test('單元說明卡引用的文法點，看過後算學過，會進混合測驗的文法範圍', () {
    final card = Lessons.units
        .expand((l) => l.cards)
        .firstWhere((c) => c.grammarRefs.isNotEmpty);
    final point = Catalog.grammarPointById(card.grammarRefs.first)!;
    final state = AppState(
      repository: MemoryProgressRepository(),
      data: ProgressData(),
      clock: () => now,
    );
    expect(point.examples, isNotEmpty);
    expect(state.learnedGrammarExampleIds, isEmpty);
    state.markLearned(card.id);
    for (final id in card.grammarRefs) {
      expect(state.learnedGrammarExampleIds,
          contains(Catalog.grammarPointById(id)!.exampleId(0)));
    }
    final other = Catalog.grammarPoints
        .firstWhere((p) => !card.grammarRefs.contains(p.id));
    expect(state.learnedGrammarExampleIds, isNot(contains(other.exampleId(0))));
  });
}
