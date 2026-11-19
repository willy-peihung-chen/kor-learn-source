import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'audio_key.dart';
import 'speech_service.dart';

SpeechService createPlatformSpeechService() => WebSpeechService();

/// 網頁版朗讀。
///
/// 1. 先找預先做好的語音檔（`audio/<key>.mp3`，由 tool/make_audio.py 用 MeloTTS 產生）：
///    有就播放語音檔，每支手機聽到的都一樣。
/// 2. 沒有語音檔的句子，才用瀏覽器內建的語音合成（品質依裝置而定）。
///
/// iPhone（Safari）只允許在「使用者點擊的當下」開始播放或朗讀，
/// 所以語音檔清單與語音清單都在啟動時先準備好，點擊後不等待、直接播放。
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
    unawaited(_loadAudioIndex());
  }

  /// 瀏覽器語音的語速：1.0 為正常，學習用稍微放慢。
  static const double _rate = 0.85;

  /// 有語音檔的 key（見 [audioKey]）；清單還沒載入時是空的。
  final Set<String> _audioKeys = <String>{};

  /// 重複使用同一個播放器：iPhone 上第一次在點擊中播放後，之後播放比較順。
  web.HTMLAudioElement? _player;

  /// 每次朗讀或停止就加一；舊的播放失敗回報時，用它判斷是不是已經過時。
  int _generation = 0;

  /// 挑好的韓文語音；null 代表還沒挑到（交給瀏覽器用預設的韓文語音）。
  web.SpeechSynthesisVoice? _voice;

  /// 語音清單是否已經有內容。
  bool _voicesLoaded = false;

  /// 語音清單裡是否有韓文語音。
  bool _hasKorean = true;

  Future<void> _loadAudioIndex() async {
    try {
      final response = await web.window.fetch('audio/index.json'.toJS).toDart;
      if (!response.ok) {
        return; // 還沒產生語音檔：全部用瀏覽器語音。
      }
      final body = (await response.text().toDart).toDart;
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['files'] is List) {
        _audioKeys.addAll((decoded['files'] as List).whereType<String>());
      }
    } catch (error) {
      debugPrint('讀取語音檔清單失敗：$error');
    }
  }

  void _refreshVoices(web.SpeechSynthesis synth) {
    final voices = synth.getVoices().toDart;
    if (voices.isEmpty) {
      return;
    }
    _voicesLoaded = true;
    final picked = pickKoreanVoice(<Map<String, String>>[
      for (final v in voices)
        <String, String>{'name': v.name, 'locale': v.lang, 'uri': v.voiceURI},
    ]);
    _hasKorean = picked != null;
    _voice = null;
    if (picked == null) {
      return;
    }
    for (final v in voices) {
      if (v.voiceURI == picked['uri']) {
        _voice = v;
        break;
      }
    }
  }

  @override
  Future<bool> speak(String text) async {
    final key = audioKey(text);
    if (_audioKeys.contains(key)) {
      _playFile(key, text);
      return true;
    }
    return _speakWithBrowser(text);
  }

  /// 播放預先做好的語音檔；播放失敗（例如檔案不見）就改用瀏覽器語音。
  void _playFile(String key, String text) {
    try {
      final generation = ++_generation;
      web.window.speechSynthesis.cancel();
      final player = _player ??= web.HTMLAudioElement();
      player.pause();
      player.src = 'audio/$key.mp3';
      player.play().toDart.then(
        (_) {},
        onError: (Object error) {
          // 換句子或按停止時，舊的播放會被中斷而回報失敗：那不是真的失敗，忽略。
          if (generation != _generation) {
            return;
          }
          debugPrint('語音檔播放失敗，改用瀏覽器語音：$error');
          _speakWithBrowser(text);
        },
      );
    } catch (error) {
      debugPrint('語音檔播放失敗，改用瀏覽器語音：$error');
      _speakWithBrowser(text);
    }
  }

  Future<bool> _speakWithBrowser(String text) async {
    try {
      _generation++;
      _player?.pause();
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
      _generation++;
      _player?.pause();
      web.window.speechSynthesis.cancel();
    } catch (_) {
      // 忽略：停止失敗不影響使用。
    }
  }
}
