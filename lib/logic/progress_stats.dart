import '../data/quiz_types.dart';
import '../storage/progress_data.dart';

class WeakItem {
  const WeakItem({
    required this.itemId,
    required this.wrong,
    required this.total,
  });

  final String itemId;
  final int wrong;
  final int total;
}

/// 由實際作答紀錄推算統計，全部是純函式。
class ProgressStats {
  ProgressStats._();

  /// 錯題本：每個「題型＋項目」只看最近一次作答，答錯的才留在錯題本；
  /// 之後答對就會移出。依最近答錯的時間由新到舊排序。
  static List<QuizSeed> mistakeSeeds(List<QuizAttempt> attempts) {
    final latest = <String, QuizAttempt>{};
    for (final attempt in attempts) {
      latest[attempt.key] = attempt;
    }
    final wrong = latest.values.where((a) => !a.correct).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return wrong.map((a) => QuizSeed(a.kind, a.itemId)).toList();
  }

  /// 錯誤較多的項目：依答錯次數、再依錯誤比例排序。
  static List<WeakItem> weakItems(List<QuizAttempt> attempts, {int limit = 5}) {
    final wrong = <String, int>{};
    final total = <String, int>{};
    for (final attempt in attempts) {
      total[attempt.itemId] = (total[attempt.itemId] ?? 0) + 1;
      if (!attempt.correct) {
        wrong[attempt.itemId] = (wrong[attempt.itemId] ?? 0) + 1;
      }
    }
    final items = wrong.entries
        .map(
          (e) => WeakItem(
            itemId: e.key,
            wrong: e.value,
            total: total[e.key] ?? e.value,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byWrong = b.wrong.compareTo(a.wrong);
        if (byWrong != 0) {
          return byWrong;
        }
        return (b.wrong / b.total).compareTo(a.wrong / a.total);
      });
    return items.take(limit).toList();
  }

  /// 最近 [window] 題的正確率（0～1）；沒有紀錄時回傳 null。
  static double? recentAccuracy(List<QuizAttempt> attempts, {int window = 20}) {
    if (attempts.isEmpty) {
      return null;
    }
    final start = attempts.length > window ? attempts.length - window : 0;
    final recent = attempts.sublist(start);
    final correct = recent.where((a) => a.correct).length;
    return correct / recent.length;
  }
}
