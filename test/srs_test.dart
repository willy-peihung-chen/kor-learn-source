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
      var s = review(null, ReviewRating.unfamiliar);
      for (var i = 0; i < 20; i++) {
        s = review(s, ReviewRating.unfamiliar);
      }
      expect(s.ease, Srs.minEase);

      var t = review(null, ReviewRating.familiar);
      for (var i = 0; i < 30; i++) {
        t = review(t, ReviewRating.familiar);
      }
      expect(t.ease, Srs.maxEase);
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
    test('isDue：到期時間當下就算到期', () {
      final s = review(null, ReviewRating.normal);
      expect(s.isDue(now), isFalse);
      expect(s.isDue(s.dueAt), isTrue);
      expect(s.isDue(s.dueAt.add(const Duration(minutes: 1))), isTrue);
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

    test('dueIds 與 newIds 的數量', () {
      final states = <String, ReviewState>{
        'a': state('a', now.subtract(const Duration(hours: 1))),
        'b': state('b', now.add(const Duration(hours: 1))),
      };
      expect(
        ReviewQueue.dueIds(itemIds: ids, states: states, now: now),
        <String>['a'],
      );
      expect(ReviewQueue.newIds(itemIds: ids, states: states).length, 5);
    });
  });
}
