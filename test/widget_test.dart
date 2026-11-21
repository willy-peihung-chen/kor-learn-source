import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/app.dart';
import 'package:hangul_app/audio/speech_service.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/lessons.dart';
import 'package:hangul_app/data/word_levels.dart';
import 'package:hangul_app/state/app_state.dart';
import 'package:hangul_app/logic/srs.dart';
import 'package:hangul_app/storage/progress_data.dart';
import 'package:hangul_app/storage/progress_repository.dart';
import 'package:hangul_app/ui/about_page.dart';
import 'package:hangul_app/ui/app_shell.dart';
import 'package:hangul_app/ui/review_page.dart';
import 'package:hangul_app/ui/lesson_page.dart';
import 'package:hangul_app/ui/progress_page.dart';

const List<Size> _sizes = <Size>[
  Size(360, 740), // 手機
  Size(820, 1180), // 平板直向
  Size(1280, 800), // 電腦
];

/// 記下被要求朗讀的文字，不會真的發聲。
class FakeSpeechService implements SpeechService {
  FakeSpeechService({this.available = true});

  final bool available;
  final List<String> spoken = <String>[];

  @override
  Future<bool> speak(String text) async {
    spoken.add(text);
    return available;
  }

  @override
  Future<void> stop() async {}
}

Future<AppState> _pumpApp(
  WidgetTester tester,
  Size size, {
  SpeechService? speech,
  ProgressData? data,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final state = AppState(
    repository: MemoryProgressRepository(),
    data: data,
    clock: () => DateTime(2026, 10, 29, 12),
  );
  await tester.pumpWidget(
    HangulApp(
      state: state,
      speech: speech ?? const NoopSpeechService(),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<void> _openTab(WidgetTester tester, Size size, String label) async {
  final navigation = size.width >= 860
      ? find.byType(NavigationRail)
      : find.byType(NavigationBar);
  await tester.tap(
    find.descendant(of: navigation, matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

/// 進入「單字」頁籤，按下「開始複習」，進到單字複習畫面。
Future<void> _openReview(WidgetTester tester, Size size) async {
  await _openTab(tester, size, '單字');
  await tester.tap(find.text('開始複習'));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in _sizes) {
    final name = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('首頁在 $name 可正常顯示，沒有版面例外', (tester) async {
      await _pumpApp(tester, size);
      expect(find.text('今日學習'), findsOneWidget);
      expect(find.text('開始學習'), findsOneWidget);
      expect(find.text('今日課程'), findsOneWidget);
      expect(find.text('舊知識複習'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('三個主要頁面在 $name 都能開啟，沒有版面例外', (tester) async {
      await _pumpApp(tester, size);

      await _openTab(tester, size, '課程');
      expect(find.text(Lessons.all.first.title), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _openTab(tester, size, '單字');
      expect(find.text(Catalog.topics.first.title), findsOneWidget);
      expect(find.text('開始複習'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _openTab(tester, size, '首頁');
      expect(find.text('今日學習'), findsOneWidget);
    });

    testWidgets('學習進度頁在 $name 從頭捲到尾，沒有版面例外', (tester) async {
      await _pumpApp(tester, size);
      openProgress(tester.element(find.byType(AppShell)));
      await tester.pumpAndSettle();
      expect(find.text('今天的新單字'), findsOneWidget);
      final scrollable = find
          .descendant(
            of: find.byType(ProgressPage),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('最近學習紀錄'),
        300,
        scrollable: scrollable,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('完成第一課：學習紀錄寫入狀態，首頁數字隨之更新', (tester) async {
    const size = Size(360, 740);
    final state = await _pumpApp(tester, size);
    final lesson = Lessons.all.first;

    await _openTab(tester, size, '課程');
    await tester.tap(find.text(lesson.title));
    await tester.pumpAndSettle();

    for (var i = 0; i < lesson.cards.length - 1; i++) {
      await tester.tap(find.text('下一個'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('完成本課'));
    await tester.pumpAndSettle();

    expect(find.text('已完成本課'), findsOneWidget);
    expect(find.text('做課後小測驗'), findsOneWidget);
    expect(state.isLessonCompleted(lesson.id), isTrue);
    expect(state.learnedCardCount(lesson), lesson.cards.length);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('回到課程列表'));
    await tester.pumpAndSettle();
    expect(find.text('已完成'), findsOneWidget);
  });

  testWidgets('單字複習：顯示意思後可以評估，並進入下一張', (tester) async {
    const size = Size(360, 740);
    final state = await _pumpApp(tester, size);

    final first = Catalog.wordById(state.buildReviewQueue().first)!;
    await _openReview(tester, size);
    expect(find.text(first.hangul), findsOneWidget);

    await tester.tap(find.text('顯示意思'));
    await tester.pumpAndSettle();
    expect(find.text(first.meaning), findsOneWidget);
    expect(find.text(first.example), findsOneWidget);

    await tester.tap(find.text('熟悉'));
    await tester.pumpAndSettle();

    expect(state.isNewWord(first.id), isFalse);
    expect(find.textContaining('第 2 /'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('單字複習：評「不熟悉」的卡排到這一輪最後再出現一次', (tester) async {
    const size = Size(360, 740);
    final state = await _pumpApp(tester, size);
    final queue = state.buildReviewQueue();
    final first = Catalog.wordById(queue.first)!;

    await _openReview(tester, size);
    await tester.tap(find.text('顯示意思'));
    await tester.pumpAndSettle();
    // 自評標準說明顯示在按鈕下面。
    expect(find.textContaining('想不起來或想錯'), findsOneWidget);
    await tester.tap(find.text('不熟悉'));
    await tester.pumpAndSettle();
    // 張數多一張：第 2 / (原本張數 + 1) 張。
    expect(find.textContaining('第 2 / ${queue.length + 1} 張'), findsOneWidget);

    // 其餘的卡都評「普通」，最後一張應該是剛才答錯的字，標示「再練一次」。
    for (var i = 1; i < queue.length; i++) {
      await tester.tap(find.text('顯示意思'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('普通'));
      await tester.pumpAndSettle();
    }
    expect(find.text(first.hangul), findsOneWidget);
    expect(find.textContaining('再練一次'), findsOneWidget);
    await tester.tap(find.text('顯示意思'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('熟悉'));
    await tester.pumpAndSettle();

    expect(find.textContaining('本輪完成，共複習 ${queue.length} 個單字'),
        findsOneWidget);
    expect(find.textContaining('共評 ${queue.length + 1} 次'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('朗讀：單字與例句的按鈕會把正確的韓文交給語音服務', (tester) async {
    const size = Size(360, 740);
    final speech = FakeSpeechService();
    final state = await _pumpApp(tester, size, speech: speech);

    final first = Catalog.wordById(state.buildReviewQueue().first)!;
    await _openReview(tester, size);

    // 還沒翻開：只有單字的朗讀按鈕。
    expect(find.byTooltip('朗讀單字'), findsOneWidget);
    expect(find.byTooltip('朗讀例句'), findsNothing);
    await tester.tap(find.byTooltip('朗讀單字'));
    await tester.pumpAndSettle();
    expect(speech.spoken, <String>[first.hangul]);

    // 翻開後：例句也有朗讀按鈕。
    await tester.tap(find.text('顯示意思'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('朗讀例句'));
    await tester.pumpAndSettle();
    expect(speech.spoken, <String>[first.hangul, first.example]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('朗讀：裝置無法朗讀時顯示提示，而不是默默沒聲音', (tester) async {
    const size = Size(360, 740);
    final speech = FakeSpeechService(available: false);
    await _pumpApp(tester, size, speech: speech);

    await _openReview(tester, size);
    await tester.tap(find.byTooltip('朗讀單字'));
    await tester.pumpAndSettle();

    expect(find.textContaining('找不到韓文語音'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('朗讀：一輪複習的每個單字與例句都能交給語音服務', (tester) async {
    const size = Size(360, 740);
    final speech = FakeSpeechService();
    final state = await _pumpApp(tester, size, speech: speech);
    final queue = state.buildReviewQueue();
    await _openReview(tester, size);

    // 一張一張評分，把整輪單字走完，每張都按單字與例句的朗讀按鈕。
    final expected = <String>[];
    expect(queue.length, AppState.newWordsPerDay);
    for (var i = 0; i < queue.length; i++) {
      final word = Catalog.wordById(queue[i])!;
      await tester.tap(find.byTooltip('朗讀單字'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('顯示意思'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('朗讀例句'));
      await tester.pumpAndSettle();
      expected..add(word.hangul)..add(word.example);
      await tester.tap(find.text('普通'));
      await tester.pumpAndSettle();
    }
    expect(speech.spoken, expected);
    expect(tester.takeException(), isNull);
  });

  testWidgets('單字複習：最後一張答錯留到下一輪；新字額度用完後可以「今天再多學」', (tester) async {
    const size = Size(360, 740);
    final state = await _pumpApp(tester, size);
    final queue = state.buildReviewQueue();
    expect(queue.length, AppState.newWordsPerDay);
    await _openReview(tester, size);

    for (var i = 0; i < queue.length; i++) {
      await tester.tap(find.text('顯示意思'));
      await tester.pumpAndSettle();
      final last = i == queue.length - 1;
      await tester.tap(find.text(last ? '不熟悉' : '普通'));
      await tester.pumpAndSettle();
    }
    // 最後一張答錯：不馬上重出，結束畫面說明。
    expect(find.textContaining('本輪完成，共複習 ${queue.length} 個單字'),
        findsOneWidget);
    expect(find.textContaining('是這一輪的最後一張'), findsOneWidget);
    expect(find.textContaining('今天的 ${AppState.newWordsPerDay} 個新單字已經學完'),
        findsOneWidget);
    expect(state.newWordsLeftToday, 0);

    await tester.tap(find.text('今天再多學 ${AppState.extraNewWordsStep} 個'));
    await tester.pumpAndSettle();
    expect(state.newWordsQuotaToday,
        AppState.newWordsPerDay + AppState.extraNewWordsStep);
    expect(find.textContaining('第 1 / ${AppState.extraNewWordsStep} 張'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('難記的字：複習時標示，翻開後用法說明在例句前面；進度頁列出來', (tester) async {
    const size = Size(360, 740);
    final word = Catalog.words.firstWhere((w) => w.note != null);
    final now = DateTime(2026, 10, 29, 12);
    final state = await _pumpApp(
      tester,
      size,
      data: ProgressData(reviews: <String, ReviewState>{
        word.id: ReviewState(
          itemId: word.id,
          repetitions: 0,
          intervalDays: 0,
          ease: 1.5,
          lapses: AppState.hardWordLapses,
          dueAt: now.subtract(const Duration(hours: 1)),
          lastReviewedAt: now.subtract(const Duration(days: 1)),
        ),
      }),
    );
    expect(state.isHardWord(word.id), isTrue);

    await _openReview(tester, size);
    expect(find.text(word.hangul), findsOneWidget);
    expect(find.textContaining('難記的字'), findsOneWidget);
    await tester.tap(find.text('顯示意思'));
    await tester.pumpAndSettle();
    final noteLabel = find.textContaining('先看這裡');
    expect(noteLabel, findsOneWidget);
    expect(
      tester.getTopLeft(noteLabel).dy,
      lessThan(tester.getTopLeft(find.textContaining('例句（')).dy),
    );

    openProgress(tester.element(find.byType(ReviewSessionPage)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('不熟悉 ${AppState.hardWordLapses} 次'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ProgressPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('不熟悉 ${AppState.hardWordLapses} 次'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('首頁的「學習進度」連結可以打開進度頁', (tester) async {
    const size = Size(360, 740);
    await _pumpApp(tester, size);
    await tester.scrollUntilVisible(
      find.textContaining('學習進度（'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('學習進度（'));
    await tester.pumpAndSettle();
    expect(find.text('今天的新單字'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('難記的字'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ProgressPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('難記的字'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('單字分頁：所有單字依主題放在一起，點主題看到單字', (tester) async {
    const size = Size(360, 740);
    await _pumpApp(tester, size);
    await _openTab(tester, size, '單字');

    final topic = Catalog.topics.first;
    await tester.tap(find.text(topic.title));
    await tester.pumpAndSettle();
    // 頁面上最先看到的是第一段的第一個單字（片語主題不分段）。
    final shown = levelGroupsOf(topic).first.words.first;
    expect(find.text(shown.hangul), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('單字列：點單字列會朗讀', (tester) async {
    const size = Size(360, 740);
    final speech = FakeSpeechService();
    await _pumpApp(tester, size, speech: speech);
    await _openTab(tester, size, '單字');

    final topic = Catalog.topics.first;
    await tester.tap(find.text(topic.title));
    await tester.pumpAndSettle();

    final first = levelGroupsOf(topic).first.words.first;
    await tester.tap(find.text(first.hangul).first);
    await tester.pumpAndSettle();
    expect(speech.spoken, <String>[first.hangul]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('複習這個主題：只出該主題的單字', (tester) async {
    const size = Size(360, 740);
    await _pumpApp(tester, size);
    await _openTab(tester, size, '單字');

    final topic = Catalog.topics[1];
    await tester.tap(find.text(topic.title));
    await tester.pumpAndSettle();
    await tester.tap(find.text('複習這個主題'));
    await tester.pumpAndSettle();

    // 複習的第一張是主題頁畫面上的第一個字。
    expect(find.text(studyOrderOf(topic).first.hangul), findsOneWidget);
    expect(find.textContaining(topic.title), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('字母課：點發音方塊會朗讀完整音節，不是單獨的字母', (tester) async {
    const size = Size(360, 740);
    final speech = FakeSpeechService();
    await _pumpApp(tester, size, speech: speech);

    openLesson(tester.element(find.byType(AppShell)), Lessons.hangul.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一個'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ㅏ').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ㅓ').first);
    await tester.pumpAndSettle();
    expect(speech.spoken, <String>['아', '어']);
    expect(tester.takeException(), isNull);
  });

  for (final size in _sizes) {
    final name = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('文法課程在 $name 逐張看完，沒有版面例外，並可進入課後小測驗', (tester) async {
      final state = await _pumpApp(tester, size);
      final lesson = Lessons.grammar.first;

      openLesson(tester.element(find.byType(AppShell)), lesson);
      await tester.pumpAndSettle();

      for (var i = 0; i < lesson.cards.length - 1; i++) {
        await tester.tap(find.text('下一個'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '第 ${i + 2} 張卡片');
      }
      await tester.tap(find.text('完成本課'));
      await tester.pumpAndSettle();
      expect(find.text('已完成本課'), findsOneWidget);
      expect(state.isLessonCompleted(lesson.id), isTrue);

      await tester.tap(find.text('做課後小測驗'));
      await tester.pumpAndSettle();
      final total =
          lesson.quizSeeds.length < 8 ? lesson.quizSeeds.length : 8;
      expect(find.textContaining('第 1 / $total 題'), findsOneWidget);
      expect(find.textContaining('____'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('教材說明頁在 $name 可顯示', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: AboutContentPage()));
      await tester.pumpAndSettle();
      expect(find.text('教材說明'), findsOneWidget);
      expect(find.text('目前的教材量'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
