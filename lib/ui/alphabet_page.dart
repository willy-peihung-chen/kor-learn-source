import 'package:flutter/material.dart';

import '../data/alphabet_chart.dart';
import '../logic/jamo.dart';
import 'speak_button.dart';
import 'theme.dart';
import 'widgets.dart';

void openAlphabet(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AlphabetPage()),
  );
}

/// 韓文四十音字母表：把 21 個母音與 19 個子音依相似程度分組排開，點字母就會出聲。
class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  ChartLetter? _selected;

  void _select(ChartLetter letter) {
    setState(() => _selected = letter);
    speakText(context, letter.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('韓文字母表')),
      body: SafeArea(
        child: PageBody(
          children: <Widget>[
            Text(
              '21 個母音 + 19 個子音。點任何一個字母就會念出它的名稱；'
              '羅馬字只是輔助標記，不等於實際發音，請以朗讀為準。',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            _SelectedPanel(letter: _selected),
            const SizedBox(height: 20),
            Text('母音', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final group in vowelGroups) ...<Widget>[
              Text(group.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                group.hint,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              _LetterWrap(
                letters: group.letters,
                columns: 6,
                selected: _selected,
                onTap: _select,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 4),
            Text('子音', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '同一橫排是一組形狀相近的字母。送氣音多半是在平音上多加一劃'
              '（ㄱ→ㅋ、ㄷ→ㅌ、ㅈ→ㅊ），濃音是把平音寫兩次（ㄱ→ㄲ）。'
              '三種聲音的差別要用耳朵分辨，請多按幾次聽。',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 10),
            _ConsonantTable(selected: _selected, onTap: _select),
            const SizedBox(height: 16),
            Text('其他子音', style: theme.textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(
              'ㅇ 在音節開頭不發音，只是佔位（아）；放在音節結尾才發 ng 的音。',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 8),
            _LetterWrap(
              letters: otherConsonants,
              columns: 5,
              selected: _selected,
              onTap: _select,
            ),
          ],
        ),
      ),
    );
  }
}

/// 目前選到的字母：放大顯示，並提供「聽名稱」與「聽音節」。
class _SelectedPanel extends StatelessWidget {
  const _SelectedPanel({required this.letter});

  final ChartLetter? letter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final current = letter;

    if (current == null) {
      return SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: <Widget>[
            Icon(Icons.touch_app_outlined, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '點下面的字母，這裡會顯示它的名稱，並可以再聽音節。',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ),
          ],
        ),
      );
    }

    // 母音：加上不發音的 ㅇ 組成音節（ㅏ → 아）；子音：搭配 ㅏ（ㄱ → 가）。
    final sample = current.isVowel
        ? composeSyllable('ㅇ', current.jamo)
        : composeSyllable(current.jamo, 'ㅏ');

    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Center(child: Text(current.jamo, style: hangulStyle(56))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  current.roman.isEmpty
                      ? '名稱：${current.name}'
                      : '名稱：${current.name}　羅馬字：${current.roman}',
                  style: hangulStyle(16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => speakText(context, current.name),
                      icon: const Icon(Icons.volume_up_outlined, size: 18),
                      label: Text('名稱 ${current.name}'),
                    ),
                    if (sample != null && sample != current.name)
                      OutlinedButton.icon(
                        onPressed: () => speakText(context, sample),
                        icon: const Icon(Icons.volume_up_outlined, size: 18),
                        label: Text('音節 $sample'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 一排排整齊的字母格子：所有格子等寬，所以上下行的欄位會對齊
/// （例如 ㅏ 的正下方就是 ㅑ）。
class _LetterWrap extends StatelessWidget {
  const _LetterWrap({
    required this.letters,
    required this.columns,
    required this.selected,
    required this.onTap,
  });

  final List<ChartLetter> letters;

  /// 欄位數（決定格子寬度，超過會換行）。
  final int columns;
  final ChartLetter? selected;
  final ValueChanged<ChartLetter> onTap;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - gap * (columns - 1)) / columns)
            .clamp(40.0, 84.0);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final letter in letters)
              _LetterTile(
                letter: letter,
                width: width,
                selected: identical(letter, selected),
                onTap: onTap,
              ),
          ],
        );
      },
    );
  }
}

/// 子音表：三欄（平音、送氣音、濃音），每列一組。
class _ConsonantTable extends StatelessWidget {
  const _ConsonantTable({required this.selected, required this.onTap});

  final ChartLetter? selected;
  final ValueChanged<ChartLetter> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    const gap = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            ((constraints.maxWidth - gap * 2) / 3).clamp(40.0, 120.0);

        Widget cell(ChartLetter? letter) => SizedBox(
              width: width,
              child: letter == null
                  ? null
                  : _LetterTile(
                      letter: letter,
                      width: width,
                      selected: identical(letter, selected),
                      onTap: onTap,
                    ),
            );

        Widget header(String text) => SizedBox(
              width: width,
              child: Center(
                child: Text(
                  text,
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                header('平音'),
                const SizedBox(width: gap),
                header('送氣音'),
                const SizedBox(width: gap),
                header('濃音'),
              ],
            ),
            const SizedBox(height: 6),
            for (final row in consonantRows)
              Padding(
                padding: const EdgeInsets.only(bottom: gap),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    cell(row.plain),
                    const SizedBox(width: gap),
                    cell(row.aspirated),
                    const SizedBox(width: gap),
                    cell(row.tense),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final ChartLetter letter;
  final double width;
  final bool selected;
  final ValueChanged<ChartLetter> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      label: '${letter.jamo}，${letter.name}',
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(letter),
          child: SizedBox(
            width: width,
            height: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(letter.jamo, style: hangulStyle(28, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  letter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hangulStyle(11, color: muted),
                ),
                Text(
                  letter.roman.isEmpty ? '—' : letter.roman,
                  maxLines: 1,
                  style: hangulStyle(10, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
