import 'dart:math' as math;

import '../util/time_codec.dart';

enum ReviewRating {
  unfamiliar('不熟悉'),
  normal('普通'),
  familiar('熟悉');

  const ReviewRating(this.label);
  final String label;
}

/// 單一單字卡的複習狀態。
class ReviewState {
  const ReviewState({
    required this.itemId,
    required this.repetitions,
    required this.intervalDays,
    required this.ease,
    required this.lapses,
    required this.dueAt,
    required this.lastReviewedAt,
    this.firstReviewedAt,
  });

  final String itemId;

  /// 連續答出「普通／熟悉」的次數。
  final int repetitions;

  /// 目前的複習間隔（天）。
  final int intervalDays;

  /// 間隔成長係數。
  final double ease;

  /// 答成「不熟悉」的累計次數。
  final int lapses;

  final DateTime dueAt;
  final DateTime lastReviewedAt;

  /// 第一次評這張卡的時間（算「今天學了幾個新字」用）。
  /// 加這個欄位之前的舊紀錄沒有這項，讀回來是 null（當作以前學的，不算今天）。
  final DateTime? firstReviewedAt;

  bool isDue(DateTime now) => !dueAt.isAfter(now);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'itemId': itemId,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'ease': ease,
        'lapses': lapses,
        'dueAt': encodeTime(dueAt),
        'lastReviewedAt': encodeTime(lastReviewedAt),
        if (firstReviewedAt != null)
          'firstReviewedAt': encodeTime(firstReviewedAt!),
      };

  /// 資料格式不符時回傳 null，由呼叫端略過這筆紀錄。
  static ReviewState? fromJson(Map<String, dynamic> json) {
    try {
      final first = json['firstReviewedAt'];
      return ReviewState(
        itemId: json['itemId'] as String,
        repetitions: (json['repetitions'] as num).toInt(),
        intervalDays: (json['intervalDays'] as num).toInt(),
        ease: (json['ease'] as num).toDouble(),
        lapses: (json['lapses'] as num).toInt(),
        dueAt: decodeTime(json['dueAt'] as String),
        lastReviewedAt: decodeTime(json['lastReviewedAt'] as String),
        // 舊紀錄沒有這欄；格式不對時也當作沒有，不影響其他欄位。
        firstReviewedAt: first is String ? _tryDecode(first) : null,
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime? _tryDecode(String text) {
    try {
      return decodeTime(text);
    } catch (_) {
      return null;
    }
  }
}

/// 簡單的間隔重複排程（純邏輯，不依賴 UI 或儲存）。
///
/// - 不熟悉：次數歸零，10 分鐘後再出現，係數下降。
/// - 普通：間隔依序 1 天、3 天，之後為「前次間隔 × 係數」。
/// - 熟悉：間隔依序 3 天、7 天，之後為「前次間隔 × 係數 × 1.3」，係數上升。
/// - 剛答錯過（[recentWindow] 內）的卡：再答對時最多排到 1 天後、係數不上升
///   （剛看過答案幾分鐘後答對，不代表真的記住了）；
///   再答錯也不重複扣係數、不重複算失誤（同一輪重做好幾次只算一次）。
class Srs {
  Srs._();

  static const double initialEase = 2.3;
  static const double minEase = 1.3;
  static const double maxEase = 3.0;
  static const Duration relearnDelay = Duration(minutes: 10);

  /// 「剛答錯過」的時間範圍：涵蓋同一輪的重做（答錯後 10 分鐘到期），
  /// 但不跨過一整晚。用時間差而不是日期，跨過午夜的重做也一樣適用。
  static const Duration recentWindow = Duration(hours: 2);

  static ReviewState review({
    ReviewState? previous,
    required String itemId,
    required ReviewRating rating,
    required DateTime now,
  }) {
    final repetitions = previous?.repetitions ?? 0;
    final interval = previous?.intervalDays ?? 0;
    final ease = previous?.ease ?? initialEase;
    final lapses = previous?.lapses ?? 0;
    // 第一次評：記下現在；之後沿用（舊紀錄沒有時維持 null，不會被算成今天的新字）。
    final firstReviewedAt =
        previous == null ? now : previous.firstReviewedAt;
    // 上一次評的是「不熟悉」（次數歸零），而且在 [recentWindow] 內。
    final recentlyFailed = previous != null &&
        previous.repetitions == 0 &&
        previous.lapses > 0 &&
        now.difference(previous.lastReviewedAt) < recentWindow;

    switch (rating) {
      case ReviewRating.unfamiliar:
        return ReviewState(
          itemId: itemId,
          repetitions: 0,
          intervalDays: 0,
          ease: recentlyFailed ? ease : math.max(minEase, ease - 0.2),
          lapses: recentlyFailed ? lapses : lapses + 1,
          dueAt: now.add(relearnDelay),
          lastReviewedAt: now,
          firstReviewedAt: firstReviewedAt,
        );
      case ReviewRating.normal:
        final grown = _nextInterval(
          nextRepetitions: repetitions + 1,
          previousInterval: interval,
          ease: ease,
          multiplier: 1.0,
          firstSteps: const <int>[1, 3],
        );
        final days = recentlyFailed ? math.min(1, grown) : grown;
        return ReviewState(
          itemId: itemId,
          repetitions: repetitions + 1,
          intervalDays: days,
          ease: ease,
          lapses: lapses,
          dueAt: now.add(Duration(days: days)),
          lastReviewedAt: now,
          firstReviewedAt: firstReviewedAt,
        );
      case ReviewRating.familiar:
        final grown = _nextInterval(
          nextRepetitions: repetitions + 1,
          previousInterval: interval,
          ease: ease,
          multiplier: 1.3,
          firstSteps: const <int>[3, 7],
        );
        final days = recentlyFailed ? math.min(1, grown) : grown;
        return ReviewState(
          itemId: itemId,
          repetitions: repetitions + 1,
          intervalDays: days,
          ease: recentlyFailed ? ease : math.min(maxEase, ease + 0.1),
          lapses: lapses,
          dueAt: now.add(Duration(days: days)),
          lastReviewedAt: now,
          firstReviewedAt: firstReviewedAt,
        );
    }
  }

  static int _nextInterval({
    required int nextRepetitions,
    required int previousInterval,
    required double ease,
    required double multiplier,
    required List<int> firstSteps,
  }) {
    if (nextRepetitions <= firstSteps.length) {
      return firstSteps[nextRepetitions - 1];
    }
    final grown = (previousInterval * ease * multiplier).round();
    return math.max(previousInterval + 1, grown);
  }
}

/// 組出一輪單字複習要看的卡片：先看到期的，再補少量新單字。
class ReviewQueue {
  ReviewQueue._();

  static List<String> dueIds({
    required Iterable<String> itemIds,
    required Map<String, ReviewState> states,
    required DateTime now,
  }) {
    final due = <ReviewState>[];
    for (final id in itemIds) {
      final state = states[id];
      if (state != null && state.isDue(now)) {
        due.add(state);
      }
    }
    due.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return due.map((s) => s.itemId).toList();
  }

  static List<String> newIds({
    required Iterable<String> itemIds,
    required Map<String, ReviewState> states,
  }) {
    return itemIds.where((id) => !states.containsKey(id)).toList();
  }

  /// [dueLimit] 為 null 時不限到期卡張數。
  static List<String> build({
    required Iterable<String> itemIds,
    required Map<String, ReviewState> states,
    required DateTime now,
    int newLimit = 5,
    int? dueLimit,
  }) {
    final due = dueIds(itemIds: itemIds, states: states, now: now);
    return <String>[
      ...(dueLimit == null ? due : due.take(dueLimit)),
      ...newIds(itemIds: itemIds, states: states).take(math.max(0, newLimit)),
    ];
  }
}

/// 一輪複習的進行狀態（純邏輯，不依賴 UI）。
///
/// 評「不熟悉」的卡會排回本輪最後，直到評過「普通」或「熟悉」為止；
/// 重排的卡不是新的一張，不會多佔新單字的名額。
///
/// 例外：答錯的是本輪剩下的最後一張時，不馬上重出（剛看完答案就再答一次沒有練習效果），
/// 改記在 [deferredIds]，這張照排程 10 分鐘後到期，下一輪再練。
class ReviewRound {
  ReviewRound(Iterable<String> ids) : _queue = List<String>.of(ids);

  final List<String> _queue;
  final Map<int, ReviewRating> _rated = <int, ReviewRating>{};
  final List<String> _deferred = <String>[];
  int _position = 0;

  /// 本輪的卡片（包含排回來重做的），依出現順序。
  List<String> get queue => List<String>.unmodifiable(_queue);

  int get length => _queue.length;

  /// 目前要評的卡片位置；等於 [length] 時代表這一輪做完了。
  int get position => _position;

  bool get isFinished => _position >= _queue.length;

  String idAt(int index) => _queue[index];

  /// 第 [index] 張已評的結果；還沒評時為 null。
  ReviewRating? ratingAt(int index) => _rated[index];

  /// 第 [index] 張是不是排回來重做的（同一個字在本輪前面已經出現過）。
  bool isRetry(int index) => _queue.sublist(0, index).contains(_queue[index]);

  /// 本輪評分的次數（重做也算一次）。
  int get ratedCount => _rated.length;

  /// 本輪複習到的不同單字數。
  int get wordCount => _queue.toSet().length;

  /// 最後一張答錯、留到下一輪再練的單字（依答錯順序）。
  List<String> get deferredIds => List<String>.unmodifiable(_deferred);

  /// 評目前這一張，並前進到下一張。
  void rate(ReviewRating rating) {
    if (isFinished) {
      throw StateError('這一輪已經結束');
    }
    _rated[_position] = rating;
    if (rating == ReviewRating.unfamiliar) {
      final id = _queue[_position];
      if (_position == _queue.length - 1) {
        _deferred.add(id);
      } else {
        _queue.add(id);
      }
    }
    _position++;
  }
}
