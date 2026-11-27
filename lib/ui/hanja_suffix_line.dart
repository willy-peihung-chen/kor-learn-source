import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../data/hanja_suffixes.dart';
import 'theme.dart';

/// 漢字詞的字尾提示：「字尾 -실（室）＝房間」與同字尾的其他單字；
/// 字尾有同音不同字時多一行提醒。不是常見字尾時不顯示任何東西。
/// [compact] 用在單字列表：只顯示「字尾 -실（室）＝房間」一行（同類的字列表上就看得到）。
class HanjaSuffixLine extends StatelessWidget {
  const HanjaSuffixLine({
    super.key,
    required this.word,
    this.center = false,
    this.compact = false,
  });

  final WordItem word;

  /// 複習卡置中顯示；辭典、單字列表靠左。
  final bool center;

  /// 單字列表用的精簡版。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hint = hanjaSuffixHintOf(word, Catalog.words);
    if (hint == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final align = center ? TextAlign.center : TextAlign.start;
    final suffix = hint.suffix;
    final siblings =
        compact ? '' : hint.siblings.map((w) => w.hangul).join('、');
    final sameSound = compact
        ? ''
        : hint.sameSound
            .map((s) =>
                '${s.suffix.hangul}（${s.suffix.hanja}）＝${s.suffix.meaning}'
                '${s.example == null ? '' : '，如 ${s.example!.hangul}'}')
            .join('；');
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              style: style,
              children: <InlineSpan>[
                const TextSpan(text: '字尾 '),
                TextSpan(
                  text: '-${suffix.hangul}（${suffix.hanja}）',
                  style: hangulStyle(14),
                ),
                TextSpan(text: '＝${suffix.meaning}'),
                if (siblings.isNotEmpty) ...<InlineSpan>[
                  const TextSpan(text: '；同類：'),
                  TextSpan(text: siblings, style: hangulStyle(14)),
                ],
              ],
            ),
            textAlign: align,
          ),
          if (sameSound.isNotEmpty)
            Text(
              '同音不同字：$sameSound',
              style: style,
              textAlign: align,
            ),
        ],
      ),
    );
  }
}
