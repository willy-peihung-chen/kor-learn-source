import 'catalog.dart';
import 'content_models.dart';
import 'quiz_types.dart';
import 'unit_lessons.dart';

enum LessonCardKind { letter, syllable, concept, grammar, sound }

/// 課程分類。
enum LessonGroup {
  hangul('韓文字母'),
  unit('單元學習'),
  grammar('基礎文法'),
  casual('半語（額外學習）');

  const LessonGroup(this.label);
  final String label;
}

/// 「發音卡」上的一個可以點來聽的項目。
///
/// [speak] 一定要是完整的音節或詞（例如「아」「가」），不能是單獨的字母（例如 ㅏ、ㄱ）：
/// 電腦語音念單獨字母常常不準，念完整音節才可靠。
class SoundItem {
  const SoundItem({
    required this.display,
    required this.speak,
    this.caption,
    this.tag,
  });

  /// 畫面上大大顯示的字（可以是字母，也可以是音節或詞）。
  final String display;

  /// 點下去朗讀的內容。
  final String speak;

  /// 顯示在底下的小字，例如「ㄱ + ㅏ」或中文意思。
  final String? caption;

  /// 句子的語氣標籤（見 [SpeechTag]）。單字、音節等不是句子的項目為 null。
  final String? tag;
}

/// 句子的語氣標籤。單元與一般課程只用敬語；半語另外放在「半語（額外學習）」。
class SpeechTag {
  SpeechTag._();

  /// 해요體：日常對話最常用的敬語。
  static const String polite = '日常禮貌（해요體）';

  /// 합니다體：正式場合、職場、服務業。
  static const String formal = '正式・職場（합니다體）';

  /// 尊敬說法：句子裡有 -(으)시-（例如 -세요），店員對客人、對長輩、對陌生人的客氣說法。
  static const String honorific = '尊敬說法（-세요）';

  static const List<String> all = <String>[polite, formal, honorific];
}

/// 課程中的一張卡片。學習進度以卡片 id 為單位記錄。
class LessonCard {
  const LessonCard._({
    required this.id,
    required this.kind,
    required this.title,
    this.paragraphs = const <String>[],
    this.letter,
    this.syllable,
    this.point,
    this.examples = const <Syllable>[],
    this.items = const <SoundItem>[],
  });

  factory LessonCard.sound({
    required String id,
    required String title,
    required List<String> paragraphs,
    required List<SoundItem> items,
  }) =>
      LessonCard._(
        id: id,
        kind: LessonCardKind.sound,
        title: title,
        paragraphs: paragraphs,
        items: items,
      );

  factory LessonCard.grammar(GrammarPoint point) => LessonCard._(
        id: point.cardId,
        kind: LessonCardKind.grammar,
        title: point.title,
        point: point,
      );

  factory LessonCard.letter(HangulLetter letter) => LessonCard._(
        id: letter.id,
        kind: LessonCardKind.letter,
        title: letter.jamo,
        letter: letter,
      );

  factory LessonCard.syllable(Syllable syllable) => LessonCard._(
        id: syllable.id,
        kind: LessonCardKind.syllable,
        title: syllable.hangul,
        syllable: syllable,
      );

  factory LessonCard.concept({
    required String id,
    required String title,
    required List<String> paragraphs,
    List<Syllable> examples = const <Syllable>[],
  }) =>
      LessonCard._(
        id: id,
        kind: LessonCardKind.concept,
        title: title,
        paragraphs: paragraphs,
        examples: examples,
      );

  final String id;
  final LessonCardKind kind;
  final String title;
  final List<String> paragraphs;
  final HangulLetter? letter;
  final Syllable? syllable;
  final GrammarPoint? point;
  final List<Syllable> examples;
  final List<SoundItem> items;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.group,
    required this.title,
    required this.summary,
    required this.cards,
    required this.quizSeeds,
  });

  final String id;
  final LessonGroup group;
  final String title;
  final String summary;
  final List<LessonCard> cards;

  /// 課後小測驗的題目來源。
  final List<QuizSeed> quizSeeds;
}

/// 已規劃但尚未建立的課程，只用來清楚標示「尚未建立」。
class PlannedLesson {
  const PlannedLesson({required this.title, required this.summary});

  final String title;
  final String summary;
}

class Lessons {
  Lessons._();

  static final List<Lesson> hangul = List<Lesson>.unmodifiable(
    <Lesson>[
      _vowelLesson(),
      _consonantLesson(),
      _readingLesson(),
      ...buildMoreHangulLessons(),
    ],
  );

