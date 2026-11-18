import 'package:flutter/material.dart';

import 'speech_scope.dart';

/// 朗讀按鈕：點一下用韓文語音念出 [text]；裝置無法朗讀時顯示提示。
class SpeakButton extends StatelessWidget {
  const SpeakButton({
    super.key,
    required this.text,
    required this.tooltip,
    this.iconSize = 26,
  });

  final String text;
  final String tooltip;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: iconSize,
      icon: const Icon(Icons.volume_up_outlined),
      onPressed: () => speakText(context, text),
    );
  }
}

/// 朗讀 [text]；裝置無法朗讀時顯示提示，而不是默默沒聲音。
/// 按鈕、可點的字母與單字列都共用這個函式。
Future<void> speakText(BuildContext context, String text) async {
  final speech = SpeechScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ok = await speech.speak(text);
  if (!ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            '這台裝置目前無法朗讀韓文：找不到韓文語音。'
            'Windows 請到「設定 → 時間與語言 → 語言」安裝韓文語言包，或改用 Edge 瀏覽器；'
            'iPhone 請到「設定 → 輔助使用 → 朗讀內容 → 聲音」確認有韓文語音。',
          ),
          duration: Duration(seconds: 6),
        ),
      );
  }
}
