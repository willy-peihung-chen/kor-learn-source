import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/ui/quiz_page.dart';

void main() {
  group('選項的朗讀喇叭', () {
    test('單字→中文：選項是中文，即使括號裡夾著韓文也不放喇叭', () {
      expect(
        showsOptionSpeaker(QuizKind.wordMeaning, '名字（對長輩的敬語為 성함）'),
        isFalse,
      );
      expect(showsOptionSpeaker(QuizKind.wordMeaning, '咖啡'), isFalse);
    });

    test('聽音辨字：不放喇叭（避免逐一比對聲音）', () {
      expect(showsOptionSpeaker(QuizKind.listenSyllable, '가'), isFalse);
    });

    test('選項是韓文的題型：放喇叭', () {
      expect(showsOptionSpeaker(QuizKind.meaningWord, '사과'), isTrue);
      expect(showsOptionSpeaker(QuizKind.syllableFromRoman, '가'), isTrue);
      expect(showsOptionSpeaker(QuizKind.grammarCloze, '는'), isTrue);
      expect(showsOptionSpeaker(QuizKind.letterName, '기역'), isTrue);
    });

    test('選項沒有韓文：不放喇叭', () {
      expect(showsOptionSpeaker(QuizKind.letterRoman, 'g/k'), isFalse);
      expect(showsOptionSpeaker(QuizKind.syllableRoman, 'ga'), isFalse);
    });
  });
}
