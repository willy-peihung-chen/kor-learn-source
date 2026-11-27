import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../logic/meaning_tokens.dart';
import '../logic/srs.dart';
import '../state/app_state.dart';
import '../util/format.dart';
import 'app_scope.dart';
import 'haeyo_form_line.dart';
import 'hanja_suffix_line.dart';
import 'speak_button.dart';
import 'theme.dart';
import 'widgets.dart';

/// 首頁與單字頁共用的「新單字」狀態說明，數字都來自 [AppState]。
String newWordStatus(AppState state) {
  if (state.newWordsPaused) {
    return '到期卡超過 ${AppState.backlogPauseThreshold} 張，新單字暫停';
  }
  final left = state.newWordsLeftToday;
  if (left == 0) {
    return '今天的新單字已學完';
  }
  return '今天還可以學 $left 個新單字';
}

/// 開始單字複習。[topic] 為 null 代表所有主題中到期與新的單字。
void openReview(BuildContext context, {WordTopic? topic}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ReviewSessionPage(topic: topic),
    ),
  );
}

/// 單字複習：先看題目（韓文，或中文→韓文卡的中文），點一下顯示答案與例句，
/// 再自評熟悉程度。
class ReviewSessionPage extends StatefulWidget {
  const ReviewSessionPage({super.key, this.topic});

  final WordTopic? topic;

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  ReviewRound _round = ReviewRound(const <String>[]);
  bool _initialized = false;
  bool _revealed = false;

