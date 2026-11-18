import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/logic/progress_stats.dart';
import 'package:hangul_app/storage/progress_data.dart';

void main() {
  final base = DateTime(2026, 10, 29, 12);

  QuizAttempt attempt(
    QuizKind kind,
    String itemId, {
    required bool correct,
    required int minute,
  }) {
    return QuizAttempt(
      kind: kind,
      itemId: itemId,
      correct: correct,
      at: base.add(Duration(minutes: minute)),
    );
  }

  group('錯題本', () {
    test('答錯的題目進入錯題本', () {
      final seeds = ProgressStats.mistakeSeeds(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterName, 'letter:ㄴ', correct: true, minute: 1),
      ]);
      expect(seeds.map((s) => s.itemId), <String>['letter:ㄱ']);
    });

    test('之後答對就會移出錯題本', () {
      final seeds = ProgressStats.mistakeSeeds(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: true, minute: 5),
      ]);
      expect(seeds, isEmpty);
    });

    test('答對之後又答錯，會再回到錯題本', () {
      final seeds = ProgressStats.mistakeSeeds(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: true, minute: 5),
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 9),
      ]);
      expect(seeds.length, 1);
    });

    test('同一個項目的不同題型分開計算', () {
      final seeds = ProgressStats.mistakeSeeds(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterRoman, 'letter:ㄱ', correct: true, minute: 1),
      ]);
      expect(seeds.length, 1);
      expect(seeds.single.kind, QuizKind.letterName);
    });

    test('依最近答錯的時間由新到舊排序', () {
      final seeds = ProgressStats.mistakeSeeds(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterName, 'letter:ㄴ', correct: false, minute: 10),
        attempt(QuizKind.letterName, 'letter:ㄷ', correct: false, minute: 5),
      ]);
      expect(
        seeds.map((s) => s.itemId),
        <String>['letter:ㄴ', 'letter:ㄷ', 'letter:ㄱ'],
      );
    });
  });

  group('錯誤較多的項目', () {
    test('依答錯次數排序，沒答錯的項目不會出現', () {
      final items = ProgressStats.weakItems(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterRoman, 'letter:ㄱ', correct: false, minute: 1),
        attempt(QuizKind.letterName, 'letter:ㄴ', correct: false, minute: 2),
        attempt(QuizKind.letterName, 'letter:ㄷ', correct: true, minute: 3),
      ]);
      expect(items.map((i) => i.itemId), <String>['letter:ㄱ', 'letter:ㄴ']);
      expect(items.first.wrong, 2);
      expect(items.first.total, 2);
    });

    test('答錯次數相同時，錯誤比例高的在前', () {
      final items = ProgressStats.weakItems(<QuizAttempt>[
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: false, minute: 0),
        attempt(QuizKind.letterName, 'letter:ㄱ', correct: true, minute: 1),
        attempt(QuizKind.letterName, 'letter:ㄴ', correct: false, minute: 2),
      ]);
      expect(items.first.itemId, 'letter:ㄴ');
    });

    test('limit 限制回傳數量', () {
      final attempts = <QuizAttempt>[
        for (var i = 0; i < 8; i++)
          attempt(QuizKind.letterName, 'letter:$i', correct: false, minute: i),
      ];
      expect(ProgressStats.weakItems(attempts, limit: 3).length, 3);
    });
  });

  group('最近正確率', () {
    test('沒有紀錄時為 null', () {
      expect(ProgressStats.recentAccuracy(<QuizAttempt>[]), isNull);
    });

    test('只看最近 window 題', () {
      final attempts = <QuizAttempt>[
        // 先 10 題全錯，再 20 題全對。
        for (var i = 0; i < 10; i++)
          attempt(QuizKind.letterName, 'a$i', correct: false, minute: i),
        for (var i = 0; i < 20; i++)
          attempt(QuizKind.letterName, 'b$i', correct: true, minute: 10 + i),
      ];
      expect(ProgressStats.recentAccuracy(attempts), 1.0);
      expect(ProgressStats.recentAccuracy(attempts, window: 30), closeTo(20 / 30, 1e-9));
    });
  });
}
