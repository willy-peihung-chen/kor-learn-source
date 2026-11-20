import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
import 'package:hangul_app/data/course_options.dart';
import 'package:hangul_app/data/hangul_letters.dart';
import 'package:hangul_app/data/lessons.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/data/words.dart';
import 'package:hangul_app/logic/quiz_generator.dart';

void main() {
  group('教材資料', () {
    test('母音 10 個、子音 14 個', () {
      expect(hangulVowels.length, 10);
      expect(hangulConsonants.length, 14);
    });

    test('音節依 Unicode 公式組合出正確的字', () {
      expect(Catalog.syllableOf('ㄱ', 'ㅏ').hangul, '가');
      expect(Catalog.syllableOf('ㅇ', 'ㅏ').hangul, '아');
      expect(Catalog.syllableOf('ㅎ', 'ㅣ').hangul, '히');
      expect(Catalog.syllableOf('ㅈ', 'ㅗ').hangul, '조');
      expect(Catalog.syllableOf('ㅁ', 'ㅜ').hangul, '무');
      expect(Catalog.syllableOf('ㅋ', 'ㅓ').hangul, '커');
    });

    test('音節的羅馬字標記由字母標記組成', () {
      expect(Catalog.syllableOf('ㄱ', 'ㅏ').roman, 'ga');
      expect(Catalog.syllableOf('ㅇ', 'ㅓ').roman, 'eo');
      expect(Catalog.syllableOf('ㅊ', 'ㅡ').roman, 'cheu');
    });

    test('音節清單排除 ㅈ、ㅊ 搭配 y 母音，且 id 不重複', () {
      expect(Catalog.syllables.length, 14 * 10 - 2 * 4);
      final ids = Catalog.syllables.map((s) => s.id).toSet();
      expect(ids.length, Catalog.syllables.length);
      expect(Catalog.syllableById(Catalog.syllableOf('ㅈ', 'ㅑ').id), isNull);
    });

    test('字母與單字的 id 不重複', () {
      expect(
        Catalog.letters.map((l) => l.id).toSet().length,
        Catalog.letters.length,
      );
      expect(
        vocabularyWords.map((w) => w.id).toSet().length,
        vocabularyWords.length,
      );
    });

    test('字母的索引沒有重複', () {
      final initials =
          hangulConsonants.map((c) => c.index).toSet().length;
      final medials = hangulVowels.map((v) => v.index).toSet().length;
      expect(initials, hangulConsonants.length);
      expect(medials, hangulVowels.length);
    });

    test('字母名稱沒有官方來源，不可標為已查核', () {
      // 字母名稱目前只有二手來源交叉對照，必須全部是待查核。
      for (final letter in Catalog.letters) {
        expect(letter.nameStatus, ContentStatus.pending, reason: letter.jamo);
      }
    });
  });

  group('課程', () {
    test('文法課，卡片 id 在同一課內不重複', () {
      expect(Lessons.hangul.length, 6);
      expect(Lessons.units.length, 31);
      expect(Lessons.casual.length, 1);
      expect(
        Lessons.grammar.length,
        Catalog.grammarLessons.length - Lessons.casual.length,
      );
      expect(
        Lessons.all.length,
        Lessons.hangul.length +
            Lessons.units.length +
            Catalog.grammarLessons.length,
      );
      final ids = <String>[];
      for (final lesson in Lessons.all) {
        ids.addAll(lesson.cards.map((c) => c.id));
      }
      // 同一課內的卡片 id 必須唯一。
      for (final lesson in Lessons.all) {
        final lessonIds = lesson.cards.map((c) => c.id).toList();
        expect(lessonIds.toSet().length, lessonIds.length, reason: lesson.id);
      }
      expect(ids, isNotEmpty);
    });

    test('每個課後測驗的種子都能產生題目', () {
      final generator = QuizGenerator(random: Random(1));
      for (final lesson in Lessons.all) {
        expect(lesson.quizSeeds, isNotEmpty, reason: lesson.id);
        for (final seed in lesson.quizSeeds) {
          expect(
            generator.build(seed),
            isNotNull,
            reason: '${lesson.id} ${seed.key}',
          );
        }
      }
    });

    test('發音卡朗讀的都是完整音節或詞，不是單獨的字母（電腦語音念單獨字母不準）', () {
      final bareJamo = RegExp(r'[\u3131-\u3163]');
      var count = 0;
      for (final lesson in Lessons.all) {
        for (final card in lesson.cards) {
          for (final item in card.items) {
            count++;
            expect(item.speak, isNotEmpty, reason: card.id);
            expect(bareJamo.hasMatch(item.speak), isFalse,
                reason: '${card.id} ${item.speak}');
          }
        }
      }
      expect(count, greaterThan(30));
    });

    test('單元學習：每個單元都有單字、句型練習、短對話與小測驗', () {
      for (final unit in Lessons.units) {
        expect(unit.group, LessonGroup.unit, reason: unit.id);
        expect(unit.cards.length, greaterThanOrEqualTo(5), reason: unit.id);
        expect(unit.cards.last.id.endsWith(':dialog'), isTrue, reason: unit.id);
        expect(unit.quizSeeds.length, greaterThanOrEqualTo(20), reason: unit.id);
      }
    });

    test('單元的每個句子都有語氣標籤，而且不是半語', () {
      final sentenceEnd = RegExp(r'[.?!]$');
      var sentences = 0;
      for (final unit in Lessons.units) {
        for (final card in unit.cards) {
          for (final item in card.items) {
            if (!sentenceEnd.hasMatch(item.display)) {
              continue;
            }
            sentences++;
            expect(item.tag, isNotNull, reason: '${card.id} ${item.display}');
            expect(SpeechTag.all.contains(item.tag), isTrue,
                reason: '${card.id} ${item.display}');
          }
        }
      }
      expect(sentences, greaterThan(40));
      // 每個有標籤的句子，最後一句要以敬語結尾（요／니다／니까／십시오），不是半語。
      final polite = RegExp(r'(요|죠|니다|니까|십시오)$');
      for (final unit in Lessons.units) {
        for (final card in unit.cards) {
          for (final item in card.items) {
            if (item.tag == null) {
              continue;
            }
            final last = item.display
                .split(RegExp(r'(?<=[.?!])\s+'))
                .last
                .replaceAll(RegExp(r'[.?!]+$'), '');
            expect(polite.hasMatch(last), isTrue,
                reason: '${card.id} ${item.display}');
          }
        }
      }
    });

    test('單元測驗只考前面出現過的單字（題目與錯誤選項都是）', () {
      final shown = StringBuffer();
      final generator = QuizGenerator(
        random: Random(5),
        wordPoolFor: Lessons.unitWordPoolFor,
      );
      for (final unit in Lessons.units) {
        for (final card in unit.cards) {
          if (card.kind == LessonCardKind.grammar) {
            continue;
          }
          shown
            ..writeln(card.title)
            ..writeAll(card.paragraphs, '\n');
          for (final item in card.items) {
            shown
              ..writeln(item.display)
              ..writeln(item.caption ?? '');
          }
        }
        final text = shown.toString();
        for (final seed in unit.quizSeeds) {
          expect(
            seed.kind == QuizKind.wordMeaning ||
                seed.kind == QuizKind.meaningWord,
            isTrue,
            reason: '${unit.id} 只出單字題：${seed.key}',
          );
          final word = Catalog.wordById(seed.itemId)!;
          expect(text.contains(word.hangul), isTrue,
              reason: '${unit.id} 還沒出現過：${word.hangul}');

          final pool = Lessons.unitWordPoolFor(seed.itemId)!;
          final allowed = <String>{
            for (final id in pool) ...<String>[
              Catalog.wordById(id)!.hangul,
              Catalog.wordById(id)!.meaning,
            ],
          };
          for (var round = 0; round < 5; round++) {
            final q = generator.build(seed)!;
            expect(q.options.length, 4, reason: '${unit.id} ${seed.key}');
            for (final option in q.options) {
              expect(allowed.contains(option), isTrue,
                  reason: '${unit.id} ${seed.key} 選項超出學過的範圍：$option');
            }
          }
        }
      }
    });

    test('單元講到的文法點都存在，而且同一個文法點只放在一個單元', () {
      final seen = <String, String>{};
      var unitsWithGrammar = 0;
      for (final unit in Lessons.units) {
        final ids = <String>[
          for (final card in unit.cards) ...card.grammarPointIds,
        ];
        if (ids.isNotEmpty) {
          unitsWithGrammar++;
        }
        for (final id in ids) {
          expect(Catalog.grammarPointById(id), isNotNull, reason: '${unit.id} $id');
          expect(Catalog.grammarLessonOfPoint(id), isNotNull, reason: '${unit.id} $id');
          expect(seen.containsKey(id), isFalse,
              reason: '${unit.id} $id 已放在 ${seen[id]}');
          seen[id] = unit.id;
        }
      }
      // 不是每個單元都有新文法（例如只學數字的單元），但大部分單元都有。
      expect(unitsWithGrammar, greaterThanOrEqualTo(25));
    });

    test('單元 1～5 的文法寫在說明卡裡，不再另外插入文法庫的卡片', () {
      for (final unit in Lessons.units.take(5)) {
        expect(
          unit.cards.where((c) => c.kind == LessonCardKind.grammar),
          isEmpty,
          reason: unit.id,
        );
      }
      final unit1 = Lessons.units.first;
      expect(
        unit1.cards.expand((c) => c.grammarRefs),
        containsAll(<String>['eun_neun', 'ieyo', 'anieyo']),
      );
    });

    test('單元有「對誰說哪一種」卡片；職場版與進階尊敬說法依開關顯示', () {
      final unit1 = Lessons.units.first;
      expect(unit1.cards.any((c) => c.id == 'u1:who'), isTrue);
      for (final unit in Lessons.units) {
        final formal = unit.cards.where((c) => c.id.endsWith(':formal'));
        // 職場版只做到單元 8；單元 9 之後不另做（見 docs/curriculum_plan.md）。
        final unitNumber = int.parse(unit.id.split('-').last);
        if (CourseOptions.showWorkplace && unitNumber <= 8) {
          expect(formal, isNotEmpty, reason: unit.id);
          for (final card in formal) {
            for (final item in card.items) {
              expect(item.tag, SpeechTag.formal, reason: item.display);
            }
          }
        } else {
          expect(formal, isEmpty, reason: unit.id);
        }
        if (!CourseOptions.showHonorific) {
          for (final card in unit.cards) {
            expect(card.point?.id, isNot('speech_si'), reason: unit.id);
            for (final item in card.items) {
              expect(item.display.contains('주시겠어요'), isFalse,
                  reason: '${card.id} ${item.display}');
              expect(item.display.contains('성함'), isFalse,
                  reason: '${card.id} ${item.display}');
            }
          }
        }
      }
    });

    test('半語另外放在半語課，單元與一般課程不含半語標籤', () {
      expect(Lessons.casual.single.group, LessonGroup.casual);
      expect(Lessons.units.every((u) => u.group == LessonGroup.unit), isTrue);
      expect(
        Lessons.casual.single.cards.any((c) => c.id == 'grammar:banmal_units'),
        isTrue,
      );
    });

    test('尚未建立的課程有清楚的清單', () {
      expect(Lessons.planned, isNotEmpty);
    });
  });
}
