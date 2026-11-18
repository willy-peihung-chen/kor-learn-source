import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/audio/speech_service.dart';
import 'package:hangul_app/data/words.dart';

Map<String, String> voice(String name, String locale) =>
    <String, String>{'name': name, 'locale': locale};

void main() {
  group('pickKoreanVoice', () {
    test('優先選神經語音（Natural / Online）', () {
      final picked = pickKoreanVoice(<Map<String, String>>[
        voice('Microsoft Heami - Korean (Korea)', 'ko-KR'),
        voice('Microsoft SunHi Online (Natural) - Korean (Korea)', 'ko-KR'),
        voice('Microsoft David - English (United States)', 'en-US'),
      ]);
      expect(picked?['name'], contains('SunHi'));
    });

    test('沒有神經語音時，選 Google 韓文語音', () {
      final picked = pickKoreanVoice(<Map<String, String>>[
        voice('Some Korean Voice', 'ko-KR'),
        voice('Google 한국어', 'ko-KR'),
      ]);
      expect(picked?['name'], 'Google 한국어');
    });

    test('只有一般韓文語音時就用它', () {
      final picked = pickKoreanVoice(<Map<String, String>>[
        voice('Microsoft Heami - Korean (Korea)', 'ko-KR'),
      ]);
      expect(picked?['name'], contains('Heami'));
    });

    test('底線格式的地區（ko_KR）也算韓文', () {
      final picked = pickKoreanVoice(<Map<String, String>>[
        voice('ko-kr-x-abc-local', 'ko_KR'),
      ]);
      expect(picked, isNotNull);
    });

    test('沒有任何韓文語音時回傳 null', () {
      final picked = pickKoreanVoice(<Map<String, String>>[
        voice('Microsoft David - English (United States)', 'en-US'),
        voice('Microsoft Hanhan - Chinese (Taiwan)', 'zh-TW'),
      ]);
      expect(picked, isNull);
    });

    test('空清單回傳 null', () {
      expect(pickKoreanVoice(<Map<String, String>>[]), isNull);
    });
  });

  group('normalizeVoices', () {
    test('把各平台回傳的 Map 轉成字串對照表，略過不是 Map 的項目', () {
      final result = normalizeVoices(<dynamic>[
        <Object?, Object?>{'name': 'Google 한국어', 'locale': 'ko-KR'},
        <String, dynamic>{'name': 'x'},
        'not a map',
        42,
      ]);
      expect(result.length, 2);
      expect(result.first, <String, String>{
        'name': 'Google 한국어',
        'locale': 'ko-KR',
      });
      expect(result.last['locale'], '');
    });

    test('不是清單時回傳空清單', () {
      expect(normalizeVoices(null), isEmpty);
      expect(normalizeVoices('x'), isEmpty);
    });
  });

  group('朗讀的內容', () {
    test('所有單字與例句都是非空的韓文字串，可以交給語音服務', () {
      final hangul = RegExp(r'[가-힣]');
      for (final word in vocabularyWords) {
        expect(hangul.hasMatch(word.hangul), isTrue, reason: word.hangul);
        expect(hangul.hasMatch(word.example), isTrue, reason: word.example);
      }
    });
  });

  group('NoopSpeechService', () {
    test('不發聲，並回報無法朗讀', () async {
      const service = NoopSpeechService();
      expect(await service.speak('아이'), isFalse);
    });
  });
}