  /// 半語另外放在「半語（額外學習）」，單元與一般課程的句子都是敬語。
  static const Set<String> _casualLessonIds = <String>{'casual_speech'};

  static final List<Lesson> grammar = List<Lesson>.unmodifiable(
    <Lesson>[
      for (final data in Catalog.grammarLessons)
        if (!_casualLessonIds.contains(data.id)) _grammarLesson(data),
    ],
  );

  static final List<Lesson> casual = List<Lesson>.unmodifiable(
    <Lesson>[
      for (final data in Catalog.grammarLessons)
        if (_casualLessonIds.contains(data.id))
          _grammarLesson(data, LessonGroup.casual),
    ],
  );

  /// 單元學習：每個單元＝核心單字、固定句型換詞練習、短對話、小測驗。
  static final List<Lesson> units =
      List<Lesson>.unmodifiable(buildUnitLessons());

  /// 單元學習的單字範圍：單字 id → 到「第一次出現這個單字的單元」為止學過的全部單字。
  /// 單元測驗（含錯題重練）的干擾選項只從這個範圍挑，不會出現還沒學過的字。
  static final Map<String, Set<String>> _unitWordPools = _buildUnitWordPools();

  static Map<String, Set<String>> _buildUnitWordPools() {
    final pools = <String, Set<String>>{};
    final taught = <String>{};
    for (final unit in units) {
      final unitWords = <String>[
        for (final seed in unit.quizSeeds)
          if (seed.kind == QuizKind.wordMeaning ||
              seed.kind == QuizKind.meaningWord)
            seed.itemId,
      ];
      taught.addAll(unitWords);
      final snapshot = Set<String>.unmodifiable(taught);
      for (final id in unitWords) {
        pools.putIfAbsent(id, () => snapshot);
      }
    }
    return pools;
  }

  /// 單元學過的單字範圍；不是單元單字時回傳 null（代表不限制）。
  static Set<String>? unitWordPoolFor(String wordId) => _unitWordPools[wordId];

  /// 全部課程，依學習順序排列。
  static final List<Lesson> all =
      List<Lesson>.unmodifiable(<Lesson>[...hangul, ...units, ...grammar, ...casual]);

  static const List<PlannedLesson> planned = <PlannedLesson>[
    PlannedLesson(
      title: '單元 32 以後',
      summary: '尚未建立。單元 1～31 已涵蓋 TOPIK I 的主要溝通情境；之後視查核結果再決定是否往 TOPIK II 延伸。',
    ),
    PlannedLesson(
      title: '不規則活用（其餘）',
      summary: 'ㅅ、ㅎ 等其餘不規則變化（ㅂ、ㄷ、르 已在單元 23、28 學過）。',
    ),
    PlannedLesson(
      title: '職場與長輩用語（합니다體、尊敬說法）',
      summary: '已做好但暫時隱藏；先把日常禮貌對話練熟，之後再開啟。',
    ),
    PlannedLesson(
      title: 'TOPIK 題型練習',
      summary: '依 TOPIK I 的聽力、閱讀題型設計練習。尚未建立。',
    ),
  ];

  static Lesson _grammarLesson(
    GrammarLessonData data, [
    LessonGroup group = LessonGroup.grammar,
  ]) =>
      Lesson(
        id: 'grammar-${data.id}',
        group: group,
        title: data.title,
        summary: data.summary,
        cards: <LessonCard>[
          for (final intro in data.intros)
            LessonCard.concept(
              id: 'concept:${data.id}:${intro.id}',
              title: intro.title,
              paragraphs: intro.paragraphs,
            ),
          for (final point in data.points) LessonCard.grammar(point),
        ],
        quizSeeds: <QuizSeed>[
          for (final point in data.points)
            for (var i = 0; i < point.examples.length; i++)
              QuizSeed(QuizKind.grammarCloze, point.exampleId(i)),
        ],
      );

  static Lesson? byId(String id) {
    for (final lesson in all) {
      if (lesson.id == id) {
        return lesson;
      }
    }
    return null;
  }

  // ---- 韓文字母：用聽的學 ----

  static String _syl(String consonant, String vowel) =>
      Catalog.syllableOf(consonant, vowel).hangul;

  static SoundItem _vowelItem(String vowel) => SoundItem(
        display: vowel,
        speak: _syl('ㅇ', vowel),
        caption: _syl('ㅇ', vowel),
      );

  static SoundItem _consonantItem(String consonant, [String vowel = 'ㅏ']) =>
      SoundItem(
        display: _syl(consonant, vowel),
        speak: _syl(consonant, vowel),
        caption: '$consonant + $vowel',
      );

