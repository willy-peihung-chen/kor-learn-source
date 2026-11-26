import 'package:flutter/material.dart';

import '../data/content_models.dart';
import '../data/haeyo_forms.dart';
import 'speak_button.dart';
import 'theme.dart';

/// 動詞、形容詞的해요體現在式（例：비싸다 → 비싸요）；其他字回傳 null。
String? haeyoFormOf(WordItem word) => haeyoForms[word.id];

/// 「說話時（敬語）：비싸요」一行，附朗讀按鈕；不是動詞、形容詞時不顯示任何東西。
/// 單字卡上的字是辭典形（字尾是 다），說話時要去掉 다 接語尾，這一行讓兩者對得起來。
/// 少數字（例如 잘생기다）描述現在的狀態也用過去式，下面會多一行提醒。
class HaeyoFormLine extends StatelessWidget {
  const HaeyoFormLine({super.key, required this.word, this.center = false});

  final WordItem word;

  /// 複習卡置中顯示；單字列表、辭典靠左。
  final bool center;

  @override
  Widget build(BuildContext context) {
    final form = haeyoFormOf(word);
    if (form == null) {
      return const SizedBox.shrink();
    }
    final hint = haeyoHints[word.id];
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final line = Row(
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      children: <Widget>[
        Text(
          '說話時（敬語）：',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        Flexible(child: Text(form, style: hangulStyle(15))),
        SpeakButton(text: form, tooltip: '朗讀$form', iconSize: 18),
      ],
    );
    if (hint == null) {
      return line;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        line,
        Text(
          '（$hint）',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
          textAlign: center ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
  }
}
