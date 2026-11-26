import 'dart:math';

import '../data/catalog.dart';
import '../data/content_models.dart';
import '../data/quiz_types.dart';
import 'meaning_tokens.dart';

/// 依教材資料出題。題目內容全部來自 [Catalog]，沒有另外寫死的答案。
class QuizGenerator {
  QuizGenerator({
    Random? random,
    Set<String>? Function(String wordId)? wordPoolFor,
  })  : _random = random ?? Random(),
        _wordPoolFor = wordPoolFor;

  final Random _random;

  /// 單字題干擾選項的範圍：回傳 null 代表不限制。
  /// App 裡用來讓單元單字只和「已經學過的單字」一起出題。
  final Set<String>? Function(String wordId)? _wordPoolFor;
  final Map<String, Set<String>> _tokenCache = <String, Set<String>>{};

  /// 同一個韓文寫法的所有單字（同形異義詞放在同一組）。
  late final Map<String, List<WordItem>> _sensesByHangul = () {
    final map = <String, List<WordItem>>{};
    for (final word in Catalog.words) {
      map.putIfAbsent(word.hangul, () => <WordItem>[]).add(word);
    }
    return map;
  }();

  /// 依種子出題；找不到對應教材時回傳 null。
  QuizQuestion? build(QuizSeed seed) {
    switch (seed.kind) {
      case QuizKind.letterRoman:
        return _letterRoman(seed.itemId);
      case QuizKind.letterName:
        return _letterName(seed.itemId);
      case QuizKind.syllableRoman:
        return _syllableRoman(seed.itemId);
      case QuizKind.syllableFromRoman:
        return _syllableFromRoman(seed.itemId);
      case QuizKind.wordMeaning:
        return _wordMeaning(seed.itemId);
      case QuizKind.meaningWord:
        return _meaningWord(seed.itemId);
      case QuizKind.listenSyllable:
        return _listenSyllable(seed.itemId);
      case QuizKind.grammarCloze:
        return _grammarCloze(seed.itemId);
    }
  }

  List<QuizQuestion> buildAll(Iterable<QuizSeed> seeds) {
    final questions = <QuizQuestion>[];
    for (final seed in seeds) {
      final question = build(seed);
      if (question != null) {
        questions.add(question);
      }
    }
    return questions;
  }

  /// 從一組種子中隨機抽 [count] 個出題（課後小測驗用）。
  List<QuizQuestion> fromSeeds(List<QuizSeed> seeds, {int count = 8}) {
    final pool = List<QuizSeed>.of(seeds)..shuffle(_random);
    return buildAll(pool.take(count));
  }

  /// 混合測驗：字母、音節、單字、文法隨機抽題，題目不重複。
  ///
  /// [wordIds]、[grammarExampleIds] 限制單字與文法題的出題範圍；
  /// 不給（null）代表全部教材，給空清單代表不出這類題目。
  List<QuizQuestion> mixed({
    int count = 10,
    Iterable<String>? wordIds,
    Iterable<String>? grammarExampleIds,
  }) =>
      buildAll(
        randomSeeds(
          count: count,
          wordIds: wordIds,
          grammarExampleIds: grammarExampleIds,
        ),
      );

  List<QuizSeed> randomSeeds({
    int count = 10,
    Iterable<String>? wordIds,
    Iterable<String>? grammarExampleIds,
  }) {
    final words = (wordIds ?? Catalog.words.map((w) => w.id)).toList();
    final grammar = (grammarExampleIds ?? Catalog.grammarExampleIds).toList();

    // 重複放入的題型代表被抽到的機會較高。
    final kinds = <QuizKind>[
      QuizKind.letterRoman,
      QuizKind.letterName,
      QuizKind.syllableRoman,
      QuizKind.syllableFromRoman,
      if (words.isNotEmpty) ...<QuizKind>[
        QuizKind.wordMeaning,
        QuizKind.wordMeaning,
        QuizKind.meaningWord,
        QuizKind.meaningWord,
      ],
      if (grammar.isNotEmpty) ...<QuizKind>[
        QuizKind.grammarCloze,
        QuizKind.grammarCloze,
        QuizKind.grammarCloze,
      ],
    ];

    final seen = <String>{};
    final seeds = <QuizSeed>[];
    var guard = 0;
    while (seeds.length < count && guard < count * 30) {
      guard++;
      final kind = _pick(kinds);
      final seed = _randomSeed(kind, words, grammar);
      if (seen.add(seed.key)) {
        seeds.add(seed);
      }
    }
    return seeds;
  }

