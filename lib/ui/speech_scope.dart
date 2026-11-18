import 'package:flutter/widgets.dart';

import '../audio/speech_service.dart';

/// 把 [SpeechService] 提供給整個 widget 樹。
class SpeechScope extends InheritedWidget {
  const SpeechScope({super.key, required this.service, required super.child});

  final SpeechService service;

  /// 找不到時回傳不發聲的實作，不會讓畫面出錯。
  static SpeechService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SpeechScope>();
    return scope?.service ?? const NoopSpeechService();
  }

  @override
  bool updateShouldNotify(SpeechScope oldWidget) =>
      service != oldWidget.service;
}