  static QuizSeed _listen(String consonant, String vowel) =>
      QuizSeed(QuizKind.listenSyllable, Catalog.syllableOf(consonant, vowel).id);

  static Lesson _vowelLesson() => Lesson(
        id: 'hangul-1',
        group: LessonGroup.hangul,
        title: '韓文字母（一）母音',
        summary: '用聽的認識 10 個基本母音。',
        cards: <LessonCard>[
          LessonCard.concept(
            id: 'h1:howto',
            title: '先聽，再看字',
            paragraphs: const <String>[
              '韓文字母是拼音文字：每個字母代表一個聲音，認得字母和聲音，就能唸出大部分的字。所以學字母最重要的是先聽、跟著念，再認字形。',
              '本課每個方塊點下去都會念出聲音。母音單獨不容易念，所以韓文會在母音前面放一個不發音的 ㅇ 當作佔位，例如 ㅏ 寫成「아」，念出來就是 ㅏ 的聲音。',
              '提醒：App 的聲音是電腦合成的，和真人發音會有些差別。可以搭配老師或影片的真人發音多聽。羅馬字只是輔助標記，不能當作發音的依據。',
            ],
          ),
          LessonCard.sound(
            id: 'h1:basic',
            title: '六個基本母音',
            paragraphs: const <String>[
              '依序點每一個聽三次，跟著念出來。',
              'ㅏ：嘴巴張大。ㅗ、ㅜ：嘴唇圓起來，ㅗ 的口型比 ㅜ 稍大。ㅣ：嘴角向兩側拉開。',
              'ㅓ 和 ㅡ 最容易搞混：ㅓ 嘴巴半開、嘴唇放鬆；ㅡ 嘴唇向兩側拉平、牙齒靠近。以上口型只是幫你找方向，聲音以聽到的為準。',
            ],
            items: <SoundItem>[
              _vowelItem('ㅏ'),
              _vowelItem('ㅓ'),
              _vowelItem('ㅗ'),
              _vowelItem('ㅜ'),
              _vowelItem('ㅡ'),
              _vowelItem('ㅣ'),
            ],
          ),
          LessonCard.sound(
            id: 'h1:y',
            title: '再加一劃：前面多一個「ㅣ」的音',
            paragraphs: const <String>[
              'ㅑ ㅕ ㅛ ㅠ 就是在 ㅏ ㅓ ㅗ ㅜ 上多加一劃，聲音也是在前面多了一個「ㅣ」的音：ㅑ ≈ ㅣ＋ㅏ，ㅕ ≈ ㅣ＋ㅓ，ㅛ ≈ ㅣ＋ㅗ，ㅠ ≈ ㅣ＋ㅜ。',
              '下面是兩兩對照：先聽左邊，再聽右邊，比較差在哪裡。',
            ],
            items: <SoundItem>[
              _vowelItem('ㅏ'),
              _vowelItem('ㅑ'),
              _vowelItem('ㅓ'),
              _vowelItem('ㅕ'),
              _vowelItem('ㅗ'),
              _vowelItem('ㅛ'),
              _vowelItem('ㅜ'),
              _vowelItem('ㅠ'),
            ],
          ),
        ],
        quizSeeds: <QuizSeed>[
          for (final v in const <String>[
            'ㅏ', 'ㅓ', 'ㅗ', 'ㅜ', 'ㅡ', 'ㅣ', 'ㅑ', 'ㅕ', 'ㅛ', 'ㅠ',
          ])
            _listen('ㅇ', v),
        ],
      );