  /// 主題單字測驗：從某個主題的單字抽題（單字→中文、中文→單字）。
  List<QuizQuestion> topicQuiz(String topicId, {int count = 10}) {
    final topic = Catalog.topicById(topicId);
    if (topic == null) {
      return <QuizQuestion>[];
    }
    final words = List<WordItem>.of(topic.words)..shuffle(_random);
    final seeds = <QuizSeed>[
      for (final word in words.take(count))
        QuizSeed(
          _random.nextBool() ? QuizKind.wordMeaning : QuizKind.meaningWord,
          word.id,
        ),
    ];
    return buildAll(seeds);
  }

  /// 文法填空測驗：從指定的例句 id 抽題。
  List<QuizQuestion> grammarQuiz(
    Iterable<String> exampleIds, {
    int count = 10,
  }) {
    final pool = exampleIds.toList()..shuffle(_random);
    return buildAll(
      pool.take(count).map((id) => QuizSeed(QuizKind.grammarCloze, id)),
    );
  }

  QuizSeed _randomSeed(
    QuizKind kind,
    List<String> wordIds,
    List<String> grammarIds,
  ) {
    switch (kind) {
      case QuizKind.letterRoman:
        final pool = Catalog.letters.where((l) => l.hasRoman).toList();
        return QuizSeed(kind, _pick(pool).id);
      case QuizKind.letterName:
        return QuizSeed(kind, _pick(Catalog.letters).id);
      case QuizKind.syllableRoman:
      case QuizKind.syllableFromRoman:
      case QuizKind.listenSyllable:
        return QuizSeed(kind, _pick(Catalog.syllables).id);
      case QuizKind.wordMeaning:
      case QuizKind.meaningWord:
        return QuizSeed(kind, _pick(wordIds));
      case QuizKind.grammarCloze:
        return QuizSeed(kind, _pick(grammarIds));
    }
  }

  T _pick<T>(List<T> items) => items[_random.nextInt(items.length)];

  // ---- 各題型 ----

  QuizQuestion? _letterRoman(String itemId) {
    final letter = Catalog.letterById(itemId);
    if (letter == null || !letter.hasRoman) {
      return null;
    }
    final pool = Catalog.letters
        .where((l) => l.type == letter.type && l.hasRoman)
        .map((l) => l.roman)
        .toList();
    final built = _assemble(letter.roman, pool);
    final isConsonant = letter.type == LetterType.consonant;
    return QuizQuestion(
      kind: QuizKind.letterRoman,
      itemId: letter.id,
      prompt: isConsonant
          ? '子音「${letter.jamo}」在音節開頭的羅馬字標記是？'
          : '母音「${letter.jamo}」的羅馬字標記是？',
      stimulus: letter.jamo,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: '「${letter.jamo}」的羅馬字標記是 ${letter.roman}'
          '${isConsonant ? '（音節開頭）' : ''}。'
          '羅馬字只是輔助標記，並不等於實際發音，請搭配音檔練習。',
    );
  }

  QuizQuestion? _letterName(String itemId) {
    final letter = Catalog.letterById(itemId);
    if (letter == null) {
      return null;
    }
    final pool = Catalog.letters
        .where((l) => l.type == letter.type)
        .map((l) => l.name)
        .toList();
    final built = _assemble(letter.name, pool);
    return QuizQuestion(
      kind: QuizKind.letterName,
      itemId: letter.id,
      prompt: '「${letter.jamo}」的名稱是？',
      stimulus: letter.jamo,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: '「${letter.jamo}」的名稱是 ${letter.name}。'
          '名稱是稱呼字母用的，和字母在音節中的發音是兩回事。',
    );
  }

  QuizQuestion? _syllableRoman(String itemId) {
    final syllable = Catalog.syllableById(itemId);
    if (syllable == null) {
      return null;
    }
    final built = _assemble(
      syllable.roman,
      Catalog.syllables.map((s) => s.roman).toList(),
      preferred: _similar(syllable).map((s) => s.roman).toList(),
    );
    return QuizQuestion(
      kind: QuizKind.syllableRoman,
      itemId: syllable.id,
      prompt: '音節「${syllable.hangul}」的羅馬字標記是？',
      stimulus: syllable.hangul,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: _syllableExplanation(syllable),
    );
  }

