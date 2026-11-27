import 'dart:math' as math;

import '../util/format.dart';
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

  /// 實際可以複習的時間。
  ///
  /// 間隔 1 天以上的卡，從到期那天的 0 點（本機時間）起就算到期，不必等到幾點幾分
  /// （例如晚上 9 點評的卡，隔天早上就能複習）；但距離上次複習至少 [minGap]，
  /// 避免深夜 11 點多評的卡過了午夜幾分鐘就又出現。
  /// 答錯後 10 分鐘的重做（間隔 0 天）仍用精確時間。
  DateTime get availableAt {
    if (intervalDays < 1) {
      return dueAt;
    }
    final dayStart = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final earliest = lastReviewedAt.add(minGap);
    final at = earliest.isAfter(dayStart) ? earliest : dayStart;
    // 不會晚於原本的到期時間。
    return at.isAfter(dueAt) ? dueAt : at;
  }

  /// 間隔 1 天以上的卡，距離上次複習最少要隔多久才會到期。
  static const Duration minGap = Duration(hours: 8);

  bool isDue(DateTime now) => !availableAt.isAfter(now);

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

/// 複習卡的 id。韓文→中文（原本的方向）就是單字 id；
/// 中文→韓文在前面加 [reversePrefix]，例如 `rev:word:사과`。
class CardId {
  CardId._();

  static const String reversePrefix = 'rev:';

  static String reverse(String wordId) => '$reversePrefix$wordId';

  static bool isReverse(String cardId) => cardId.startsWith(reversePrefix);

  static String wordIdOf(String cardId) =>
      isReverse(cardId) ? cardId.substring(reversePrefix.length) : cardId;
}

/// 韓文→中文與中文→韓文兩個方向一起排程（純邏輯，不依賴 UI 或儲存）。
///
/// 兩個方向各有一份 [ReviewState]（[forward]、[reverse]，都以單字 id 為鍵），
/// 用同一套 [Srs] 規則各自計算間隔。
///
/// - 中文→韓文卡在韓文→中文的間隔達到 [unlockIntervalDays] 天以後才開啟
///   （先認得，再練說出來）。剛開啟的卡算「新卡」，數量由呼叫端限制。
/// - 同一個字一天只練一個方向：今天評過其中一個方向，另一個方向留到明天
///   （剛看過答案再考另一個方向，沒有練習效果）。
///   兩個方向同時到期時，先出韓文→中文。
/// - 同一個方向答錯後的重做（10 分鐘後到期）不受影響；跨過午夜也一樣，
///   重做完成前另一個方向不出。
class TwoWayQueue {
  TwoWayQueue._();

  static const int unlockIntervalDays = 3;

  static bool _reviewedToday(ReviewState? state, DateTime now) =>
      state != null && isSameDay(state.lastReviewedAt, now);

  /// 這個方向會擋住另一個方向：今天評過，或剛答錯、重做還沒完成
  /// （[Srs.recentWindow] 內；跨過午夜的重做也照樣先做完）。
  static bool _blocks(ReviewState? state, DateTime now) =>
      state != null &&
      (_reviewedToday(state, now) ||
          (state.repetitions == 0 &&
              state.lapses > 0 &&
              now.difference(state.lastReviewedAt) < Srs.recentWindow));

  /// 隔天 0 點（本機時間）。
  static DateTime _startOfTomorrow(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1);

  /// 韓文→中文卡現在可以出：到期，而且今天沒練過中文→韓文。
  static bool forwardDue(
    String wordId,
    Map<String, ReviewState> forward,
    Map<String, ReviewState> reverse,
    DateTime now,
  ) {
    final f = forward[wordId];
    return f != null && f.isDue(now) && !_blocks(reverse[wordId], now);
  }

  /// 中文→韓文卡現在可以出：到期、今天沒練過韓文→中文，
  /// 而且韓文→中文現在沒有要出（同時到期時讓韓文→中文先）。
  static bool reverseDue(
    String wordId,
    Map<String, ReviewState> forward,
    Map<String, ReviewState> reverse,
    DateTime now,
  ) {
    final r = reverse[wordId];
    return r != null &&
        r.isDue(now) &&
        !_blocks(forward[wordId], now) &&
        !forwardDue(wordId, forward, reverse, now);
  }

  /// 中文→韓文卡可以開啟（還沒練過）：韓文→中文的間隔達到 [unlockIntervalDays] 天、
  /// 現在沒有到期、今天也沒練過。
  static bool reverseUnlockable(
    String wordId,
    Map<String, ReviewState> forward,
    Map<String, ReviewState> reverse,
    DateTime now,
  ) {
    final f = forward[wordId];
    return !reverse.containsKey(wordId) &&
        f != null &&
        f.intervalDays >= unlockIntervalDays &&
        !f.isDue(now) &&
        !_reviewedToday(f, now);
  }

