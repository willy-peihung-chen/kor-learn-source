import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/logic/srs.dart';

void main() {
  final now = DateTime(2026, 10, 29, 12);

  ReviewState review(
    ReviewState? previous,
    ReviewRating rating, {
    DateTime? at,
  }) {
    return Srs.review(
      previous: previous,
      itemId: 'word:아이',
      rating: rating,
      now: at ?? now,
    );
  }

  group('Srs.review', () {
    test('第一次評「普通」：1 天後再出現', () {
      final s = review(null, ReviewRating.normal);
      expect(s.repetitions, 1);
      expect(s.intervalDays, 1);
      expect(s.dueAt, now.add(const Duration(days: 1)));
      expect(s.ease, Srs.initialEase);
    });

    test('連續評「普通」：間隔依序為 1、3、7 天', () {
      var s = review(null, ReviewRating.normal);
      final intervals = <int>[s.intervalDays];
      for (var i = 0; i < 2; i++) {
        s = review(s, ReviewRating.normal);
        intervals.add(s.intervalDays);
      }
      // 第三次：round(3 * 2.3) = 7
      expect(intervals, <int>[1, 3, 7]);
    });

    test('連續評「熟悉」：間隔 3、7、23 天，係數上升', () {
      var s = review(null, ReviewRating.familiar);
      expect(s.intervalDays, 3);
      s = review(s, ReviewRating.familiar);
      expect(s.intervalDays, 7);
      expect(s.ease, closeTo(2.5, 1e-9));
      s = review(s, ReviewRating.familiar);
      // round(7 * 2.5 * 1.3) = round(22.75) = 23
      expect(s.intervalDays, 23);
    });

    test('評「不熟悉」：次數歸零、10 分鐘後再出現、係數下降、失誤加一', () {
      var s = review(null, ReviewRating.familiar); // 係數 2.3 → 2.4
      s = review(s, ReviewRating.unfamiliar); // 係數 2.4 → 2.2
      expect(s.repetitions, 0);
      expect(s.intervalDays, 0);
      expect(s.lapses, 1);
      expect(s.ease, closeTo(Srs.initialEase + 0.1 - 0.2, 1e-9));
      expect(s.dueAt, now.add(Srs.relearnDelay));
    });

    test('答錯之後再答對，間隔從頭開始', () {
      var s = review(null, ReviewRating.familiar);
      s = review(s, ReviewRating.familiar);
      s = review(s, ReviewRating.unfamiliar);
      s = review(s, ReviewRating.normal);
      expect(s.intervalDays, 1);
      expect(s.repetitions, 1);
    });

    test('係數不會低於下限、也不會高於上限', () {
      // 每次間隔一天答錯（剛答錯過的不重複扣，所以要隔開）。
      var s = review(null, ReviewRating.unfamiliar);
      for (var i = 1; i <= 20; i++) {
        s = review(s, ReviewRating.unfamiliar,
            at: now.add(Duration(days: i)));
      }
      expect(s.ease, Srs.minEase);

      var t = review(null, ReviewRating.familiar);
      for (var i = 0; i < 30; i++) {
        t = review(t, ReviewRating.familiar);
      }
      expect(t.ease, Srs.maxEase);
    });

    test('剛答錯過（2 小時內），再評「熟悉」：最多排 1 天，係數不上升', () {
      var s = review(null, ReviewRating.familiar);
      s = review(s, ReviewRating.familiar);
      s = review(s, ReviewRating.unfamiliar);
      final easeAfterLapse = s.ease;
      s = review(s, ReviewRating.familiar,
          at: now.add(const Duration(minutes: 3)));
      expect(s.intervalDays, 1);
      expect(s.repetitions, 1);
      expect(s.ease, easeAfterLapse);
    });

    test('剛答錯過，再評「普通」：1 天', () {
      var s = review(null, ReviewRating.unfamiliar);
      s = review(s, ReviewRating.normal,
          at: now.add(const Duration(minutes: 3)));
      expect(s.intervalDays, 1);
    });

    test('前一天答錯、今天評「熟悉」：照一般規則（3 天）', () {
      var s = review(null, ReviewRating.unfamiliar);
      s = review(s, ReviewRating.familiar,
          at: now.add(const Duration(days: 1)));
      expect(s.intervalDays, 3);
    });

    test('剛答錯又答錯（同一輪重做）：不重複扣係數、不重複算失誤', () {
      var s = review(null, ReviewRating.normal);
      s = review(s, ReviewRating.unfamiliar);
      final ease = s.ease;
      s = review(s, ReviewRating.unfamiliar,
          at: now.add(const Duration(minutes: 5)));
      s = review(s, ReviewRating.unfamiliar,
          at: now.add(const Duration(minutes: 9)));
      expect(s.lapses, 1);
      expect(s.ease, ease);
      expect(s.dueAt, now.add(const Duration(minutes: 9)).add(Srs.relearnDelay));
    });

    test('隔了一整晚又答錯：算新的一次失誤', () {
      var s = review(null, ReviewRating.normal);
      s = review(s, ReviewRating.unfamiliar);
      s = review(s, ReviewRating.unfamiliar,
          at: now.add(const Duration(hours: 10)));
      expect(s.lapses, 2);
    });

    test('跨過午夜的重做也算「剛答錯過」', () {
      final late = DateTime(2026, 10, 29, 23, 58);
      var s = review(null, ReviewRating.unfamiliar, at: late);
      s = review(s, ReviewRating.familiar,
          at: late.add(const Duration(minutes: 4)));
      expect(s.intervalDays, 1);
    });

    test('沒有答錯過的卡不受「剛答錯過」限制', () {
      var s = review(null, ReviewRating.normal);
      s = review(s, ReviewRating.familiar,
          at: now.add(const Duration(minutes: 5)));
      expect(s.intervalDays, 7);
    });

    test('間隔至少比前一次多一天', () {
      var s = review(null, ReviewRating.normal);
      s = review(s, ReviewRating.normal);
      for (var i = 0; i < 6; i++) {
        final before = s.intervalDays;
        s = review(s, ReviewRating.normal);
        expect(s.intervalDays, greaterThan(before));
      }
    });
  });

  group('ReviewState', () {
    test('isDue：間隔 1 天以上的卡，到期那天 0 點起就算到期', () {
      // now 是 10/29 12:00；評「普通」→ 10/30 12:00 到期。
      final s = review(null, ReviewRating.normal);
      expect(s.isDue(now), isFalse);
      expect(s.isDue(DateTime(2026, 10, 29, 23, 59)), isFalse);
      expect(s.isDue(DateTime(2026, 10, 30)), isTrue);
      expect(s.isDue(DateTime(2026, 10, 30, 8)), isTrue);
      expect(s.availableAt, DateTime(2026, 10, 30));
    });

    test('isDue：深夜評的卡，過了午夜不會馬上到期（至少隔 8 小時）', () {
      final late = DateTime(2026, 10, 29, 23, 50);
      final s = Srs.review(
          itemId: 'x', rating: ReviewRating.normal, now: late);
      expect(s.intervalDays, 1);
      expect(s.isDue(DateTime(2026, 10, 30, 0, 5)), isFalse);
      expect(s.availableAt, late.add(ReviewState.minGap));
      expect(s.isDue(DateTime(2026, 10, 30, 8)), isTrue);
    });

    test('isDue：答錯後的重做（間隔 0 天）仍用精確時間', () {
      final s = review(null, ReviewRating.unfamiliar);
      expect(s.intervalDays, 0);
      expect(s.isDue(now.add(const Duration(minutes: 9))), isFalse);
      expect(s.isDue(s.dueAt), isTrue);
      expect(s.availableAt, s.dueAt);
    });

    test('JSON 往返後內容相同', () {
      final s = review(null, ReviewRating.familiar);
      final back = ReviewState.fromJson(s.toJson())!;
      expect(back.itemId, s.itemId);
      expect(back.repetitions, s.repetitions);
      expect(back.intervalDays, s.intervalDays);
      expect(back.ease, s.ease);
      expect(back.lapses, s.lapses);
      expect(back.dueAt.isAtSameMomentAs(s.dueAt), isTrue);
      expect(back.lastReviewedAt.isAtSameMomentAs(s.lastReviewedAt), isTrue);
    });

    test('第一次評記下 firstReviewedAt，之後沿用不變', () {
      final s = review(null, ReviewRating.normal);
      expect(s.firstReviewedAt, now);
      final t = review(s, ReviewRating.unfamiliar,
          at: now.add(const Duration(days: 2)));
      expect(t.firstReviewedAt, now);
      final back = ReviewState.fromJson(t.toJson())!;
      expect(back.firstReviewedAt!.isAtSameMomentAs(now), isTrue);
    });

    test('舊紀錄沒有 firstReviewedAt：照常讀取，再評也維持 null（不算成今天的新字）', () {
      final old = <String, dynamic>{
        'itemId': 'word:아이',
        'repetitions': 1,
        'intervalDays': 1,
        'ease': 2.3,
        'lapses': 0,
        'dueAt': now.toUtc().toIso8601String(),
        'lastReviewedAt':
            now.subtract(const Duration(days: 1)).toUtc().toIso8601String(),
      };
      final s = ReviewState.fromJson(old)!;
      expect(s.firstReviewedAt, isNull);
      expect(s.repetitions, 1);
      final t = review(s, ReviewRating.normal);
      expect(t.firstReviewedAt, isNull);
      expect(t.toJson().containsKey('firstReviewedAt'), isFalse);
      // 這欄格式壞掉時也只當作沒有，不影響整筆紀錄。
      final broken = ReviewState.fromJson(
          <String, dynamic>{...old, 'firstReviewedAt': 'not a time'})!;
      expect(broken.firstReviewedAt, isNull);
    });

    test('格式錯誤的 JSON 回傳 null，不會丟例外', () {
      expect(ReviewState.fromJson(<String, dynamic>{'itemId': 1}), isNull);
      expect(ReviewState.fromJson(<String, dynamic>{}), isNull);
    });
  });

  group('ReviewQueue', () {
    const ids = <String>['a', 'b', 'c', 'd', 'e', 'f', 'g'];

    ReviewState state(String id, DateTime due) => ReviewState(
          itemId: id,
          repetitions: 1,
          intervalDays: 1,
          ease: 2.3,
          lapses: 0,
          dueAt: due,
          lastReviewedAt: now,
        );

    test('到期的排前面（越早到期越前面），再補新單字', () {
      final states = <String, ReviewState>{
        'a': state('a', now.add(const Duration(days: 2))), // 未到期
        'b': state('b', now.subtract(const Duration(days: 1))), // 到期
        'c': state('c', now.subtract(const Duration(days: 3))), // 到期，更早
      };
      final queue = ReviewQueue.build(
        itemIds: ids,
        states: states,
        now: now,
        newLimit: 2,
      );
      // 到期：c、b；新單字（沒有紀錄）：d、e（上限 2）
      expect(queue, <String>['c', 'b', 'd', 'e']);
    });

    test('未到期的卡片不會出現', () {
      final states = <String, ReviewState>{
        for (final id in ids) id: state(id, now.add(const Duration(days: 5))),
      };
      expect(
        ReviewQueue.build(itemIds: ids, states: states, now: now),
        isEmpty,
      );
    });

    test('沒有任何紀錄時，只給新單字、且受上限限制', () {
      final queue = ReviewQueue.build(
        itemIds: ids,
        states: <String, ReviewState>{},
        now: now,
        newLimit: 3,
      );
      expect(queue, <String>['a', 'b', 'c']);
    });

    test('dueLimit 限制到期卡張數（最早到期的先），新單字照樣補上', () {
      final states = <String, ReviewState>{
        'a': state('a', now.subtract(const Duration(hours: 1))),
        'b': state('b', now.subtract(const Duration(hours: 3))),
        'c': state('c', now.subtract(const Duration(hours: 2))),
      };
      final queue = ReviewQueue.build(
        itemIds: ids,
        states: states,
        now: now,
        newLimit: 1,
        dueLimit: 2,
      );
      expect(queue, <String>['b', 'c', 'd']);
      expect(
        ReviewQueue.build(
            itemIds: ids, states: states, now: now, newLimit: -3),
        <String>['b', 'c', 'a'],
      );
    });

    test('dueIds 與 newIds 的數量', () {
      final states = <String, ReviewState>{
        'a': state('a', now.subtract(const Duration(hours: 1))),
        // 間隔 1 天以上的卡從到期那天起算，所以「還沒到期」要放在明天以後。
        'b': state('b', now.add(const Duration(days: 1))),
      };
      expect(
        ReviewQueue.dueIds(itemIds: ids, states: states, now: now),
        <String>['a'],
      );
      expect(ReviewQueue.newIds(itemIds: ids, states: states).length, 5);
    });
  });

  group('ReviewRound', () {
    test('評「不熟悉」的卡排回本輪最後，評過「普通」或「熟悉」就不再出現', () {
      final round = ReviewRound(<String>['a', 'b', 'c']);
      round.rate(ReviewRating.unfamiliar); // a 排到最後
      expect(round.queue, <String>['a', 'b', 'c', 'a']);
      round.rate(ReviewRating.normal); // b
      round.rate(ReviewRating.familiar); // c
      expect(round.isFinished, isFalse);
      expect(round.idAt(round.position), 'a');
      expect(round.isRetry(round.position), isTrue);
      round.rate(ReviewRating.normal);
      expect(round.isFinished, isTrue);
      expect(round.ratedCount, 4);
      expect(round.wordCount, 3);
      expect(round.deferredIds, isEmpty);
    });

    test('還有別的卡時，同一張連續答錯會一直排到後面', () {
      final round = ReviewRound(<String>['a', 'b', 'c']);
      round.rate(ReviewRating.unfamiliar); // a → 最後
      round.rate(ReviewRating.unfamiliar); // b → 最後
      expect(round.queue, <String>['a', 'b', 'c', 'a', 'b']);
      round.rate(ReviewRating.normal); // c
      round.rate(ReviewRating.unfamiliar); // a 又錯，後面還有 b，排回最後
      expect(round.queue, <String>['a', 'b', 'c', 'a', 'b', 'a']);
      round.rate(ReviewRating.normal); // b
      round.rate(ReviewRating.normal); // a
      expect(round.isFinished, isTrue);
      expect(round.deferredIds, isEmpty);
    });

    test('答錯的是剩下的最後一張：不馬上重出，留到下一輪', () {
      final round = ReviewRound(<String>['a', 'b']);
      round.rate(ReviewRating.normal); // a
      round.rate(ReviewRating.unfamiliar); // b 是最後一張
      expect(round.isFinished, isTrue);
      expect(round.queue, <String>['a', 'b']);
      expect(round.deferredIds, <String>['b']);

      // 重做的卡在最後又答錯，也是留到下一輪。
      final retry = ReviewRound(<String>['a', 'b']);
      retry.rate(ReviewRating.unfamiliar); // a → 最後
      retry.rate(ReviewRating.normal); // b
      retry.rate(ReviewRating.unfamiliar); // 最後一張 a 又錯
      expect(retry.isFinished, isTrue);
      expect(retry.queue, <String>['a', 'b', 'a']);
      expect(retry.deferredIds, <String>['a']);
    });

    test('沒有答錯時，張數不變，也沒有重做的卡', () {
      final round = ReviewRound(<String>['a', 'b']);
      round.rate(ReviewRating.normal);
      round.rate(ReviewRating.familiar);
      expect(round.isFinished, isTrue);
      expect(round.length, 2);
      expect(round.isRetry(0), isFalse);
      expect(round.isRetry(1), isFalse);
      expect(round.ratingAt(0), ReviewRating.normal);
      expect(round.ratingAt(1), ReviewRating.familiar);
    });

    test('空的一輪直接結束；結束後再評會丟出錯誤', () {
      final round = ReviewRound(<String>[]);
      expect(round.isFinished, isTrue);
      expect(() => round.rate(ReviewRating.normal), throwsStateError);
    });

    test('外部傳入的清單之後被修改，不影響這一輪', () {
      final ids = <String>['a', 'b'];
      final round = ReviewRound(ids);
      ids.add('c');
      expect(round.length, 2);
    });
  });

  group('CardId', () {
    test('韓文→中文用單字 id；中文→韓文加 rev: 前綴，能還原單字 id', () {
      const id = 'word:배#船';
      expect(CardId.isReverse(id), isFalse);
      expect(CardId.wordIdOf(id), id);
      final rev = CardId.reverse(id);
      expect(rev, 'rev:word:배#船');
      expect(CardId.isReverse(rev), isTrue);
      expect(CardId.wordIdOf(rev), id);
    });
  });

  group('TwoWayQueue', () {
    ReviewState st(
      String id, {
      required int interval,
      required DateTime dueAt,
      required DateTime last,
      int repetitions = 2,
      int lapses = 0,
    }) =>
        ReviewState(
          itemId: id,
          repetitions: repetitions,
          intervalDays: interval,
          ease: 2.3,
          lapses: lapses,
          dueAt: dueAt,
          lastReviewedAt: last,
        );
    final yesterday = now.subtract(const Duration(days: 1));
    final later = now.add(const Duration(days: 2));
    final past = now.subtract(const Duration(hours: 1));

    test('韓文→中文間隔不到 ${TwoWayQueue.unlockIntervalDays} 天不開啟中文→韓文卡', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 1, dueAt: later, last: yesterday),
        'b': st('b', interval: TwoWayQueue.unlockIntervalDays,
            dueAt: later, last: yesterday),
      };
      expect(
        TwoWayQueue.newReverseCardIds(
          wordIds: <String>['a', 'b', 'c'],
          forward: forward,
          reverse: <String, ReviewState>{},
          now: now,
        ),
        <String>[CardId.reverse('b')],
      );
    });

    test('韓文→中文今天剛評過或已到期時，不開啟中文→韓文卡', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 3, dueAt: later, last: now),
        'b': st('b', interval: 3, dueAt: past, last: yesterday),
      };
      expect(
        TwoWayQueue.newReverseCardIds(
          wordIds: <String>['a', 'b'],
          forward: forward,
          reverse: <String, ReviewState>{},
          now: now,
        ),
        isEmpty,
      );
    });

    test('兩個方向同時到期時只出韓文→中文；今天評過一個方向，另一個方向不出', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 7, dueAt: past, last: yesterday),
        'b': st('b', interval: 7, dueAt: past, last: yesterday),
        'c': st('c', interval: 7, dueAt: later, last: now),
      };
      final reverse = <String, ReviewState>{
        'a': st('a', interval: 3, dueAt: past, last: yesterday),
        'b': st('b', interval: 3, dueAt: later, last: now),
        'c': st('c', interval: 3, dueAt: past, last: yesterday),
      };
      final due = TwoWayQueue.dueCardIds(
        wordIds: <String>['a', 'b', 'c'],
        forward: forward,
        reverse: reverse,
        now: now,
      );
      // a：韓文→中文先；b：今天練過中文→韓文，韓文→中文留到明天；
      // c：今天練過韓文→中文，中文→韓文留到明天。
      expect(due, <String>['a']);
    });

    test('中文→韓文答錯後的重做照常出現（同一個方向不受限制）', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 7, dueAt: later, last: yesterday),
      };
      final reverse = <String, ReviewState>{
        'a': st('a', interval: 0, repetitions: 0,
            dueAt: past, last: now.subtract(const Duration(minutes: 11))),
      };
      expect(
        TwoWayQueue.dueCardIds(
          wordIds: <String>['a'],
          forward: forward,
          reverse: reverse,
          now: now,
        ),
        <String>[CardId.reverse('a')],
      );
    });

    test('到期卡兩個方向合併、最早到期的先；一輪依序為到期、新反向卡、新單字', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 3,
            dueAt: now.subtract(const Duration(hours: 2)), last: yesterday),
        'b': st('b', interval: 7, dueAt: later, last: yesterday),
        'c': st('c', interval: 7, dueAt: later, last: yesterday),
      };
      final reverse = <String, ReviewState>{
        'b': st('b', interval: 3,
            dueAt: now.subtract(const Duration(hours: 5)), last: yesterday),
      };
      final queue = TwoWayQueue.build(
        wordIds: <String>['a', 'b', 'c', 'd', 'e'],
        forward: forward,
        reverse: reverse,
        now: now,
        newWordLimit: 1,
        newReverseLimit: 5,
        dueLimit: 20,
      );
      expect(queue, <String>[
        CardId.reverse('b'), // 最早到期
        'a',
        CardId.reverse('c'), // 新開啟的中文→韓文卡
        'd', // 新單字（限 1 個）
      ]);
    });

    test('到期上限算兩個方向合計；新卡數量照上限', () {
      final forward = <String, ReviewState>{
        for (final id in <String>['a', 'b', 'c'])
          id: st(id, interval: 7, dueAt: past, last: yesterday),
        for (final id in <String>['d', 'e'])
          id: st(id, interval: 7, dueAt: later, last: yesterday),
      };
      final reverse = <String, ReviewState>{
        'd': st('d', interval: 3,
            dueAt: now.subtract(const Duration(hours: 5)), last: yesterday),
      };
      final queue = TwoWayQueue.build(
        wordIds: <String>['a', 'b', 'c', 'd', 'e'],
        forward: forward,
        reverse: reverse,
        now: now,
        newWordLimit: 0,
        newReverseLimit: 0,
        dueLimit: 2,
      );
      expect(queue, <String>[CardId.reverse('d'), 'a']);
    });

    test('跨過午夜：中文→韓文答錯的重做先做完，韓文→中文才出', () {
      final midnight = DateTime(2026, 10, 30, 0, 5);
      final forward = <String, ReviewState>{
        'a': st('a', interval: 7,
            dueAt: DateTime(2026, 10, 29, 20), last: DateTime(2026, 10, 22)),
      };
      final reverse = <String, ReviewState>{
        'a': st('a', interval: 0, repetitions: 0, lapses: 1,
            dueAt: DateTime(2026, 10, 30, 0, 5),
            last: DateTime(2026, 10, 29, 23, 55)),
      };
      expect(
        TwoWayQueue.dueCardIds(
          wordIds: <String>['a'],
          forward: forward,
          reverse: reverse,
          now: midnight,
        ),
        <String>[CardId.reverse('a')],
      );
    });

    test('剛答錯、還在等 10 分鐘的卡可以馬上練；一般排程中的卡不會被提早叫出來', () {
      const minute = Duration(minutes: 1);
      final forward = <String, ReviewState>{
        // a：3 分鐘前答錯，7 分鐘後到期 → 等待中。
        'a': st('a', interval: 0, repetitions: 0, lapses: 1,
            dueAt: now.add(minute * 7), last: now.subtract(minute * 3)),
        // b：已經到期的重做 → 由 buildReviewQueue 負責，不算等待中。
        'b': st('b', interval: 0, repetitions: 0, lapses: 1,
            dueAt: now.subtract(minute), last: now.subtract(minute * 11)),
        // c：一般排程（答對過、2 天後到期）→ 不能提早。
        'c': st('c', interval: 3, dueAt: later, last: yesterday),
        // d：3 小時前答錯、還沒到期（不會發生，防呆）→ 超過 2 小時範圍不算。
        'd': st('d', interval: 0, repetitions: 0, lapses: 1,
            dueAt: now.add(minute), last: now.subtract(const Duration(hours: 3))),
      };
      final reverse = <String, ReviewState>{
        // a 的中文→韓文也在等，而且比 a 更早到期。
        'a': st('a', interval: 0, repetitions: 0, lapses: 1,
            dueAt: now.add(minute * 2), last: now.subtract(minute * 8)),
      };
      expect(
        TwoWayQueue.relearningCardIds(
          wordIds: <String>['a', 'b', 'c', 'd'],
          forward: forward,
          reverse: reverse,
          now: now,
        ),
        <String>[CardId.reverse('a'), 'a'],
      );
      // 沒有等待中的卡時為空。
      expect(
        TwoWayQueue.relearningCardIds(
          wordIds: <String>['b', 'c'],
          forward: forward,
          reverse: <String, ReviewState>{},
          now: now,
        ),
        isEmpty,
      );
    });

    test('被擋住的卡下次時間算成明天 0 點；沒有排定時為 null', () {
      final forward = <String, ReviewState>{
        'a': st('a', interval: 7, dueAt: past, last: yesterday),
      };
      final reverse = <String, ReviewState>{
        'a': st('a', interval: 3, dueAt: later, last: now),
      };
      // a 的韓文→中文到期，但今天練過中文→韓文 → 明天 0 點。
      expect(
        TwoWayQueue.nextAvailableAt(
          wordIds: <String>['a'],
          forward: forward,
          reverse: reverse,
          now: now,
        ),
        DateTime(2026, 10, 30),
      );
      expect(
        TwoWayQueue.nextAvailableAt(
          wordIds: <String>['x'],
          forward: forward,
          reverse: reverse,
          now: now,
        ),
        isNull,
      );
      // 沒被擋住、還沒到期：用到期那天。
      final notYet = <String, ReviewState>{
        'b': st('b', interval: 7, dueAt: later, last: yesterday),
      };
      expect(
        TwoWayQueue.nextAvailableAt(
          wordIds: <String>['b'],
          forward: notYet,
          reverse: <String, ReviewState>{},
          now: now,
        ),
        // 間隔 1 天以上：到期那天的 0 點。
        DateTime(later.year, later.month, later.day),
      );
    });
  });
}
