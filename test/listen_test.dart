import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/lessons.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/logic/quiz_generator.dart';

void main() {
  group('聽音辨字', () {
    test('每個音節都能出題：4 個不重複的選項、正確答案就是朗讀的音節', () {
      final generator = QuizGenerator(random: Random(7));
      for (final syllable in Catalog.syllables) {
        final question = generator.build(
          QuizSeed(QuizKind.listenSyllable, syllable.id),
        );
        expect(question, isNotNull, reason: syllable.id);
        expect(question!.options.length, 4, reason: syllable.id);
        expect(question.options.toSet().length, 4, reason: syllable.id);
        expect(question.correctAnswer, syllable.hangul, reason: syllable.id);
        expect(question.speakText, syllable.hangul, reason: syllable.id);
        expect(question.stimulus, isNull, reason: '不能把答案直接印在題目上');
      }
    });

    test('干擾選項只用已教過的基本字母，不含送氣音與濃音', () {
      const allowed = <String>{
        'ㅇ', 'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅈ', 'ㅎ',
      };
      final generator = QuizGenerator(random: Random(3));
      for (final syllable in Catalog.syllables.where(
        (s) => allowed.contains(s.initial.jamo),
      )) {
        final question = generator.build(
          QuizSeed(QuizKind.listenSyllable, syllable.id),
        )!;
        for (final option in question.options) {
          final found = Catalog.syllables.firstWhere((s) => s.hangul == option);
          expect(allowed.contains(found.initial.jamo), isTrue,
              reason: '${syllable.id} 的選項 $option');
        }
      }
    });

    test('前三堂字母課的課後測驗都包含聽音辨字', () {
      // 送氣音／濃音、複合母音、收尾音三堂沒有對應的「音節」教材資料，
      // 且電腦語音不易分辨這些音，所以它們的課後測驗改用單字題。
      for (final lesson in Lessons.hangul.take(3)) {
        expect(
          lesson.quizSeeds.any((s) => s.kind == QuizKind.listenSyllable),
          isTrue,
          reason: lesson.id,
        );
      }
    });
  });
}
