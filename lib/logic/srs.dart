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

  bool isDue(DateTime now) => !dueAt.isAfter(now);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'itemId': itemId,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'ease': ease,
        'lapses': lapses,
        'dueAt': encodeTime(dueAt),
        'lastReviewedAt': encodeTime(lastReviewedAt),
      };

  /// 資料格式不符時回傳 null，由呼叫端略過這筆紀錄。
  static ReviewState? fromJson(Map<String, dynamic> json) {
    try {
      return ReviewState(
        itemId: json['itemId'] as String,
        repetitions: (json['repetitions'] as num).toInt(),
        intervalDays: (json['intervalDays'] as num).toInt(),
        ease: (json['ease'] as num).toDouble(),
        lapses: (json['lapses'] as num).toInt(),
        dueAt: decodeTime(json['dueAt'] as String),
        lastReviewedAt: decodeTime(json['lastReviewedAt'] as String),
      );
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
class Srs {
  Srs._();

  static const double initialEase = 2.3;
  static const double minEase = 1.3;
  static const double maxEase = 3.0;
  static const Duration relearnDelay = Duration(minutes: 10);

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

    switch (rating) {
      case ReviewRating.unfamiliar:
        return ReviewState(
          itemId: itemId,
          repetitions: 0,
          intervalDays: 0,
          ease: math.max(minEase, ease - 0.2),
          lapses: lapses + 1,
          dueAt: now.add(relearnDelay),
          lastReviewedAt: now,
        );
      case ReviewRating.normal:
        final days = _nextInterval(
          nextRepetitions: repetitions + 1,
          previousInterval: interval,
          ease: ease,
          multiplier: 1.0,
          firstSteps: const <int>[1, 3],
        );
        return ReviewState(
          itemId: itemId,
          repetitions: repetitions + 1,
          intervalDays: days,
          ease: ease,
          lapses: lapses,
          dueAt: now.add(Duration(days: days)),
          lastReviewedAt: now,
        );
      case ReviewRating.familiar:
        final days = _nextInterval(
          nextRepetitions: repetitions + 1,
          previousInterval: interval,
          ease: ease,
          multiplier: 1.3,
          firstSteps: const <int>[3, 7],
        );
        return ReviewState(
          itemId: itemId,
          repetitions: repetitions + 1,
          intervalDays: days,
          ease: math.min(maxEase, ease + 0.1),
          lapses: lapses,
          dueAt: now.add(Duration(days: days)),
          lastReviewedAt: now,
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

  static List<String> build({
    required Iterable<String> itemIds,
    required Map<String, ReviewState> states,
    required DateTime now,
    int newLimit = 5,
  }) {
    return <String>[
      ...dueIds(itemIds: itemIds, states: states, now: now),
      ...newIds(itemIds: itemIds, states: states).take(newLimit),
    ];
  }
}
