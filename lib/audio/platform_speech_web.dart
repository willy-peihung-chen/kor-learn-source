import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'speech_service.dart';

SpeechService createPlatformSpeechService() => WebSpeechService();

/// 網頁版朗讀：直接使用瀏覽器內建的語音合成，不經過 flutter_tts。
///
/// 這是機器合成語音，不是真人錄音；使用哪個語音由瀏覽器與系統決定，
/// 這裡只是在可用的韓文語音中挑最自然的一個。
///
/// iPhone（Safari）只允許在「使用者點擊的當下」開始朗讀，
/// 所以語音清單在啟動時先準備好，點擊後不等待、直接呼叫 speak。
class WebSpeechService implements SpeechService {
  WebSpeechService() {
    try {
      final synth = web.window.speechSynthesis;
      _refreshVoices(synth);
      // 有些瀏覽器的語音清單是之後才載入完成，載入後再挑一次。
      synth.onvoiceschanged = ((web.Event _) => _refreshVoices(synth)).toJS;
    } catch (error) {
      debugPrint('網頁語音初始化失敗：$error');
    }
  }

  /// 語速：1.0 為正常，學習用稍微放慢。
  static const double _rate = 0.85;

  /// 挑好的韓文語音；null 代表還沒挑到（交給瀏覽器用預設的韓文語音）。
  web.SpeechSynthesisVoice? _voice;

  /// 語音清單是否已經有內容。
  bool _voicesLoaded = false;

  /// 語音清單裡是否有韓文語音。
  bool _hasKorean = true;

  void _refreshVoices(web.SpeechSynthesis synth) {
    final voices = synth.getVoices().toDart;
    if (voices.isEmpty) {
      return;
    }
    _voicesLoaded = true;
    final picked = pickKoreanVoice(<Map<String, String>>[
      for (final v in voices) <String, String>{'name': v.name, 'locale': v.lang},
    ]);
    _hasKorean = picked != null;
    _voice = null;
    if (picked == null) {
      return;
    }
    for (final v in voices) {
      if (v.name == picked['name'] && v.lang == picked['locale']) {
        _voice = v;
        break;
      }
    }
  }

  @override
  Future<bool> speak(String text) async {
    try {
      final synth = web.window.speechSynthesis;
      if (!_voicesLoaded) {
        _refreshVoices(synth);
      }
      // 清單已載入、卻沒有任何韓文語音，才判定無法朗讀。
      if (_voicesLoaded && !_hasKorean) {
        return false;
      }

      // 正在念的話先停掉；停止之後稍等一下再念，避免聲音被吃掉。
      // 沒有在念的時候不等待，讓 speak 在點擊的當下執行（iPhone 需要）。
      if (synth.speaking || synth.pending) {
        synth.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }

      final voice = _voice;
      final utterance = web.SpeechSynthesisUtterance(text)
        ..lang = voice?.lang ?? 'ko-KR'
        ..rate = _rate;
      if (voice != null) {
        utterance.voice = voice;
      }
      synth.speak(utterance);
      return true;
    } catch (error) {
      debugPrint('網頁朗讀失敗：$error');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      web.window.speechSynthesis.cancel();
    } catch (_) {
      // 忽略：停止失敗不影響使用。
    }
  }
}
