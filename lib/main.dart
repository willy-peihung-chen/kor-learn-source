import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'audio/platform_speech.dart';
import 'state/app_state.dart';
import 'storage/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final state = await AppState.load(SharedPrefsProgressRepository(prefs));
  runApp(HangulApp(state: state, speech: createPlatformSpeechService()));
}
