import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/util/korean_runs.dart';

void main() {
  group('說明文字切出韓文', () {
    test('中間夾空白的韓文算同一段', () {
      expect(splitKoreanRuns('例如 메뉴 좀 주세요（請給我菜單）'), const <TextRun>[
        TextRun('例如 ', isKorean: false),
        TextRun('메뉴 좀 주세요', isKorean: true),
        TextRun('（請給我菜單）', isKorean: false),
      ]);
    });

    test('被符號隔開的韓文分成兩段', () {
      final korean = splitKoreanRuns('「을／를」')
          .where((r) => r.isKorean)
          .map((r) => r.text)
          .toList();
      expect(korean, <String>['을', '를']);
    });

    test('單獨的字母不算韓文段落', () {
      final runs = splitKoreanRuns('收尾音是 ㄹ 時用「로」');
      expect(runs.where((r) => r.isKorean).map((r) => r.text), <String>['로']);
      expect(runs.map((r) => r.text).join(), '收尾音是 ㄹ 時用「로」');
    });

    test('沒有韓文時整段原樣保留', () {
      expect(splitKoreanRuns('只有中文。'), const <TextRun>[
        TextRun('只有中文。', isKorean: false),
      ]);
    });

    test('切完再接起來和原文一樣', () {
      const text = '저는 학생이에요. → 나는 학생이야.（저→나，이에요→이야）';
      expect(splitKoreanRuns(text).map((r) => r.text).join(), text);
    });
  });
}
