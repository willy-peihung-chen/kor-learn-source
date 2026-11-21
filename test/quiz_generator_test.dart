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

  group('同形異義詞的雙正解', () {
    Set<String> tokens(String meaning) => meaning
        .replaceAll(RegExp('（[^）]*）'), '')
        .split('；')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    test('指定範圍時：另一個意思重疊的單字（여덟＝八）不會出現在 팔 的選項裡', () {
      final narrow = QuizGenerator(
        random: Random(1),
        wordPoolFor: (_) => <String>{
          'word:여덟',
          'word:둘',
          'word:셋',
          'word:팔#臂',
          'word:팔#八',
        },
      );
      // 팔 有「手臂」和「八（漢字數詞）」兩個意思；여덟 是「八（固有數詞）」。
      final a = narrow.build(const QuizSeed(QuizKind.wordMeaning, 'word:팔#臂'))!;
      expect(a.options, isNot(contains('八（固有數詞）')));
      expect(a.options, contains('手臂'));

      // 反方向：問「八（固有數詞）」時，選項不能有 팔。
      final b = narrow.build(const QuizSeed(QuizKind.meaningWord, 'word:여덟'));
      // 範圍內有 팔（八）與 팔（手臂），둘、셋；팔 兩個意思都不能當干擾選項。
      expect(b, isNotNull);
      expect(b!.options, isNot(contains('팔')));
    });

    test('已知的近義字組要共用至少一個意思，出題時才會互相排除', () {
      // 中文寫法不同但意思實質相同的字（例如口語縮寫），
      // 要靠共用的意思詞讓 _overlaps 把它們排除，否則選項會有兩個都對。
      const pairs = <List<String>>[
        <String>['이거', '이것'],
        <String>['그거', '그것'],
        <String>['저거', '저것'],
        <String>['무슨', '어떤'],
        <String>['어서', '빨리'],
        <String>['실례', '실례합니다'],
        <String>['테이블', '식탁'],
        <String>['테이블', '책상'],
        <String>['이쪽', '여기'],
        <String>['저쪽', '저기'],
        <String>['그쪽', '거기'],
        <String>['그곳', '거기'],
        <String>['공휴일', '휴일'],
        <String>['한국말', '한국어'],
        <String>['잠깐', '잠시'],
        <String>['핸드폰', '휴대폰'],
        <String>['티브이', '텔레비전'],
        <String>['노트', '공책'],
        <String>['흰색', '하얀색'],
        <String>['슈퍼마켓', '마트'],
        <String>['얘기', '이야기'],
        <String>['얘기하다', '이야기하다'],
        <String>['드리다', '주다'],
        <String>['계시다', '있다'],
        <String>['잡수시다', '먹다'],
        <String>['말씀하다', '말하다'],
        <String>['죄송하다', '죄송합니다'],
        <String>['감사', '감사합니다'],
        <String>['스무', '스물'],
        <String>['물어보다', '묻다'],
        <String>['잊어버리다', '잊다'],
        <String>['잃다', '잃어버리다'],
        <String>['돕다', '도와주다'],
        <String>['고프다', '배고프다'],
        <String>['아름답다', '예쁘다'],
        <String>['힘들다', '피곤하다'],
        <String>['축하하다', '축하합니다'],
        <String>['질문하다', '묻다'],
        <String>['댁', '집'],
        <String>['지내다', '보내다'],
        <String>['늦다', '늦게'],
        <String>['반갑다', '만나서 반갑습니다'],
        <String>['이십', '스물'],
        <String>['삼십', '서른'],
        <String>['사십', '마흔'],
        <String>['오십', '쉰'],
        <String>['육십', '예순'],
        <String>['칠십', '일흔'],
        <String>['팔십', '여든'],
        <String>['구십', '아흔'],
        <String>['세상', '세계'],
        <String>['모양', '모습'],
        <String>['뜻', '의미'],
        <String>['경기', '대회'],
        <String>['최근', '요즘'],
        <String>['지난해', '작년'],
        <String>['주변', '근처'],
        <String>['마치다', '끝내다'],
        <String>['이용하다', '사용하다'],
        <String>['도움', '돕다'],
        <String>['늘', '언제나'],
        <String>['기간', '동안'],
        <String>['마찬가지', '똑같다'],
        <String>['핸드폰', '스마트폰'],
        <String>['같다', '마찬가지'],
        <String>['훨씬', '더'],
        <String>['다양하다', '여러'],
        <String>['바뀌다', '바꾸다'],
        <String>['느끼다', '느낌'],
        <String>['식구', '가족'],
        <String>['음료', '음료수'],
        <String>['무척', '아주'],
        <String>['금방', '곧'],
        <String>['자꾸', '계속'],
        <String>['키우다', '기르다'],
        <String>['하얗다', '하얀색'],
        <String>['검다', '검은색'],
        <String>['정확하다', '맞다'],
        <String>['비용', '요금'],
        <String>['안전', '안전하다'],
        <String>['선택하다', '고르다'],
        <String>['새로', '새롭다'],
        <String>['소식', '뉴스'],
        <String>['찾아보다', '찾다'],
        <String>['얼른', '빨리'],
        <String>['몹시', '아주'],
        <String>['굉장히', '아주'],
        <String>['어쩌면', '아마'],
        <String>['해외', '외국'],
        <String>['없어지다', '사라지다'],
        <String>['결정하다', '정하다'],
        <String>['순서', '차례'],
        <String>['조그맣다', '작다'],
        <String>['붉다', '빨간색'],
        <String>['훌륭하다', '대단하다'],
        <String>['당연하다', '물론'],
        <String>['마침내', '결국'],
        <String>['푸르다', '파란색'],
        <String>['모시다', '데리다'],
        <String>['알맞다', '어울리다'],
        <String>['아까', '금방'],
        <String>['놀이', '게임'],
        <String>['과제', '숙제'],
      ];
      for (final pair in pairs) {
        final a = Catalog.words.firstWhere((w) => w.hangul == pair[0]);
        final b = Catalog.words.firstWhere((w) => w.hangul == pair[1]);
        expect(
          tokens(a.meaning).intersection(tokens(b.meaning)),
          isNotEmpty,
          reason: '${pair[0]}（${a.meaning}）與 ${pair[1]}（${b.meaning}）',
        );
      }
    });

    test('所有單字：選項裡除了答案，沒有任何單字的任何一個意思和答案重疊', () {
      for (final word in Catalog.words) {
        final senses = Catalog.words.where((w) => w.hangul == word.hangul);
        final correctTokens = <String>{
          for (final s in senses) ...tokens(s.meaning),
        };
        final a = generator.build(QuizSeed(QuizKind.wordMeaning, word.id))!;
        for (var i = 0; i < a.options.length; i++) {
          if (i == a.correctIndex) {
            continue;
          }
          expect(
            tokens(a.options[i]).intersection(correctTokens),
            isEmpty,
            reason: '${word.id} 的選項 ${a.options[i]}',
          );
        }

        final b = generator.build(QuizSeed(QuizKind.meaningWord, word.id))!;
        final wordTokens = tokens(word.meaning);
        for (var i = 0; i < b.options.length; i++) {
          if (i == b.correctIndex) {
            continue;
          }
          for (final other in Catalog.words.where((w) => w.hangul == b.options[i])) {
            expect(
              tokens(other.meaning).intersection(wordTokens),
              isEmpty,
              reason: '${word.id} 的選項 ${b.options[i]}（${other.meaning}）',
            );
          }
        }
      }
    });
  });

  group('選項說明（作答後顯示每個選項的意思）', () {
    test('單字題：每個選項都有說明，且與該選項實際對應的單字一致', () {
      for (final word in Catalog.words) {
        final a = generator.build(QuizSeed(QuizKind.wordMeaning, word.id))!;
        expect(a.optionNotes, isNotNull, reason: word.id);
        expect(a.optionNotes!.length, a.options.length, reason: word.id);
        expect(a.optionNotes![a.correctIndex], word.hangul, reason: word.id);
        for (var i = 0; i < a.options.length; i++) {
          final note = a.optionNotes![i];
          expect(note, isNotNull, reason: '${word.id} 選項 ${a.options[i]}');
          // 說明裡的每個韓文單字，意思都要等於該選項。
          for (final hangul in note!.split('、')) {
            expect(
              Catalog.words.any(
                (w) => w.hangul == hangul && w.meaning == a.options[i],
              ),
              isTrue,
              reason: '${word.id} 選項 ${a.options[i]} 說明 $hangul',
            );
          }
        }

        final b = generator.build(QuizSeed(QuizKind.meaningWord, word.id))!;
        expect(b.optionNotes, isNotNull, reason: word.id);
        expect(b.optionNotes!.length, b.options.length, reason: word.id);
        expect(b.optionNotes![b.correctIndex], word.meaning, reason: word.id);
        for (var i = 0; i < b.options.length; i++) {
          final note = b.optionNotes![i];
          expect(note, isNotNull, reason: '${word.id} 選項 ${b.options[i]}');
          // 說明裡的每個意思，都要是這個韓文單字的某個意思。
          final meanings = Catalog.words
              .where((w) => w.hangul == b.options[i])
              .map((w) => w.meaning)
              .toSet();
          expect(
            meanings.contains(note) ||
                note!.split(' / ').every(meanings.contains),
            isTrue,
            reason: '${word.id} 選項 ${b.options[i]} 說明 $note',
          );
        }
      }
    });

    test('字母、音節、文法題沒有選項說明', () {
      final q = generator.build(
        QuizSeed(QuizKind.letterName, Catalog.letters.first.id),
      )!;
      expect(q.optionNotes, isNull);
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
