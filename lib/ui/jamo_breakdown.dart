import 'package:flutter/material.dart';

import '../logic/jamo.dart';
import 'theme.dart';

/// 單字的字母分解：每個音節拆成 子音 + 母音（+ 尾音）。
///
/// 例：하늘 → ㅎ+ㅏ  ㄴ+ㅡ+ㄹ。
/// 音節開頭不發音的 ㅇ 以淡色顯示。
class JamoBreakdown extends StatelessWidget {
  const JamoBreakdown({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.onSurfaceVariant;
    final faint = base.withAlpha(90);

    final words = decomposeText(text);
    if (words.isEmpty) {
      return const SizedBox.shrink();
    }

    final spans = <InlineSpan>[];
    for (var w = 0; w < words.length; w++) {
      if (w > 0) {
        spans.add(TextSpan(text: '   ｜   ', style: TextStyle(color: faint)));
      }
      final syllables = words[w];
      for (var s = 0; s < syllables.length; s++) {
        if (s > 0) {
          spans.add(const TextSpan(text: '  '));
        }
        final parts = syllables[s];
        for (var i = 0; i < parts.letters.length; i++) {
          if (i > 0) {
            spans.add(TextSpan(text: '+', style: TextStyle(color: faint)));
          }
          final silent = i == 0 && parts.hasSilentInitial;
          spans.add(TextSpan(
            text: parts.letters[i],
            style: TextStyle(color: silent ? faint : base),
          ));
        }
      }
    }

    return Text.rich(
      TextSpan(style: hangulStyle(fontSize, color: base), children: spans),
      textAlign: textAlign,
    );
  }
}
