import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 朗讀服務的介面。UI 只依賴這個介面；
/// 之後如果有真人錄音檔，可以新增另一個實作（有音檔就播音檔，沒有才用語音合成）。
abstract class SpeechService {
  /// 朗讀韓文 [text]。回傳 false 代表這台裝置目前無法朗讀（例如沒有韓文語音）。
  Future<bool> speak(String text);

  Future<void> stop();
}

/// 不發聲的實作：測試，以及沒有提供語音服務時使用。
class NoopSpeechService implements SpeechService {
  const NoopSpeechService();

  @override
  Future<bool> speak(String text) async => false;

  @override
  Future<void> stop() async {}
}

/// 把各平台回傳的語音清單整理成 name / locale 的字串對照表。
List<Map<String, String>> normalizeVoices(dynamic raw) {
  if (raw is! List) {
    return <Map<String, String>>[];
  }
  final result = <Map<String, String>>[];
  for (final item in raw) {
    if (item is Map) {
      final name = item['name'];
      final locale = item['locale'];
      if (name != null) {
        result.add(<String, String>{
          'name': name.toString(),
          'locale': (locale ?? '').toString(),
        });
      }
    }
  }
  return result;
}

bool isKoreanVoice(Map<String, String> voice) {
  final name = (voice['name'] ?? '').toLowerCase();
  final locale = (voice['locale'] ?? '').toLowerCase();
  return locale.startsWith('ko') ||
      name.contains('korean') ||
      name.contains('한국');
}

int _voiceScore(Map<String, String> voice) {
  final name = (voice['name'] ?? '').toLowerCase();
  final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
  var score = 0;
  // 神經語音（例如 Edge 的 Natural 語音）通常比傳統語音自然。
  if (name.contains('natural')) score += 4;
  if (name.contains('online')) score += 3;
  if (name.contains('neural')) score += 3;
  if (name.contains('google')) score += 2;
  if (name.contains('premium') || name.contains('enhanced')) score += 2;
  if (locale == 'ko-kr') score += 1;
  return score;
}

/// 從語音清單中挑出最適合的韓文語音；沒有韓文語音時回傳 null。
Map<String, String>? pickKoreanVoice(List<Map<String, String>> voices) {
  Map<String, String>? best;
  var bestScore = -1;
  for (final voice in voices) {
    if (!isKoreanVoice(voice)) {
      continue;
    }
    final score = _voiceScore(voice);
    if (score > bestScore) {
      best = voice;
      bestScore = score;
    }
  }
  return best;
}

/// 以裝置內建的語音合成朗讀（網頁版用瀏覽器、Windows 與 Android 用系統語音）。
///
/// 這是機器合成語音，發音正確性沒有經過查核，也不是真人錄音。
class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  Future<bool>? _ready;

  Future<bool> _prepare() async {
    try {
      await _tts.setLanguage('ko-KR');
      // 學習用，稍微放慢。各平台的語速刻度不同：網頁 1.0 為正常，其他平台 0.5 為正常。
      await _tts.setSpeechRate(kIsWeb ? 0.85 : 0.4);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      final voices = normalizeVoices(await _tts.getVoices);
      // 清單是空的（有些瀏覽器還沒載入完）就交給系統用預設的韓文語音；
      // 清單有內容、但沒有任何韓文語音，才判定無法朗讀。
      if (voices.isNotEmpty) {
        final voice = pickKoreanVoice(voices);
        if (voice == null) {
          return false;
        }
        await _tts.setVoice(voice);
      }
      return true;
    } catch (error) {
      debugPrint('語音初始化失敗：$error');
      return false;
    }
  }

  @override
  Future<bool> speak(String text) async {
    final ready = await (_ready ??= _prepare());
    if (!ready) {
      // 不要把失敗存起來：使用者安裝語音後，不必重開 App 就能再試。
      _ready = null;
      return false;
    }
    try {
      await _tts.stop();
      await _tts.speak(text);
      return true;
    } catch (error) {
      debugPrint('朗讀失敗：$error');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // 忽略：停止失敗不影響使用。
    }
  }
}
