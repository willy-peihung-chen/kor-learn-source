/// 字母資料的查核狀態（只用於字母；App 畫面不再逐項顯示，
/// 教材整體的說明集中在「教材說明」頁，查核紀錄見 docs/content_sources.md）。
enum ContentStatus {
  verified('已查核'),
  pending('待查核');

  const ContentStatus(this.label);
  final String label;
}

enum LetterType { vowel, consonant }

/// 一個韓文字母（母音或子音）。
class HangulLetter {
  const HangulLetter({
    required this.jamo,
    required this.name,
    required this.roman,
    required this.type,
    required this.index,
    required this.romanStatus,
    this.nameStatus = ContentStatus.pending,
    this.note,
  });

  /// 字母本身，例如 ㅏ。
  final String jamo;

  /// 字母名稱，例如 기역。
  final String name;

  /// 國語羅馬字標記法的標記（音節開頭）；空字串代表沒有（ㅇ）。
  final String roman;

  final LetterType type;

  /// Unicode 韓文音節組合用的索引：子音為初聲索引，母音為中聲索引。
  final int index;

  final ContentStatus romanStatus;
  final ContentStatus nameStatus;

  /// 補充說明。
  final String? note;

  String get id => 'letter:$jamo';
  bool get hasRoman => roman.isNotEmpty;
}

/// 「子音＋母音」組成的音節（第一版不含尾音）。
class Syllable {
  const Syllable(this.initial, this.vowel);

  final HangulLetter initial;
  final HangulLetter vowel;

  /// 依 Unicode 韓文音節公式組合：0xAC00 + (初聲 * 21 + 中聲) * 28。
  String get hangul =>
      String.fromCharCode(0xAC00 + (initial.index * 21 + vowel.index) * 28);

  String get roman => '${initial.roman}${vowel.roman}';

  String get id => 'syl:$hangul';
}

/// 單字卡項目。
///
/// 動詞與形容詞以原形（다 結尾）收錄，例句使用實際的活用形。
class WordItem {
  const WordItem(
    this.hangul,
    this.meaning,
    this.example,
    this.exampleMeaning, {
    this.hanja,
    this.sense,
    this.note,
  });

  final String hangul;
  final String meaning;
  final String example;
  final String exampleMeaning;

  /// 漢字語的漢字（採台灣常用的正體字）；非漢字語為 null。
  /// 韓文與中文有很多相通的漢字詞，可以用來輔助記憶，但意思不一定與中文完全相同。
  final String? hanja;

  /// 同形異義詞的區分標記（例如 배 的「腹」「梨」「船」）。
  /// 沒有同形詞時為 null，id 維持 `word:韓文`。
  final String? sense;

  /// 高頻單字的補充說明（用法、語感、和相近詞的差別）；沒有時為 null。
  final String? note;

  String get id => sense == null ? 'word:$hangul' : 'word:$hangul#$sense';

  /// 例句不是敬語（해요體／합니다體）時為 true，畫面上會明確標示「半語」。
  bool get isPlainStyleExample {
    final text = example.replaceAll(RegExp(r'[.?!。！？\s]+$'), '');
    return !RegExp(r'(요|니다|니까|십시오)$').hasMatch(text);
  }
}

/// 一個單字主題（例如「食物與飲料」）。
class WordTopic {
  const WordTopic({
    required this.id,
    required this.title,
    required this.words,
  });

  final String id;
  final String title;
  final List<WordItem> words;
}

/// 文法例句。[ko] 中用中括號標出要考填空的部分，例如「저[는] 학생이에요.」。
class GrammarExample {
  const GrammarExample(this.ko, this.zh, this.wrong);

  final String ko;
  final String zh;

  /// 填空題的錯誤選項（3 個）。
  final List<String> wrong;

  String get answer => ko.substring(ko.indexOf('[') + 1, ko.indexOf(']'));

  String get before => ko.substring(0, ko.indexOf('['));

  String get after => ko.substring(ko.indexOf(']') + 1);

  /// 完整句子（不含中括號）。
  String get plain => '$before$answer$after';

  /// 挖空的句子。
  String get cloze => '${before}____$after';
}

/// 一個文法點。
class GrammarPoint {
  const GrammarPoint({
    required this.id,
    required this.title,
    required this.form,
    required this.explanation,
    required this.examples,
  });

  final String id;

  /// 例如「은/는（主題助詞）」。
  final String title;

  /// 接續方式或公式的簡短摘要。
  final String form;

  final List<String> explanation;
  final List<GrammarExample> examples;

  String get cardId => 'grammar:$id';

  String exampleId(int index) => 'gram:$id:$index';
}

/// 文法課程中的說明卡（不屬於單一文法點）。
class GrammarIntro {
  const GrammarIntro({required this.id, required this.title, required this.paragraphs});

  final String id;
  final String title;
  final List<String> paragraphs;
}

/// 一個文法課程：幾張說明卡，加上數個文法點。
class GrammarLessonData {
  const GrammarLessonData({
    required this.id,
    required this.title,
    required this.summary,
    required this.intros,
    required this.points,
  });

  final String id;
  final String title;
  final String summary;
  final List<GrammarIntro> intros;
  final List<GrammarPoint> points;
}