  /// 現在可以出的到期卡（兩個方向合在一起），最早到期的先；
  /// 同時到期時依 [wordIds] 的順序，同一個字韓文→中文在前。
  static List<String> dueCardIds({
    required Iterable<String> wordIds,
    required Map<String, ReviewState> forward,
    required Map<String, ReviewState> reverse,
    required DateTime now,
  }) {
    final cards = <({String id, DateTime dueAt, int order})>[];
    var order = 0;
    for (final wordId in wordIds) {
      if (forwardDue(wordId, forward, reverse, now)) {
        cards.add((id: wordId, dueAt: forward[wordId]!.dueAt, order: order));
      }
      order++;
      if (reverseDue(wordId, forward, reverse, now)) {
        cards.add((
          id: CardId.reverse(wordId),
          dueAt: reverse[wordId]!.dueAt,
          order: order,
        ));
      }
      order++;
    }
    cards.sort((a, b) {
      final byDue = a.dueAt.compareTo(b.dueAt);
      return byDue != 0 ? byDue : a.order.compareTo(b.order);
    });
    return cards.map((c) => c.id).toList();
  }

  /// 剛答錯、正在等 [Srs.relearnDelay] 的卡（還沒到期，兩個方向都算），
  /// 最早到期的先。用在使用者不想等、要馬上把答錯的卡練完時；
  /// 只認「剛答錯」（[Srs.recentWindow] 內、次數歸零），不會把一般排程中的卡提早叫出來。
  /// 正常流程不會兩個方向同時在等（另一個方向會被擋住）；這裡不另外防呆。
  static List<String> relearningCardIds({
    required Iterable<String> wordIds,
    required Map<String, ReviewState> forward,
    required Map<String, ReviewState> reverse,
    required DateTime now,
  }) {
    bool waiting(ReviewState? s) =>
        s != null &&
        s.repetitions == 0 &&
        s.lapses > 0 &&
        !s.isDue(now) &&
        now.difference(s.lastReviewedAt) < Srs.recentWindow;

    final cards = <({String id, DateTime dueAt, int order})>[];
    var order = 0;
    for (final wordId in wordIds) {
      if (waiting(forward[wordId])) {
        cards.add((id: wordId, dueAt: forward[wordId]!.dueAt, order: order));
      }
      order++;
      if (waiting(reverse[wordId])) {
        cards.add((
          id: CardId.reverse(wordId),
          dueAt: reverse[wordId]!.dueAt,
          order: order,
        ));
      }
      order++;
    }
    cards.sort((a, b) {
      final byDue = a.dueAt.compareTo(b.dueAt);
      return byDue != 0 ? byDue : a.order.compareTo(b.order);
    });
    return cards.map((c) => c.id).toList();
  }

  /// 可以開啟的中文→韓文卡（卡片 id），依 [wordIds] 的順序。
  static List<String> newReverseCardIds({
    required Iterable<String> wordIds,
    required Map<String, ReviewState> forward,
    required Map<String, ReviewState> reverse,
    required DateTime now,
  }) =>
      <String>[
        for (final wordId in wordIds)
          if (reverseUnlockable(wordId, forward, reverse, now))
            CardId.reverse(wordId),
      ];

  /// 組一輪：到期卡（最多 [dueLimit] 張；null 不限）→ 新開啟的中文→韓文卡
  /// （最多 [newReverseLimit] 張）→ 新單字（最多 [newWordLimit] 個）。
  static List<String> build({
    required List<String> wordIds,
    required Map<String, ReviewState> forward,
    required Map<String, ReviewState> reverse,
    required DateTime now,
    required int newWordLimit,
    required int newReverseLimit,
    int? dueLimit,
  }) {
    final due = dueCardIds(
      wordIds: wordIds,
      forward: forward,
      reverse: reverse,
      now: now,
    );
    return <String>[
      ...(dueLimit == null ? due : due.take(dueLimit)),
      ...newReverseCardIds(
        wordIds: wordIds,
        forward: forward,
        reverse: reverse,
        now: now,
      ).take(math.max(0, newReverseLimit)),
      ...ReviewQueue.newIds(itemIds: wordIds, states: forward)
          .take(math.max(0, newWordLimit)),
    ];
  }

  /// 還沒到、之後才可以出的卡中，最早的時間；沒有時為 null。
  /// 被「同一個字一天只練一個方向」擋住的卡，算成明天 0 點。
  /// 不包含還沒開啟的中文→韓文卡（那是新卡，不是排定的複習）。
  static DateTime? nextAvailableAt({
    required Iterable<String> wordIds,
    required Map<String, ReviewState> forward,
    required Map<String, ReviewState> reverse,
    required DateTime now,
  }) {
    final tomorrow = _startOfTomorrow(now);
    DateTime? earliest;
    void consider(DateTime availableAt, {required bool blockedToday}) {
      final at = blockedToday && availableAt.isBefore(tomorrow)
          ? tomorrow
          : availableAt;
      if (!at.isAfter(now)) {
        return; // 現在就可以出，不算「之後」。
      }
      if (earliest == null || at.isBefore(earliest!)) {
        earliest = at;
      }
    }

    for (final wordId in wordIds) {
      final f = forward[wordId];
      final r = reverse[wordId];
      if (f != null) {
        consider(f.availableAt, blockedToday: _blocks(r, now));
      }
      if (r != null) {
        consider(
          r.availableAt,
          blockedToday: _blocks(f, now) ||
              forwardDue(wordId, forward, reverse, now),
        );
      }
    }
    return earliest;
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
