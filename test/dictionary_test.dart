import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/app.dart';
import 'package:hangul_app/audio/speech_service.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/content_models.dart';
import 'package:hangul_app/logic/dictionary.dart';
import 'package:hangul_app/state/app_state.dart';
import 'package:hangul_app/storage/progress_repository.dart';

void main() {
  group('辭典查詢', () {
    final sample = DictionarySearch(const <WordItem>[
      WordItem('수박', '西瓜', '수박을 먹어요.', '吃西瓜。'),
      WordItem('물', '水', '물을 마셔요.', '喝水。'),
      WordItem('수영장', '游泳池（有水）', '수영장에 가요.', '去游泳池。'),
      WordItem('과일', '水果', '과일을 좋아해요.', '喜歡水果。'),
      WordItem('이름', '名字（對長輩的敬語為 성함）', '이름이 뭐예요?', '你叫什麼名字？'),
    ]);

    List<String> hangulOf(String query) =>
        sample.search(query).map((w) => w.hangul).toList();

    test('意思完全相同的排最前面，其次是核心詞開頭相同，再來是括號補充與例句', () {
      // 水：물（完全相同）→ 과일（核心詞「水果」開頭相同）→ 수영장（只在括號補充裡）
      // → 수박 不含「水」，不會出現。
      expect(hangulOf('水'), <String>['물', '과일', '수영장']);
    });

    test('括號裡的補充說明不算核心詞，但仍然查得到', () {
      expect(DictionarySearch.meaningTokens('名字（對長輩的敬語為 성함）'), <String>['名字']);
      expect(hangulOf('名字'), <String>['이름']);
      expect(hangulOf('敬語'), <String>['이름']);
    });

    test('例句翻譯裡出現的詞也查得到，但排在意思相符的後面', () {
      expect(hangulOf('喝'), <String>['물']);
    });

    test('可以輸入韓文反查', () {
      expect(hangulOf('물'), <String>['물']);
      expect(hangulOf('수'), <String>['수박', '수영장']);
    });

    test('空白或查無結果時回傳空清單；limit 會限制筆數', () {
      expect(sample.search(''), isEmpty);
      expect(sample.search('   '), isEmpty);
      expect(sample.search('不存在的詞'), isEmpty);
      expect(sample.search('水', limit: 2).length, 2);
      expect(sample.search('水', limit: 0), isEmpty);
    });

    test('每個教材單字，用它的任何一個核心詞都查得到它自己', () {
      final all = DictionarySearch.all;
      for (final word in Catalog.words) {
        final tokens = DictionarySearch.meaningTokens(word.meaning);
        expect(tokens, isNotEmpty, reason: word.id);
        for (final token in tokens) {
          final ids = all.search(token, limit: 5000).map((w) => w.id).toList();
          expect(ids, contains(word.id), reason: '${word.id} / $token');
        }
      }
    });

    test('每個教材單字，用它的韓文查會排在第一個（同形異義詞除外）', () {
      final all = DictionarySearch.all;
      for (final word in Catalog.words) {
        final first = all.search(word.hangul, limit: 5000).first;
        expect(first.hangul, word.hangul, reason: word.id);
      }
    });
  });

  testWidgets('辭典頁籤：輸入中文會列出對應的韓文，查不到時有提示', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState(
      repository: MemoryProgressRepository(),
      clock: () => DateTime(2026, 11, 1, 12),
    );
    await tester.pumpWidget(
      HangulApp(state: state, speech: const NoopSpeechService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('辭典'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('試試看'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '學生');
    await tester.pumpAndSettle();
    expect(find.text('학생'), findsOneWidget);
    expect(find.textContaining('找到'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), '不存在的詞');
    await tester.pumpAndSettle();
    expect(find.textContaining('找不到'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
