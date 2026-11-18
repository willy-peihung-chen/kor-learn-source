import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/quiz_types.dart';
import 'package:hangul_app/logic/quiz_generator.dart';

void expectWellFormed(QuizQuestion question) {
  expect(question.options.length, 4, reason: question.prompt);
  expect(
    question.options.toSet().length,
    4,
    reason: '選項不可重複：${question.options}',
  );
  expect(question.correctIndex, inInclusiveRange(0, 3));
  expect(question.explanation, isNotEmpty);
}

void main() {
  late QuizGenerator generator;

  setUp(() {
    generator = QuizGenerator(random: Random(42));
  });

  group('各題型', () {
    test('字母→羅馬字：正確選項就是該字母的標記', () {
      for (final letter in Catalog.letters.where((l) => l.hasRoman)) {
        final q = generator.build(QuizSeed(QuizKind.letterRoman, letter.id))!;
        expectWellFormed(q);
        expect(q.correctAnswer, letter.roman);
      }
    });

    test('ㅇ 沒有羅馬字標記，不會出「字母→羅馬字」的題目', () {
      final q = generator.build(
        QuizSeed(QuizKind.letterRoman, Catalog.letterById('letter:ㅇ')!.id),
      );
      expect(q, isNull);
    });

    test('字母→名稱：正確選項就是該字母的名稱', () {
      for (final letter in Catalog.letters) {
        final q = generator.build(QuizSeed(QuizKind.letterName, letter.id))!;
        expectWellFormed(q);
        expect(q.correctAnswer, letter.name);
      }
    });

    test('音節→羅馬字與羅馬字→音節', () {
      for (final syllable in Catalog.syllables) {
        final a = generator.build(
          QuizSeed(QuizKind.syllableRoman, syllable.id),
        )!;
        expectWellFormed(a);
        expect(a.correctAnswer, syllable.roman);

        final b = generator.build(
          QuizSeed(QuizKind.syllableFromRoman, syllable.id),
        )!;
        expectWellFormed(b);
        expect(b.correctAnswer, syllable.hangul);
      }
    });

    test('單字→中文與中文→單字', () {
      for (final word in Catalog.words) {
        final a = generator.build(QuizSeed(QuizKind.wordMeaning, word.id))!;
        expectWellFormed(a);
        expect(a.correctAnswer, word.meaning);

        final b = generator.build(QuizSeed(QuizKind.meaningWord, word.id))!;
        expectWellFormed(b);
        expect(b.correctAnswer, word.hangul);
      }
    });

    test('找不到教材項目時回傳 null', () {
      expect(
        generator.build(const QuizSeed(QuizKind.wordMeaning, 'word:不存在')),
        isNull,
      );
      expect(
        generator.build(const QuizSeed(QuizKind.syllableRoman, 'syl:x')),
        isNull,
      );
    });
  });

  group('答題判定', () {
    test('只有選到正確索引才算答對', () {
      final q = generator.build(
        QuizSeed(QuizKind.wordMeaning, Catalog.words.first.id),
      )!;
      for (var i = 0; i < q.options.length; i++) {
        expect(q.isCorrect(i), i == q.correctIndex);
      }
    });

    test('題目可以轉回種子，用來重新出題（錯題本）', () {
      final seed = QuizSeed(QuizKind.letterName, Catalog.letters.first.id);
      final q = generator.build(seed)!;
      expect(q.seed.key, seed.key);
      final again = generator.build(q.seed)!;
      expect(again.correctAnswer, q.correctAnswer);
    });
  });

  group('混合測驗', () {
    test('回傳指定題數，題型＋項目不重複', () {
      final questions = generator.mixed(count: 10);
      expect(questions.length, 10);
      expect(questions.map((q) => q.seed.key).toSet().length, 10);
      questions.forEach(expectWellFormed);
    });

    test('fromSeeds 只從給定的種子裡抽題', () {
      final seeds = <QuizSeed>[
        for (final w in Catalog.words.take(3))
          QuizSeed(QuizKind.wordMeaning, w.id),
      ];
      final questions = generator.fromSeeds(seeds, count: 8);
      expect(questions.length, 3);
      final allowed = seeds.map((s) => s.key).toSet();
      for (final q in questions) {
        expect(allowed.contains(q.seed.key), isTrue);
      }
    });
  });
  group('單字題的干擾選項', () {
    test('所有單字都能出「單字→中文」與「中文→單字」，且選項不重複', () {
      for (final word in Catalog.words) {
        final a = generator.build(QuizSeed(QuizKind.wordMeaning, word.id))!;
        expectWellFormed(a);
        final b = generator.build(QuizSeed(QuizKind.meaningWord, word.id))!;
        expectWellFormed(b);
      }
    });

    test('同形異義詞：不會把另一個意思放進選項（避免兩個都算對）', () {
      var checked = 0;
      for (final word in Catalog.words) {
        final others = Catalog.homographsOf(word);
        if (others.isEmpty) {
          continue;
        }
        checked++;
        final a = generator.build(QuizSeed(QuizKind.wordMeaning, word.id))!;
        for (final other in others) {
          expect(a.options.contains(other.meaning), isFalse, reason: word.id);
        }
        final b = generator.build(QuizSeed(QuizKind.meaningWord, word.id))!;
        expect(
          b.options.where((o) => o == word.hangul).length,
          1,
          reason: word.id,
        );
      }
      expect(checked, greaterThan(0));
    });
  });

  group('文法填空', () {
    test('所有例句都能出題，正確選項就是被挖空的部分', () {
      for (final id in Catalog.grammarExampleIds) {
        final q = generator.build(QuizSeed(QuizKind.grammarCloze, id))!;
        expectWellFormed(q);
        final ref = Catalog.grammarExample(id)!;
        expect(q.correctAnswer, ref.example.answer, reason: id);
        expect(q.stimulus, ref.example.cloze, reason: id);
        expect(q.speakText, ref.example.plain, reason: id);
      }
    });

    test('文法測驗只出指定範圍內的例句', () {
      final ids = Catalog.grammarExampleIds.take(5).toList();
      final questions = generator.grammarQuiz(ids, count: 10);
      expect(questions.length, 5);
      for (final q in questions) {
        expect(ids.contains(q.itemId), isTrue);
      }
    });
  });

  group('混合測驗的範圍', () {
    test('單字與文法清單都是空的時，只出字母與音節題', () {
      final seeds = generator.randomSeeds(
        count: 20,
        wordIds: const <String>[],
        grammarExampleIds: const <String>[],
      );
      expect(seeds.length, 20);
      for (final seed in seeds) {
        expect(
          <QuizKind>{
            QuizKind.letterRoman,
            QuizKind.letterName,
            QuizKind.syllableRoman,
            QuizKind.syllableFromRoman,
          }.contains(seed.kind),
          isTrue,
          reason: seed.key,
        );
      }
    });

    test('給定單字與文法範圍時，單字題與文法題只從範圍內抽', () {
      final wordId = Catalog.words[3].id;
      final grammarId = Catalog.grammarExampleIds[4];
      final seeds = generator.randomSeeds(
        count: 40,
        wordIds: <String>[wordId],
        grammarExampleIds: <String>[grammarId],
      );
      final kinds = seeds.map((s) => s.kind).toSet();
      expect(kinds.contains(QuizKind.grammarCloze), isTrue);
      expect(kinds.contains(QuizKind.wordMeaning), isTrue);
      for (final seed in seeds) {
        if (seed.kind == QuizKind.grammarCloze) {
          expect(seed.itemId, grammarId);
        }
        if (seed.kind == QuizKind.wordMeaning ||
            seed.kind == QuizKind.meaningWord) {
          expect(seed.itemId, wordId);
        }
      }
    });

    test('主題單字測驗只出該主題的單字', () {
      final topic = Catalog.topics[2];
      final questions = generator.topicQuiz(topic.id, count: 10);
      expect(questions.length, 10);
      final ids = topic.words.map((w) => w.id).toSet();
      for (final q in questions) {
        expect(ids.contains(q.itemId), isTrue);
        expectWellFormed(q);
      }
      expect(generator.topicQuiz('不存在'), isEmpty);
    });
  });
}
