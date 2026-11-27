import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
import 'package:hangul_app/data/hanja_suffixes.dart';
import 'package:hangul_app/ui/hanja_suffix_line.dart';

WordItem _word(String hangul) =>
    Catalog.words.firstWhere((w) => w.hangul == hangul);

void main() {
  group('漢字詞字尾提示', () {
    test('교실 的字尾是 실（室），同類是別的 -실 字，不含自己', () {
      final hint = hanjaSuffixHintOf(_word('교실'), Catalog.words)!;
      expect(hint.suffix.hangul, '실');
      expect(hint.suffix.hanja, '室');
      expect(hint.siblings, isNotEmpty);
      expect(hint.siblings.length, lessThanOrEqualTo(maxSiblings));
      for (final w in hint.siblings) {
        expect(w.hangul.endsWith('실'), isTrue, reason: w.hangul);
        expect(w.hanja!.endsWith('室'), isTrue, reason: w.hangul);
        expect(w.hangul, isNot('교실'));
      }
    });

    test('同音不同字：병원（院）會提醒 원 也可能是園、員', () {
      final hint = hanjaSuffixHintOf(_word('병원'), Catalog.words)!;
      expect(hint.suffix.hanja, '院');
      expect(hint.sameSound.map((s) => s.suffix.hanja),
          containsAll(<String>['園', '員']));
      expect(hint.sameSound.every((s) => s.example != null), isTrue);
      final person = hanjaSuffixHintOf(_word('회사원'), Catalog.words)!;
      expect(person.suffix.hanja, '員');
      expect(person.siblings.map((w) => w.hangul), isNot(contains('병원')));
    });

    test('字尾看起來一樣但意思不同的字不給提示', () {
      for (final hangul in <String>['인생', '남동생', '고생', '주소', '당장', '직장', '단어']) {
        expect(hanjaSuffixOf(_word(hangul)), isNull, reason: hangul);
      }
      // 同一個字尾，真正的學生仍然有。
      expect(hanjaSuffixOf(_word('대학생'))?.hanja, '生');
    });

    test('不是漢字詞或字數對不上的字不給提示', () {
      expect(hanjaSuffixOf(_word('사과')), isNull);
      expect(hanjaSuffixOf(_word('하나')), isNull);
      // 個月：兩個漢字對兩個音節，但字尾（월）不在名單內。
      expect(hanjaSuffixOf(_word('개월')), isNull);
    });

    test('名單裡每個字尾在單字庫都找得到字，被排除的字都在單字庫', () {
      for (final suffix in hanjaSuffixes) {
        final matches =
            Catalog.words.where((w) => hanjaSuffixOf(w) == suffix).toList();
        expect(matches.length, greaterThanOrEqualTo(2),
            reason: '${suffix.hangul}（${suffix.hanja}）');
        for (final w in matches) {
          expect(w.hangul.endsWith(suffix.hangul), isTrue, reason: w.hangul);
          expect(w.hanja!.endsWith(suffix.hanja), isTrue, reason: w.hangul);
        }
        for (final hangul in suffix.exclude) {
          expect(Catalog.words.any((w) => w.hangul == hangul), isTrue,
              reason: hangul);
        }
      }
    });
  });

  group('字尾提示畫面', () {
    Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
          MaterialApp(home: Scaffold(body: SizedBox(width: 360, child: child))),
        );

    testWidgets('完整版有同類與同音不同字；精簡版只有字尾一行', (tester) async {
      final word = _word('병원');
      await pump(tester, HanjaSuffixLine(word: word));
      expect(find.textContaining('同類', findRichText: true), findsOneWidget);
      expect(find.textContaining('同音不同字'), findsOneWidget);

      await pump(tester, HanjaSuffixLine(word: word, compact: true));
      expect(find.textContaining('-원（院）', findRichText: true), findsOneWidget);
      expect(find.textContaining('同類', findRichText: true), findsNothing);
      expect(find.textContaining('同音不同字'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('沒有字尾的字不顯示任何東西', (tester) async {
      await pump(tester, HanjaSuffixLine(word: _word('사과'), compact: true));
      expect(find.textContaining('字尾', findRichText: true), findsNothing);
    });
  });
}
