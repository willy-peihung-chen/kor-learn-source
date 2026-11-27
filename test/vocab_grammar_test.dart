import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
import 'package:hangul_app/data/labels.dart';

void main() {
  final hangulChar = RegExp(r'[가-힣]');
  final cjkOnly = RegExp(r'^[一-鿿]+$');

  group('單字資料', () {
    test('至少 1000 個單字、主題 id 與單字 id 都不重複', () {
      expect(Catalog.words.length, greaterThanOrEqualTo(1000));
      final topicIds = Catalog.topics.map((t) => t.id).toList();
      expect(topicIds.toSet().length, topicIds.length);
      final wordIds = Catalog.words.map((w) => w.id).toList();
      expect(wordIds.toSet().length, wordIds.length);
    });

    test('中翻韓卡翻面前看得到的中文（意思、例句翻譯）不含這個字的韓文', () {
      // 中翻韓卡翻面前會顯示 meaning 與 exampleMeaning，不能直接寫出答案。
      for (final word in Catalog.words) {
        final answer = word.hangul.replaceAll(' ', '');
        final front = '${word.meaning} ${word.exampleMeaning}'.replaceAll(' ', '');
        expect(front.contains(answer), isFalse, reason: word.id);
      }
    });

    test('每個單字只屬於一個主題，且主題不是空的', () {
      var total = 0;
      for (final topic in Catalog.topics) {
        expect(topic.words, isNotEmpty, reason: topic.id);
        expect(topic.title, isNotEmpty);
        total += topic.words.length;
        for (final word in topic.words) {
          expect(Catalog.topicOfWord(word.id)?.id, topic.id, reason: word.id);
        }
      }
      expect(total, Catalog.words.length);
    });

    test('每個單字都有韓文、中文意思、含韓文的例句與例句翻譯', () {
      for (final word in Catalog.words) {
        expect(hangulChar.hasMatch(word.hangul), isTrue, reason: word.id);
        expect(word.meaning.trim(), word.meaning, reason: word.id);
        expect(word.meaning, isNotEmpty, reason: word.id);
        expect(hangulChar.hasMatch(word.example), isTrue, reason: word.id);
        expect(word.exampleMeaning, isNotEmpty, reason: word.id);
        expect(word.hangul.trim(), word.hangul, reason: word.id);
      }
    });

    test('漢字欄位只含漢字（不混韓文、字母或空白）', () {
      for (final word in Catalog.words.where((w) => w.hanja != null)) {
        expect(cjkOnly.hasMatch(word.hanja!), isTrue, reason: '${word.id} ${word.hanja}');
      }
    });

    test('同形異義詞都有 sense 區分，id 不衝突', () {
      final byHangul = <String, List<WordItem>>{};
      for (final word in Catalog.words) {
        byHangul.putIfAbsent(word.hangul, () => <WordItem>[]).add(word);
      }
      for (final entry in byHangul.entries.where((e) => e.value.length > 1)) {
        for (final word in entry.value) {
          expect(word.sense, isNotNull, reason: '${entry.key} 缺少 sense');
        }
      }
    });

    test('原有 14 個單字的 id 維持不變（舊的學習紀錄才不會失效）', () {
      const legacy = <String>[
        '아이', '우유', '오이', '나무', '바지', '고기', '모자',
        '여자', '지도', '커피', '포도', '주스', '어머니', '아버지',
      ];
      for (final hangul in legacy) {
        expect(Catalog.wordById('word:$hangul'), isNotNull, reason: hangul);
      }
    });
  });

  group('文法資料', () {
    test('課程、文法點、例句 id 都不重複', () {
      final lessonIds = Catalog.grammarLessons.map((l) => l.id).toList();
      expect(lessonIds.toSet().length, lessonIds.length);
      final pointIds = Catalog.grammarPoints.map((p) => p.id).toList();
      expect(pointIds.toSet().length, pointIds.length);
      expect(Catalog.grammarExampleIds.toSet().length,
          Catalog.grammarExampleIds.length);
    });

    test('每個例句恰有一組中括號、3 個不重複且不等於答案的錯誤選項', () {
      for (final point in Catalog.grammarPoints) {
        expect(point.examples.length, greaterThanOrEqualTo(3), reason: point.id);
        expect(point.explanation, isNotEmpty, reason: point.id);
        for (var i = 0; i < point.examples.length; i++) {
          final example = point.examples[i];
          final reason = '${point.id}[$i] ${example.ko}';
          expect('['.allMatches(example.ko).length, 1, reason: reason);
          expect(']'.allMatches(example.ko).length, 1, reason: reason);
          expect(example.answer, isNotEmpty, reason: reason);
          expect(example.wrong.length, 3, reason: reason);
          expect(example.wrong.toSet().length, 3, reason: reason);
          expect(example.wrong.contains(example.answer), isFalse, reason: reason);
          expect(hangulChar.hasMatch(example.plain), isTrue, reason: reason);
          expect(example.zh, isNotEmpty, reason: reason);
          expect(example.cloze.contains('____'), isTrue, reason: reason);
        }
      }
    });

    test('例句 id 可以解回文法點與例句，格式錯誤回傳 null', () {
      for (final id in Catalog.grammarExampleIds) {
        final ref = Catalog.grammarExample(id);
        expect(ref, isNotNull, reason: id);
        expect(ref!.point.exampleId(ref.index), id);
      }
      expect(Catalog.grammarExample('gram:不存在:0'), isNull);
      expect(Catalog.grammarExample('gram:${Catalog.grammarPoints.first.id}:99'), isNull);
      expect(Catalog.grammarExample('word:아이'), isNull);
    });

    test('錯題本的標籤可以顯示文法例句', () {
      final id = Catalog.grammarExampleIds.first;
      expect(itemLabel(id), contains(Catalog.grammarExample(id)!.example.plain));
    });
  });
}
