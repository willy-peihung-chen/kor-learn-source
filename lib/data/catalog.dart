import 'content_models.dart';
import 'grammar/all_grammar.dart';
import 'hangul_letters.dart';
import 'vocab/all_topics.dart';
import 'words.dart';

/// 某個文法例句與它所屬的文法點。
typedef GrammarExampleRef = ({
  GrammarPoint point,
  int index,
  GrammarExample example,
});

/// 教材的查詢入口：用 id 找字母、音節、單字、文法。
class Catalog {
  Catalog._();

  static final List<HangulLetter> letters = List<HangulLetter>.unmodifiable(
    <HangulLetter>[...hangulVowels, ...hangulConsonants],
  );

  static final List<WordItem> words =
      List<WordItem>.unmodifiable(vocabularyWords);

  static final List<WordTopic> topics =
      List<WordTopic>.unmodifiable(allWordTopics);

  static final List<GrammarLessonData> grammarLessons =
      List<GrammarLessonData>.unmodifiable(allGrammarLessons);

  /// 可用於練習的音節（子音 × 母音）。
  ///
  /// 教學上的取捨：ㅈ、ㅊ 搭配 ㅑ ㅕ ㅛ ㅠ 的組合不放進練習，
  /// 避免初學階段的混淆。這不代表這些音節不存在。
  static final List<Syllable> syllables =
      List<Syllable>.unmodifiable(_buildSyllables());

  static final Map<String, HangulLetter> _letterById =
      <String, HangulLetter>{for (final l in letters) l.id: l};

  static final Map<String, HangulLetter> _letterByJamo =
      <String, HangulLetter>{for (final l in letters) l.jamo: l};

  static final Map<String, WordItem> _wordById =
      <String, WordItem>{for (final w in words) w.id: w};

  static final Map<String, WordTopic> _topicById =
      <String, WordTopic>{for (final t in topics) t.id: t};

  static final Map<String, WordTopic> _topicByWordId = <String, WordTopic>{
    for (final t in topics)
      for (final w in t.words) w.id: t,
  };

  static final Map<String, Syllable> _syllableById =
      <String, Syllable>{for (final s in syllables) s.id: s};

  static final List<GrammarPoint> grammarPoints =
      List<GrammarPoint>.unmodifiable(
    <GrammarPoint>[
      for (final lesson in grammarLessons) ...lesson.points,
    ],
  );

  static final Map<String, GrammarPoint> _pointById =
      <String, GrammarPoint>{for (final p in grammarPoints) p.id: p};

  /// 所有文法例句的 id（`gram:<文法點>:<序號>`）。
  static final List<String> grammarExampleIds = List<String>.unmodifiable(
    <String>[
      for (final p in grammarPoints)
        for (var i = 0; i < p.examples.length; i++) p.exampleId(i),
    ],
  );

  static HangulLetter? letterById(String id) => _letterById[id];

  static WordItem? wordById(String id) => _wordById[id];

  static Syllable? syllableById(String id) => _syllableById[id];

  static WordTopic? topicById(String id) => _topicById[id];

  /// 單字所屬的主題；找不到時為 null。
  static WordTopic? topicOfWord(String wordId) => _topicByWordId[wordId];

  static GrammarPoint? grammarPointById(String id) => _pointById[id];

  /// 文法點所在的文法課；找不到時為 null。
  static GrammarLessonData? grammarLessonOfPoint(String pointId) {
    for (final lesson in grammarLessons) {
      if (lesson.points.any((p) => p.id == pointId)) {
        return lesson;
      }
    }
    return null;
  }

  /// 同形異義詞：與 [word] 韓文寫法相同、但意思不同的其他單字。
  static List<WordItem> homographsOf(WordItem word) => words
      .where((w) => w.hangul == word.hangul && w.id != word.id)
      .toList();

  /// 由例句 id 找到文法點與例句；格式錯誤或找不到時回傳 null。
  static GrammarExampleRef? grammarExample(String exampleId) {
    final parts = exampleId.split(':');
    if (parts.length != 3 || parts[0] != 'gram') {
      return null;
    }
    final point = _pointById[parts[1]];
    final index = int.tryParse(parts[2]);
    if (point == null ||
        index == null ||
        index < 0 ||
        index >= point.examples.length) {
      return null;
    }
    return (point: point, index: index, example: point.examples[index]);
  }

  /// 以字母本身（例如 'ㄱ'、'ㅏ'）組出音節。
  static Syllable syllableOf(String consonant, String vowel) {
    final c = _letterByJamo[consonant];
    final v = _letterByJamo[vowel];
    if (c == null ||
        v == null ||
        c.type != LetterType.consonant ||
        v.type != LetterType.vowel) {
      throw ArgumentError('Unknown consonant/vowel pair: $consonant $vowel');
    }
    return Syllable(c, v);
  }

  static List<Syllable> _buildSyllables() {
    const palatalInitials = <String>{'ㅈ', 'ㅊ'};
    const yVowels = <String>{'ㅑ', 'ㅕ', 'ㅛ', 'ㅠ'};
    final result = <Syllable>[];
    for (final c in hangulConsonants) {
      for (final v in hangulVowels) {
        if (palatalInitials.contains(c.jamo) && yVowels.contains(v.jamo)) {
          continue;
        }
        result.add(Syllable(c, v));
      }
    }
    return result;
  }
}
