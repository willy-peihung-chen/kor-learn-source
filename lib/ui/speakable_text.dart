import 'package:flutter/material.dart';

import '../util/korean_runs.dart';
import 'speak_button.dart';

/// 說明文字：每段韓文後面自動加一個小喇叭，點一下就朗讀那段韓文。
/// 沒有韓文時就是一般的 [Text]。
class SpeakableText extends StatelessWidget {
  const SpeakableText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final runs = splitKoreanRuns(text);
    if (!runs.any((r) => r.isKorean)) {
      return Text(text, style: style);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          for (final run in runs) ...<InlineSpan>[
            TextSpan(text: run.text),
            if (run.isKorean)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _InlineSpeaker(text: run.text),
              ),
          ],
        ],
      ),
    );
  }
}

class _InlineSpeaker extends StatelessWidget {
  const _InlineSpeaker({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '朗讀這段韓文',
      child: InkResponse(
        radius: 16,
        onTap: () => speakText(context, text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Icon(
            Icons.volume_up_outlined,
            size: 17,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