  static Lesson _consonantLesson() => Lesson(
        id: 'hangul-2',
        group: LessonGroup.hangul,
        title: '韓文字母（二）基本子音與音節',
        summary: '用聽的認識 10 個基本子音，並學會子音＋母音變成音節。',
        cards: <LessonCard>[
          LessonCard.concept(
            id: 'h2:howto',
            title: '子音要搭配母音才念得出來',
            paragraphs: const <String>[
              '子音單獨發不出聲音，一定要搭配母音。所以本課每個子音都先搭配母音 ㅏ 一起念，例如 ㄱ ＋ ㅏ ＝ 가。',
              '不用背子音的「名稱」（例如 기역）。名稱只是稱呼字母用的，和字母在音節裡的聲音是兩回事。先記住「가 나 다」這些音節的聲音就好。',
            ],
          ),
          LessonCard.sound(
            id: 'h2:group1',
            title: 'ㄱ ㄴ ㄷ ㄹ ㅁ',
            paragraphs: const <String>[
              '先學這五個。ㄱ、ㄷ 在音節開頭的聲音比較輕，ㄹ 像舌尖輕輕彈一下。先聽再模仿，不用急著對照中文的音。',
            ],
            items: <SoundItem>[
              _consonantItem('ㄱ'),
              _consonantItem('ㄴ'),
              _consonantItem('ㄷ'),
              _consonantItem('ㄹ'),
              _consonantItem('ㅁ'),
            ],
          ),
          LessonCard.sound(
            id: 'h2:group2',
            title: 'ㅂ ㅅ ㅇ ㅈ ㅎ',
            paragraphs: const <String>[
              'ㅇ 放在音節開頭時不發音，只是佔位，所以 ㅇ ＋ ㅏ 的聲音和單獨的 ㅏ 一樣，都是「아」。（ㅇ 放在音節結尾才有 ng 的聲音，之後再學。）',
            ],
            items: <SoundItem>[
              _consonantItem('ㅂ'),
              _consonantItem('ㅅ'),
              _consonantItem('ㅇ'),
              _consonantItem('ㅈ'),
              _consonantItem('ㅎ'),
            ],
          ),
          LessonCard.sound(
            id: 'h2:block',
            title: '音節像一個方塊：子音在左，母音在右或下方',
            paragraphs: const <String>[
              '子音和母音組合成一個方塊，這個方塊就是一個音節。',
              'ㅏ ㅣ 這類直長形的母音寫在子音右邊：가、기。',
              'ㅗ ㅜ ㅡ 這類橫長形的母音寫在子音下面：고、구、그。',
              '同樣是 ㄱ，換不同的母音，聲音就不一樣。依序聽聽看。',
            ],
            items: <SoundItem>[
              _consonantItem('ㄱ', 'ㅏ'),
              _consonantItem('ㄱ', 'ㅣ'),
              _consonantItem('ㄱ', 'ㅗ'),
              _consonantItem('ㄱ', 'ㅜ'),
              _consonantItem('ㄱ', 'ㅡ'),
            ],
          ),
        ],
        quizSeeds: <QuizSeed>[
          for (final c in const <String>[
            'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅎ',
          ])
            _listen(c, 'ㅏ'),
          _listen('ㄱ', 'ㅣ'),
          _listen('ㄱ', 'ㅗ'),
          _listen('ㄱ', 'ㅜ'),
          _listen('ㄱ', 'ㅡ'),
        ],
      );

  static const List<String> _readingWordIds = <String>[
    'word:아이',
    'word:우유',
    'word:오이',
    'word:나무',
    'word:바지',
    'word:고기',
    'word:모자',
    'word:여자',
    'word:지도',
    'word:아버지',
    'word:어머니',
  ];

  static Lesson _readingLesson() {
    final words = <WordItem>[
      for (final id in _readingWordIds) Catalog.wordById(id)!,
    ];
    return Lesson(
      id: 'hangul-3',
      group: LessonGroup.hangul,
      title: '韓文字母（三）讀讀看',
      summary: '把學過的音節連起來，讀出簡單的字。',
      cards: <LessonCard>[
        LessonCard.concept(
          id: 'h3:howto',
          title: '你已經可以讀出簡單的字了',
          paragraphs: const <String>[
            '一個方塊是一個音節，一個詞由一到幾個方塊組成。把每個方塊的聲音連起來，就能唸出這個詞。例如 아이 ＝ 아 ＋ 이。',
            '下面的詞都只用到前兩課學過的字母。點下去聽整個詞的聲音，同時看每個方塊怎麼拼。',
          ],
        ),
        LessonCard.sound(
          id: 'h3:words',
          title: '試著讀這些詞',
          paragraphs: const <String>[
            '先自己拆開唸，再點下去對答案。',
          ],
          items: <SoundItem>[
            for (final w in words)
              SoundItem(display: w.hangul, speak: w.hangul, caption: w.meaning),
          ],
        ),
      ],
      quizSeeds: <QuizSeed>[
        for (final s in const <List<String>>[
          <String>['ㅈ', 'ㅣ'],
          <String>['ㄷ', 'ㅗ'],
          <String>['ㅁ', 'ㅜ'],
          <String>['ㅁ', 'ㅗ'],
          <String>['ㅂ', 'ㅓ'],
          <String>['ㅁ', 'ㅓ'],
          <String>['ㄴ', 'ㅣ'],
          <String>['ㅂ', 'ㅏ'],
        ])
          _listen(s[0], s[1]),
        for (final id in _readingWordIds.take(6))
          QuizSeed(QuizKind.wordMeaning, id),
      ],
    );
  }
}