  /// 不為 null 代表正在回頭查看已評過的卡片（只能看，不能重評）。
  int? _browse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _round = ReviewRound(
        AppScope.of(context).buildReviewQueue(topicId: widget.topic?.id),
      );
      _initialized = true;
    }
  }

  void _rate(ReviewRating rating) {
    final state = AppScope.of(context);
    state.rateCard(_round.idAt(_round.position), rating);
    setState(() {
      _round.rate(rating);
      _revealed = false;
    });
  }

  void _restart() {
    final state = AppScope.of(context);
    setState(() {
      _round = ReviewRound(state.buildReviewQueue(topicId: widget.topic?.id));
      _revealed = false;
      _browse = null;
    });
  }

  void _addExtraNewWords() {
    AppScope.of(context).addExtraNewWordsToday();
    _restart();
  }

  void _goPrevious() {
    final current = _browse ?? _round.position;
    if (current <= 0) {
      return;
    }
    setState(() => _browse = current - 1);
  }

  void _goNext() {
    final current = _browse;
    if (current == null) {
      return;
    }
    setState(
      () => _browse = current + 1 >= _round.position ? null : current + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.topic == null ? '單字複習' : '複習・${widget.topic!.title}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    if (_round.isFinished) {
      return _finished(context);
    }

    final browsing = _browse != null;
    final index = _browse ?? _round.position;
    final showAnswer = browsing || _revealed;
    final cardId = _round.idAt(index);
    final reverse = CardId.isReverse(cardId);
    final word = Catalog.wordById(CardId.wordIdOf(cardId))!;
    final isNew = state.isNewCard(cardId);
    final isRetry = _round.isRetry(index);
    final topic = Catalog.topicOfWord(word.id);
    final ratedAs = _round.ratingAt(index);
    final isHard = state.isHardWord(word.id);
    final note = word.note == null
        ? const <Widget>[]
        : <Widget>[
            Text(
              isHard ? '用法說明（這個字比較難記，先看這裡）' : '用法說明',
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 2),
            Text(
              word.note!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ];

    return PageBody(
      children: <Widget>[
        Text(
          '第 ${index + 1} / ${_round.length} 張・'
          '${browsing ? '回頭查看（已評為「${ratedAs?.label ?? ''}」）' : (isRetry ? '再練一次' : (isNew ? (reverse ? '新卡' : '新單字') : '複習'))}'
          '${reverse ? '・中文→韓文' : ''}'
          '${isHard ? '・難記的字' : ''}'
          '${topic == null ? '' : '・${topic.title}'}',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: reverse
                ? _reverseCard(context, word, showAnswer, isHard, note)
                : _forwardCard(context, word, showAnswer, isHard, note),
          ),
        ),
        const SizedBox(height: 16),
        if (browsing)
          Text(
            '這張已經評過，只能查看；回到目前進度後繼續評下一張。',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          )
        else if (_revealed) ...<Widget>[
          Row(
            children: <Widget>[
              for (final rating in ReviewRating.values) ...<Widget>[
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _rate(rating),
                    child: Text(rating.label),
                  ),
                ),
                if (rating != ReviewRating.values.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reverse
                ? '不熟悉：說不出來或說錯（這一輪稍後再出現；最後一張則留到下一輪）\n'
                    '普通：想了一下才說出來\n'
                    '熟悉：馬上說得出來'
                : '不熟悉：想不起來或想錯（這一輪稍後再出現；最後一張則留到下一輪）\n'
                    '普通：想了一下才想起來\n'
                    '熟悉：一看就知道',
            style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.5),
          ),
        ]
        else
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: Text(reverse ? '顯示韓文' : '顯示意思'),
          ),
        if (_round.position > 0 || browsing) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: index > 0 ? _goPrevious : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('上一張'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: browsing ? _goNext : null,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(
                    _browse != null && _browse! + 1 >= _round.position
                        ? '回到目前進度'
                        : '下一張',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 韓文→中文卡：先看韓文，翻開後看意思、例句與用法說明。
  List<Widget> _forwardCard(
    BuildContext context,
    WordItem word,
    bool showAnswer,
    bool isHard,
    List<Widget> note,
  ) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: Text(word.hangul, style: hangulStyle(64))),
          const SizedBox(width: 4),
          SpeakButton(text: word.hangul, tooltip: '朗讀單字'),
        ],
      ),
      if (showAnswer) ...<Widget>[
        const SizedBox(height: 16),
        Text(word.meaning, style: theme.textTheme.headlineSmall),
        ..._hanja(context, word),
        ..._suffix(word),
        ..._haeyo(word),
        if (isHard && note.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          ...note,
        ],
        ..._example(context, word),
        const SizedBox(height: 8),
        Text(
          '中文翻譯',
          style: theme.textTheme.labelMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 2),
        Text(word.exampleMeaning, style: theme.textTheme.bodyLarge),
        if (!isHard && note.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          ...note,
        ],
      ],
    ];
  }

  /// 中文→韓文卡：先看中文意思和例句的中文翻譯（幫忙分辨意思相近的字），
  /// 想出韓文後翻開；翻開前沒有朗讀按鈕，避免直接聽到答案。
  List<Widget> _reverseCard(
    BuildContext context,
    WordItem word,
    bool showAnswer,
    bool isHard,
    List<Widget> note,
  ) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final similar = sameMeaningWords(word);
    return <Widget>[
      Text(
        '韓文怎麼說？',
        style: theme.textTheme.labelMedium?.copyWith(color: muted),
      ),
      const SizedBox(height: 6),
      Text(
        word.meaning,
        style: theme.textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        '例句：${word.exampleMeaning}',
        style: theme.textTheme.bodyMedium?.copyWith(color: muted, height: 1.5),
        textAlign: TextAlign.center,
      ),
      if (similar.isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          '還有 ${similar.length} 個單字的意思和這個相近，請照例句想這一個。',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
          textAlign: TextAlign.center,
        ),
      ],
      if (showAnswer) ...<Widget>[
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(child: Text(word.hangul, style: hangulStyle(56))),
            const SizedBox(width: 4),
            SpeakButton(text: word.hangul, tooltip: '朗讀單字'),
          ],
        ),
        ..._hanja(context, word),
        ..._suffix(word),
        ..._haeyo(word),
        if (isHard && note.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          ...note,
        ],
        ..._example(context, word),
        if (similar.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            '意思相近的字',
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 2),
          for (final other in similar)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    '${other.hangul}（${other.meaning}）',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 2),
                SpeakButton(
                  text: other.hangul,
                  tooltip: '朗讀${other.hangul}',
                  iconSize: 20,
                ),
              ],
            ),
        ],
        if (!isHard && note.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          ...note,
        ],
      ],
    ];
  }

  /// 動詞、形容詞翻開後多一行해요體（비싸다 → 비싸요）。
  List<Widget> _haeyo(WordItem word) {
    if (haeyoFormOf(word) == null) {
      return const <Widget>[];
    }
    return <Widget>[
      const SizedBox(height: 2),
      HaeyoFormLine(word: word, center: true),
    ];
  }

  List<Widget> _suffix(WordItem word) {
    if (word.hanja == null) {
      return const <Widget>[];
    }
    return <Widget>[HanjaSuffixLine(word: word, center: true)];
  }

  List<Widget> _hanja(BuildContext context, WordItem word) {
    if (word.hanja == null) {
      return const <Widget>[];
    }
    final theme = Theme.of(context);
    return <Widget>[
      const SizedBox(height: 6),
      Text(
        '漢字詞：${word.hanja}',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    ];
  }

  /// 韓文例句與朗讀按鈕（標出敬語或半語）。
  List<Widget> _example(BuildContext context, WordItem word) {
    final theme = Theme.of(context);
    return <Widget>[
      const SizedBox(height: 20),
      Text(
        word.isPlainStyleExample ? '例句（半語，非敬語）' : '例句（敬語）',
        style: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: Text(word.example, style: hangulStyle(20))),
          const SizedBox(width: 4),
          SpeakButton(text: word.example, tooltip: '朗讀例句', iconSize: 22),
        ],
      ),
    ];
  }

  /// 一輪結束（或一開始就沒有卡）時的畫面：說明為什麼停、接下來可以做什麼。
  Widget _finished(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final topicId = widget.topic?.id;

    final nextDue = state.nextDueAtOf(topicId);
    final hasMore = state.buildReviewQueue(topicId: topicId).isNotEmpty;
    final dueLeft = state.dueCountOf(topicId);
    final unseenLeft = state.newWordIdsInOrder(topicId: topicId).length;
    final canAddExtra = state.canAddExtraNewWordsOf(topicId);

    final unlockLeft = state.unlockableReverseCardIds(topicId: topicId).length;

    final notes = <String>[
      for (final id in _round.deferredIds)
        '「${Catalog.wordById(CardId.wordIdOf(id))?.hangul ?? id}」'
            '${CardId.isReverse(id) ? '（中文→韓文）' : ''}是這一輪的最後一張，答錯後先不馬上重出；'
            '${Srs.relearnDelay.inMinutes} 分鐘後到期，到時在單字頁按「開始複習」就會出現。',
      if (dueLeft > 0)
        '還有 $dueLeft 張到期，按「再來一輪」繼續'
            '（每輪最多 ${AppState.dueCardsPerRound} 張）。',
      if ((unseenLeft > 0 || unlockLeft > 0) && state.newWordsPaused)
        '全部單字到期的卡有 ${state.dueCount} 張（超過 ${AppState.backlogPauseThreshold} 張），'
            '先暫停新單字，複習做完一些再學新字。'
      else if (unseenLeft > 0 && state.newWordsLeftToday == 0)
        '今天的 ${state.newWordsQuotaToday} 個新單字已經學完'
            '（每天 ${AppState.newWordsPerDay} 個，單字頁和各主題共用）。',
      if (unlockLeft > 0 &&
          !state.newWordsPaused &&
          state.newReverseLeftToday == 0)
        '今天的 ${AppState.newReverseCardsPerDay} 張中文→韓文新卡已經練完，'
            '還有 $unlockLeft 個字明天之後再開始練。',
    ];

    return PageBody(
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _round.ratedCount > 0
                    ? '本輪完成，共複習 ${_round.wordCount} 個單字'
                        '${_round.ratedCount > _round.wordCount ? '（答錯的重做過，共評 ${_round.ratedCount} 次）' : ''}。'
                    : (widget.topic == null
                        ? '目前沒有需要複習的單字。'
                        : '這個主題目前沒有需要複習的單字。'),
                style: theme.textTheme.titleMedium,
              ),
              for (final note in notes) ...<Widget>[
                const SizedBox(height: 8),
                Text(note, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 8),
              Text(
                nextDue == null
                    ? '沒有排定的下次複習。'
                    : '下一張預計在 ${formatDateTime(nextDue)} 之後到期。',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (hasMore)
                    FilledButton(
                      onPressed: _restart,
                      child: const Text('再來一輪'),
                    ),
                  if (canAddExtra)
                    FilledButton.tonal(
                      onPressed: _addExtraNewWords,
                      child: const Text(
                        '今天再多學 ${AppState.extraNewWordsStep} 個',
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('回到單字'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