  QuizQuestion? _syllableFromRoman(String itemId) {
    final syllable = Catalog.syllableById(itemId);
    if (syllable == null) {
      return null;
    }
    final built = _assemble(
      syllable.hangul,
      Catalog.syllables.map((s) => s.hangul).toList(),
      preferred: _similar(syllable).map((s) => s.hangul).toList(),
    );
    return QuizQuestion(
      kind: QuizKind.syllableFromRoman,
      itemId: syllable.id,
      prompt: '哪一個音節的羅馬字標記是「${syllable.roman}」？',
      stimulus: syllable.roman,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: _syllableExplanation(syllable),
    );
  }

  /// 聽音辨字：干擾項只取已經教過的基本字母（平音子音 × 基本母音），
  /// 避免出現還沒學過、或電腦語音很難分辨的送氣音與濃音。
  static const Set<String> _listenInitials = <String>{
    'ㅇ', 'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅈ', 'ㅎ',
  };

  QuizQuestion? _listenSyllable(String itemId) {
    final syllable = Catalog.syllableById(itemId);
    if (syllable == null) {
      return null;
    }
    final pool = Catalog.syllables
        .where((s) => _listenInitials.contains(s.initial.jamo))
        .toList();
    final built = _assemble(
      syllable.hangul,
      pool.map((s) => s.hangul).toList(),
      preferred: _similar(syllable)
          .where((s) => _listenInitials.contains(s.initial.jamo))
          .map((s) => s.hangul)
          .toList(),
    );
    return QuizQuestion(
      kind: QuizKind.listenSyllable,
      itemId: syllable.id,
      prompt: '按下喇叭聽聲音，選出你聽到的音節。',
      options: built.options,
      correctIndex: built.correctIndex,
      explanation:
          '你聽到的是「${syllable.hangul}」（${syllable.initial.jamo} + ${syllable.vowel.jamo}）。',
      speakText: syllable.hangul,
    );
  }

  QuizQuestion? _wordMeaning(String itemId) {
    final word = Catalog.wordById(itemId);
    if (word == null) {
      return null;
    }
    final others = _distractorWords(word);
    final built = _assemble(
      word.meaning,
      others.map((w) => w.meaning).toList(),
      preferred: _sameTopic(word, others).map((w) => w.meaning).toList(),
    );
    return QuizQuestion(
      kind: QuizKind.wordMeaning,
      itemId: word.id,
      prompt: '「${word.hangul}」的意思是？',
      stimulus: word.hangul,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: '「${word.hangul}」的意思是「${word.meaning}」。'
          '${_hanjaNote(word)}${_homographNote(word)}'
          '例句：${word.example}（${word.exampleMeaning}）',
      speakText: word.example,
      // 選項是中文意思：作答後在每個選項底下標出它是哪個韓文單字。
      optionNotes: <String?>[
        for (var i = 0; i < built.options.length; i++)
          i == built.correctIndex
              ? word.hangul
              : _joinUnique(
                  others
                      .where((w) => w.meaning == built.options[i])
                      .map((w) => w.hangul),
                  '、',
                ),
      ],
    );
  }

  QuizQuestion? _meaningWord(String itemId) {
    final word = Catalog.wordById(itemId);
    if (word == null) {
      return null;
    }
    final others = _distractorWords(word);
    final built = _assemble(
      word.hangul,
      others.map((w) => w.hangul).toList(),
      preferred: _sameTopic(word, others).map((w) => w.hangul).toList(),
    );
    return QuizQuestion(
      kind: QuizKind.meaningWord,
      itemId: word.id,
      prompt: '「${word.meaning}」的韓文是？',
      stimulus: word.meaning,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: '「${word.meaning}」的韓文是 ${word.hangul}。'
          '${_hanjaNote(word)}${_homographNote(word)}'
          '例句：${word.example}（${word.exampleMeaning}）',
      speakText: word.example,
      // 選項是韓文單字：作答後在每個選項底下標出它的意思。
      optionNotes: <String?>[
        for (var i = 0; i < built.options.length; i++)
          i == built.correctIndex
              ? word.meaning
              : _joinUnique(
                  others
                      .where((w) => w.hangul == built.options[i])
                      .map((w) => w.meaning),
                  ' / ',
                ),
      ],
    );
  }

  QuizQuestion? _grammarCloze(String itemId) {
    final ref = Catalog.grammarExample(itemId);
    if (ref == null) {
      return null;
    }
    final example = ref.example;
    final built = _assemble(example.answer, example.wrong);
    return QuizQuestion(
      kind: QuizKind.grammarCloze,
      itemId: itemId,
      prompt: '${example.zh}\n文法：${ref.point.title}\n空格要填什麼？',
      stimulus: example.cloze,
      options: built.options,
      correctIndex: built.correctIndex,
      explanation: '完整句子：${example.plain}（${example.zh}）\n'
          '接續方式：${ref.point.form}',
      speakText: example.plain,
    );
  }

