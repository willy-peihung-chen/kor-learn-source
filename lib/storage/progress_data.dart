import 'dart:math' as math;

import '../data/quiz_types.dart';
import '../logic/srs.dart';
import '../util/time_codec.dart';

/// 單題作答紀錄。錯題本與「錯誤較多的項目」都由這份紀錄推算。
class QuizAttempt {
  const QuizAttempt({
    required this.kind,
    required this.itemId,
    required this.correct,
    required this.at,
  });

  final QuizKind kind;
  final String itemId;
  final bool correct;
  final DateTime at;

  String get key => '${kind.name}|$itemId';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind.name,
        'itemId': itemId,
        'correct': correct,
        'at': encodeTime(at),
      };

  static QuizAttempt? fromJson(Map<String, dynamic> json) {
    try {
      final kind = QuizKind.values.asNameMap()[json['kind'] as String];
      if (kind == null) {
        return null;
      }
      return QuizAttempt(
        kind: kind,
        itemId: json['itemId'] as String,
        correct: json['correct'] as bool,
        at: decodeTime(json['at'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

/// 最近學習紀錄（首頁與進度頁顯示用）。
class ActivityEntry {
  const ActivityEntry({
    required this.type,
    required this.label,
    required this.at,
    this.count = 1,
  });

  /// lesson_completed、quiz、review。
  final String type;
  final String label;
  final DateTime at;

  /// 同一天連續的複習會合併成一筆，用 count 記錄張數。
  final int count;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'label': label,
        'at': encodeTime(at),
        'count': count,
      };

  static ActivityEntry? fromJson(Map<String, dynamic> json) {
    try {
      return ActivityEntry(
        type: json['type'] as String,
        label: json['label'] as String,
        at: decodeTime(json['at'] as String),
        count: (json['count'] as num?)?.toInt() ?? 1,
      );
    } catch (_) {
      return null;
    }
  }
}

/// 使用者所有學習紀錄。只負責資料與 JSON，不含任何儲存媒介的細節。
class ProgressData {
  ProgressData({
    Set<String>? completedLessons,
    Set<String>? learnedItems,
    Map<String, ReviewState>? reviews,
    List<QuizAttempt>? attempts,
    List<ActivityEntry>? activity,
    this.extraNewWordsDate,
    this.extraNewWords = 0,
  })  : completedLessons = completedLessons ?? <String>{},
        learnedItems = learnedItems ?? <String>{},
        reviews = reviews ?? <String, ReviewState>{},
        attempts = attempts ?? <QuizAttempt>[],
        activity = activity ?? <ActivityEntry>[];

  static const int schemaVersion = 1;
  static const int maxAttempts = 1000;
  static const int maxActivity = 50;

  final Set<String> completedLessons;
  final Set<String> learnedItems;
  final Map<String, ReviewState> reviews;
  final List<QuizAttempt> attempts;
  final List<ActivityEntry> activity;

  /// 「今天再多學」加上的新字額度，只在 [extraNewWordsDate]（本機日期 yyyy-mm-dd）那天有效。
  String? extraNewWordsDate;
  int extraNewWords;

  /// 只保留最近的紀錄，避免資料無限成長。
  void trim() {
    if (attempts.length > maxAttempts) {
      attempts.removeRange(0, attempts.length - maxAttempts);
    }
    if (activity.length > maxActivity) {
      activity.removeRange(0, activity.length - maxActivity);
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': schemaVersion,
        'completedLessons': completedLessons.toList()..sort(),
        'learnedItems': learnedItems.toList()..sort(),
        'reviews': reviews.values.map((r) => r.toJson()).toList(),
        'attempts': attempts.map((a) => a.toJson()).toList(),
        'activity': activity.map((a) => a.toJson()).toList(),
        if (extraNewWordsDate != null) ...<String, dynamic>{
          'extraNewWordsDate': extraNewWordsDate,
          'extraNewWords': extraNewWords,
        },
      };

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> maps(Object? raw) {
      if (raw is! List) {
        return <Map<String, dynamic>>[];
      }
      return raw.whereType<Map<String, dynamic>>().toList();
    }

    Set<String> strings(Object? raw) {
      if (raw is! List) {
        return <String>{};
      }
      return raw.whereType<String>().toSet();
    }

    final reviews = <String, ReviewState>{};
    for (final map in maps(json['reviews'])) {
      final state = ReviewState.fromJson(map);
      if (state != null) {
        reviews[state.itemId] = state;
      }
    }

    return ProgressData(
      completedLessons: strings(json['completedLessons']),
      learnedItems: strings(json['learnedItems']),
      reviews: reviews,
      attempts: maps(json['attempts'])
          .map(QuizAttempt.fromJson)
          .whereType<QuizAttempt>()
          .toList(),
      activity: maps(json['activity'])
          .map(ActivityEntry.fromJson)
          .whereType<ActivityEntry>()
          .toList(),
      extraNewWordsDate: json['extraNewWordsDate'] is String
          ? json['extraNewWordsDate'] as String
          : null,
      extraNewWords: json['extraNewWords'] is num
          ? math.max(0, (json['extraNewWords'] as num).toInt())
          : 0,
    );
  }
}
