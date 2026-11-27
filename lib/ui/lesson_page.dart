import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../data/lessons.dart';
import '../state/app_state.dart';
import 'app_scope.dart';
import 'quiz_page.dart';
import 'speak_button.dart';
import 'speakable_text.dart';
import 'theme.dart';
import 'widgets.dart';

void openLesson(BuildContext context, Lesson lesson) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => LessonPage(lesson: lesson)),
  );
}

/// 課程內容：一次一張卡片，依序學習；看完最後一張即完成本課。
class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _index = 0;
  bool _finished = false;

  void _next(AppState state, int index) {
    // 連按兩下時第二下不算（避免跳過一張或重複完成本課）。
    if (_finished || index != _index) {
      return;
    }
    final cards = widget.lesson.cards;
    state.markLearned(cards[_index].id);
    if (_index == cards.length - 1) {
      state.completeLesson(widget.lesson);
      setState(() => _finished = true);
    } else {
      setState(() => _index++);
    }
  }

  void _previous() {
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SafeArea(
        child: _finished ? _buildDone(context, state) : _buildCard(context, state),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppState state) {
    final cards = widget.lesson.cards;
    final card = cards[_index];
    final isLast = _index == cards.length - 1;
    // 在畫面建立時記下卡號，按鈕用這個值，連按時第二下會被擋掉。
    final shownIndex = _index;

    return Column(
      children: <Widget>[
        LinearProgressIndicator(value: (_index + 1) / cards.length),
        Expanded(
          child: PageBody(
            // 換卡時重新建立捲動區，從頂端開始顯示。
            key: ValueKey<int>(_index),
            children: <Widget>[
              Text(
                '${_index + 1} / ${cards.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              LessonCardView(card: card),
            ],
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: <Widget>[
                  OutlinedButton(
                    onPressed: _index == 0 ? null : _previous,
                    child: const Text('上一個'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _next(state, shownIndex),
                      child: Text(isLast ? '完成本課' : '下一個'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_circle, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                '已完成本課',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.lesson.title,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final questions =
                      state.quiz.fromSeeds(widget.lesson.quizSeeds, count: 8);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizSessionPage(
                        title: '${widget.lesson.title}・小測驗',
                        questions: questions,
                      ),
                    ),
                  );
                },
                child: const Text('做課後小測驗'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('回到課程列表'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 單張課程卡片的內容。
class LessonCardView extends StatelessWidget {
  const LessonCardView({super.key, required this.card});

  final LessonCard card;

  @override
  Widget build(BuildContext context) {
    switch (card.kind) {
      case LessonCardKind.letter:
        return _letterCard(context, card.letter!);
      case LessonCardKind.syllable:
        return _syllableCard(context, card.syllable!);
      case LessonCardKind.concept:
        return _conceptCard(context);
      case LessonCardKind.grammar:
        return _grammarCard(context, card.point!);
      case LessonCardKind.sound:
        return _soundCard(context);
    }
  }

  Widget _letterCard(BuildContext context, HangulLetter letter) {
    final theme = Theme.of(context);
    final isConsonant = letter.type == LetterType.consonant;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text(letter.jamo, style: hangulStyle(96))),
          const SizedBox(height: 16),
          _InfoRow(label: '字母名稱', value: letter.name),
          _InfoRow(
            label: isConsonant ? '羅馬字標記（音節開頭）' : '羅馬字標記',
            value: letter.hasRoman ? letter.roman : '（無）',
          ),
          if (letter.note != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              '補充說明',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            SpeakableText(letter.note!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          const _SoundReminder(),
        ],
      ),
    );
  }

  Widget _syllableCard(BuildContext context, Syllable syllable) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text(syllable.hangul, style: hangulStyle(96))),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${syllable.initial.jamo} + ${syllable.vowel.jamo} = ${syllable.hangul}',
              style: hangulStyle(24),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: '羅馬字標記',
            value: syllable.roman.isEmpty ? '（無）' : syllable.roman,
          ),
          const SizedBox(height: 16),
          const _SoundReminder(),
        ],
      ),
    );
  }

  Widget _grammarCard(BuildContext context, GrammarPoint point) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(point.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SpeakableText(
              point.form,
              style: hangulStyle(16, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          for (final line in point.explanation) ExplanationLine(line),
          const SizedBox(height: 8),
          Text('例句', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final example in point.examples)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            style: hangulStyle(20),
                            children: <InlineSpan>[
                              TextSpan(text: example.before),
                              TextSpan(
                                text: example.answer,
                                style: hangulStyle(
                                  20,
                                  color: scheme.primary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: example.after),
                            ],
                          ),
                        ),
                        Text(
                          example.zh,
                          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  SpeakButton(
                    text: example.plain,
                    tooltip: '朗讀例句',
                    iconSize: 22,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _soundCard(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(card.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final paragraph in card.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SpeakableText(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final item in card.items) _SoundTile(item: item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conceptCard(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(card.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final paragraph in card.paragraphs) ExplanationLine(paragraph),
          if (card.grammarRefs.isNotEmpty) _GrammarRefs(ids: card.grammarRefs),
          if (card.examples.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final s in card.examples) _SyllableChip(syllable: s),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: <Widget>[
          Text(
            '$label：',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: hangulStyle(20, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SoundReminder extends StatelessWidget {
  const _SoundReminder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '提醒：名稱、羅馬字標記與實際發音是三件不同的事。'
      '羅馬字只是輔助標記，實際發音請搭配官方音檔（例如國立國語院）練習。',
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _SyllableChip extends StatelessWidget {
  const _SyllableChip({required this.syllable});

  final Syllable syllable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final roman = syllable.roman.isEmpty ? '' : '（${syllable.roman}）';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${syllable.initial.jamo} + ${syllable.vowel.jamo} → ${syllable.hangul}$roman',
        style: hangulStyle(16),
      ),
    );
  }
}

/// 可以點下去聽聲音的方塊。
class _SoundTile extends StatelessWidget {
  const _SoundTile({required this.item});

  final SoundItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      label: '播放 ${item.speak}',
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => speakText(context, item.speak),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        item.display,
                        style: hangulStyle(
                          item.display.length > 5 ? 20 : 34,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.volume_up_outlined, size: 18, color: muted),
                  ],
                ),
                if (item.caption != null)
                  Text(
                    item.caption!,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                if (item.tag != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.tag!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 說明文字的一行。以「■ 」開頭的是小標題；其他是一般段落（韓文後面有小喇叭）。
class ExplanationLine extends StatelessWidget {
  const ExplanationLine(this.text, {super.key});

  /// 小標題的開頭記號。
  static const String headingMark = '■ ';

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (text.startsWith(headingMark)) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: SpeakableText(
          text.substring(headingMark.length),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SpeakableText(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }
}

/// 說明卡最後的「完整說明在基礎文法的哪一課」。
class _GrammarRefs extends StatelessWidget {
  const _GrammarRefs({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lines = <String>[
      for (final id in ids)
        if ((Catalog.grammarPointById(id), Catalog.grammarLessonOfPoint(id))
            case (final point?, final lesson?))
          '「${point.title}」：基礎文法〈${lesson.title}〉',
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '想看更完整的說明',
            style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SpeakableText(line, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