  // ---- 單字題的干擾選項 ----

  /// 中文意思的「核心詞」（規則見 [meaningTokens]），加快取。
  Set<String> _meaningTokens(String meaning) =>
      _tokenCache.putIfAbsent(meaning, () => meaningTokens(meaning));

  /// 兩個單字能不能同時出現在同一題的選項裡。
  ///
  /// 寫法相同就不行；意思重疊也不行。同形異義詞要把「所有意思」都算進去，
  /// 例如 팔 有「手臂」和「八（漢字數詞）」，題目問 팔 時，
  /// 「八（固有數詞）」（여덟）也算對，所以不能當干擾選項。
  /// 這樣的比較偶爾會多排除一些候選，但不會讓兩個選項都對。
  bool _overlaps(WordItem a, WordItem b) {
    if (a.hangul == b.hangul) {
      return true;
    }
    for (final x in _sensesByHangul[a.hangul] ?? <WordItem>[a]) {
      final xTokens = _meaningTokens(x.meaning);
      for (final y in _sensesByHangul[b.hangul] ?? <WordItem>[b]) {
        if (xTokens.intersection(_meaningTokens(y.meaning)).isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  /// 可以當干擾選項的單字：寫法相同（同形異義詞）或意思重疊的都排除，
  /// 避免出現兩個都算對的選項。
  /// 有設定學習範圍時，只從範圍內的單字挑。
  List<WordItem> _distractorWords(WordItem word) {
    final pool = _wordPoolFor?.call(word.id);
    return Catalog.words
        .where((w) => !_overlaps(word, w))
        .where((w) => pool == null || pool.contains(w.id))
        .toList();
  }

  List<WordItem> _sameTopic(WordItem word, List<WordItem> candidates) {
    final topic = Catalog.topicOfWord(word.id);
    if (topic == null) {
      return <WordItem>[];
    }
    final ids = topic.words.map((w) => w.id).toSet();
    return candidates.where((w) => ids.contains(w.id)).toList();
  }

  /// 去掉重複後用 [separator] 接起來；沒有內容時回傳 null。
  String? _joinUnique(Iterable<String> items, String separator) {
    final unique = items.toSet();
    return unique.isEmpty ? null : unique.join(separator);
  }

  String _hanjaNote(WordItem word) =>
      word.hanja == null ? '' : '漢字詞：${word.hanja}。';

  String _homographNote(WordItem word) {
    final others = Catalog.homographsOf(word);
    if (others.isEmpty) {
      return '';
    }
    final meanings = others.map((w) => w.meaning).join('、');
    return '「${word.hangul}」還有其他意思：$meanings。';
  }

  // ---- 工具 ----

  String _syllableExplanation(Syllable syllable) {
    final romanPart = syllable.roman.isEmpty ? '（無）' : syllable.roman;
    return '「${syllable.hangul}」＝ ${syllable.initial.jamo} + '
        '${syllable.vowel.jamo}，羅馬字標記為 $romanPart。'
        '羅馬字只是輔助標記，並不等於實際發音。';
  }

  /// 與 [syllable] 共用子音或母音的其他音節，用來做更有鑑別度的選項。
  List<Syllable> _similar(Syllable syllable) {
    return Catalog.syllables
        .where(
          (s) =>
              s.id != syllable.id &&
              (s.initial.jamo == syllable.initial.jamo ||
                  s.vowel.jamo == syllable.vowel.jamo),
        )
        .toList();
  }

  /// 組出 4 個不重複的選項（正確答案 + 3 個干擾項），並隨機排序。
  /// [preferred] 裡的候選會優先當干擾項。
  ({List<String> options, int correctIndex}) _assemble(
    String correct,
    List<String> candidates, {
    List<String> preferred = const <String>[],
    int count = 4,
  }) {
    final distractors = <String>[];

    void addFrom(Iterable<String> source) {
      final shuffled = source.toSet().toList()..shuffle(_random);
      for (final item in shuffled) {
        if (distractors.length >= count - 1) {
          return;
        }
        if (item != correct && !distractors.contains(item)) {
          distractors.add(item);
        }
      }
    }

    addFrom(preferred);
    addFrom(candidates);

    final options = <String>[correct, ...distractors]..shuffle(_random);
    return (options: options, correctIndex: options.indexOf(correct));
  }
}
