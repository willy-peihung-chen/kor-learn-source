import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../logic/srs.dart';
import '../util/format.dart';
import 'app_scope.dart';
import 'speak_button.dart';
import 'theme.dart';
import 'widgets.dart';

/// 開始單字複習。[topic] 為 null 代表所有主題中到期與新的單字。
void openReview(BuildContext context, {WordTopic? topic}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ReviewSessionPage(topic: topic),
    ),
  );
}

/// 單字複習：先看韓文，點一下顯示意思與例句，再自評熟悉程度。
class ReviewSessionPage extends StatefulWidget {
  const ReviewSessionPage({super.key, this.topic});

  final WordTopic? topic;

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  List<String> _queue = <String>[];
  bool _initialized = false;
  int _position = 0;
  int _reviewed = 0;
  bool _revealed = false;

  /// 不為 null 代表正在回頭查看已評過的卡片（只能看，不能重評）。
  int? _browse;

  /// 本輪每張卡片（以位置為鍵）已評的結果。
  final Map<int, ReviewRating> _rated = <int, ReviewRating>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _queue = AppScope.of(context).buildReviewQueue(topicId: widget.topic?.id);
      _initialized = true;
    }
  }

  void _rate(ReviewRating rating) {
    final state = AppScope.of(context);
    state.rateWord(_queue[_position], rating);
    setState(() {
      _rated[_position] = rating;
      _position++;
      _reviewed++;
      _revealed = false;
    });
  }

  void _restart() {
    final state = AppScope.of(context);
    setState(() {
      _queue = state.buildReviewQueue(topicId: widget.topic?.id);
      _position = 0;
      _reviewed = 0;
      _revealed = false;
      _browse = null;
      _rated.clear();
    });
  }

  void _goPrevious() {
    final current = _browse ?? _position;
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
    setState(() => _browse = current + 1 >= _position ? null : current + 1);
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

    if (_position >= _queue.length) {
      final nextDue = state.nextDueAt;
      final hasMore =
          state.buildReviewQueue(topicId: widget.topic?.id).isNotEmpty;
      return PageBody(
        children: <Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _reviewed > 0
                      ? '本輪完成，共複習 $_reviewed 張。'
                      : (widget.topic == null
                          ? '目前沒有需要複習的單字。'
                          : '這個主題目前沒有需要複習的單字。'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  nextDue == null
                      ? '沒有排定的下次複習。'
                      : '下一張預計在 ${formatDateTime(nextDue)} 之後到期。',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    if (hasMore) ...<Widget>[
                      FilledButton(
                        onPressed: _restart,
                        child: const Text('再來一輪'),
                      ),
                      const SizedBox(width: 8),
                    ],
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

    final browsing = _browse != null;
    final index = _browse ?? _position;
    final showAnswer = browsing || _revealed;
    final word = Catalog.wordById(_queue[index])!;
    final isNew = state.isNewWord(word.id);
    final topic = Catalog.topicOfWord(word.id);
    final ratedAs = _rated[index];

    return PageBody(
      children: <Widget>[
        Text(
          '第 ${index + 1} / ${_queue.length} 張・'
          '${browsing ? '回頭查看（已評為「${ratedAs?.label ?? ''}」）' : (isNew ? '新單字' : '複習')}'
          '${topic == null ? '' : '・${topic.title}'}',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
                if (word.hanja != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    '漢字詞：${word.hanja}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  word.isPlainStyleExample ? '例句（半語，非敬語）' : '例句（敬語）',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(child: Text(word.example, style: hangulStyle(20))),
                    const SizedBox(width: 4),
                    SpeakButton(
                      text: word.example,
                      tooltip: '朗讀例句',
                      iconSize: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '中文翻譯',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 2),
                Text(
                  word.exampleMeaning,
                  style: theme.textTheme.bodyLarge,
                ),
                if (word.note != null) ...<Widget>[
                  const SizedBox(height: 20),
                  Text(
                    '用法說明',
                    style: theme.textTheme.labelMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (browsing)
          Text(
            '這張已經評過，只能查看；回到目前進度後繼續評下一張。',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          )
        else if (_revealed)
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
          )
        else
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: const Text('顯示意思'),
          ),
        if (_position > 0 || browsing) ...<Widget>[
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
                    _browse != null && _browse! + 1 >= _position
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
}
