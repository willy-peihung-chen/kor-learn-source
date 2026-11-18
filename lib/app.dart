import 'package:flutter/material.dart';

import 'audio/speech_service.dart';
import 'state/app_state.dart';
import 'ui/app_scope.dart';
import 'ui/app_shell.dart';
import 'ui/speech_scope.dart';
import 'ui/theme.dart';

class HangulApp extends StatelessWidget {
  const HangulApp({
    super.key,
    required this.state,
    this.speech = const NoopSpeechService(),
  });

  final AppState state;
  final SpeechService speech;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: SpeechScope(
        service: speech,
        child: MaterialApp(
          title: '韓文自學',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const AppShell(),
        ),
      ),
    );
  }
}
