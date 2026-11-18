// 韓文四十音字母表（21 個母音 + 19 個子音）的排列資料。
//
// 只負責「怎麼分組、怎麼排」，與課程和測驗的字母資料（hangul_letters.dart）分開：
// 課程只教基本字母，這張表額外收錄複合母音與濃音，供查閱與點按聽音。
//
// 名稱與羅馬字標記皆為自行整理；其中基本字母的資料與 hangul_letters.dart 相同，
// 複合母音與濃音尚未逐項對照官方資料（見「教材說明」）。

enum ChartLetterType { vowel, consonant }

class ChartLetter {
  const ChartLetter(this.jamo, this.name, this.roman, this.type);

  /// 字母本身，例如 ㅏ、ㄱ。
  final String jamo;

  /// 字母名稱，例如 기역；母音的名稱就是加上 ㅇ 的音節（아）。
  final String name;

  /// 國語羅馬字標記法的標記（音節開頭）；沒有標記時為空字串（ㅇ）。
  final String roman;

  final ChartLetterType type;

  bool get isVowel => type == ChartLetterType.vowel;
}

ChartLetter _v(String jamo, String name, String roman) =>
    ChartLetter(jamo, name, roman, ChartLetterType.vowel);

ChartLetter _c(String jamo, String name, String roman) =>
    ChartLetter(jamo, name, roman, ChartLetterType.consonant);

/// 母音的一個分組（一行）。
class VowelGroup {
  const VowelGroup(this.title, this.hint, this.letters);

  final String title;
  final String hint;
  final List<ChartLetter> letters;
}

/// 子音表的一列：同一組的 平音／送氣音／濃音。沒有的欄位為 null。
class ConsonantRow {
  const ConsonantRow(this.plain, this.aspirated, this.tense);

  final ChartLetter? plain;
  final ChartLetter? aspirated;
  final ChartLetter? tense;
}

// ---- 母音 ----

final ChartLetter _a = _v('ㅏ', '아', 'a');
final ChartLetter _eo = _v('ㅓ', '어', 'eo');
final ChartLetter _o = _v('ㅗ', '오', 'o');
final ChartLetter _u = _v('ㅜ', '우', 'u');
final ChartLetter _eu = _v('ㅡ', '으', 'eu');
final ChartLetter _i = _v('ㅣ', '이', 'i');

final List<VowelGroup> vowelGroups = <VowelGroup>[
  VowelGroup('基本母音（6）', '先認這 6 個，其他母音都是從它們變出來的。', <ChartLetter>[
    _a,
    _eo,
    _o,
    _u,
    _eu,
    _i,
  ]),
  VowelGroup('加一劃的 Y 母音（4）', '在 ㅏ ㅓ ㅗ ㅜ 上多加一劃，聲音前面多一個 y。排在上一行同一欄的下面。',
      <ChartLetter>[
    _v('ㅑ', '야', 'ya'),
    _v('ㅕ', '여', 'yeo'),
    _v('ㅛ', '요', 'yo'),
    _v('ㅠ', '유', 'yu'),
  ]),
  VowelGroup('ㅐ ㅔ 一組（4）', 'ㅐ = ㅏ+ㅣ，ㅔ = ㅓ+ㅣ；ㅒ ㅖ 是它們加上 Y 的版本。', <ChartLetter>[
    _v('ㅐ', '애', 'ae'),
    _v('ㅔ', '에', 'e'),
    _v('ㅒ', '얘', 'yae'),
    _v('ㅖ', '예', 'ye'),
  ]),
  VowelGroup('組合母音（7）',
      'ㅘ = ㅗ+ㅏ、ㅙ = ㅗ+ㅐ、ㅚ = ㅗ+ㅣ、ㅝ = ㅜ+ㅓ、ㅞ = ㅜ+ㅔ、ㅟ = ㅜ+ㅣ、ㅢ = ㅡ+ㅣ。',
      <ChartLetter>[
    _v('ㅘ', '와', 'wa'),
    _v('ㅙ', '왜', 'wae'),
    _v('ㅚ', '외', 'oe'),
    _v('ㅝ', '워', 'wo'),
    _v('ㅞ', '웨', 'we'),
    _v('ㅟ', '위', 'wi'),
    _v('ㅢ', '의', 'ui'),
  ]),
];

// ---- 子音 ----

/// 子音表：每一列是一組形狀相近的字母，由左至右是 平音、送氣音、濃音。
final List<ConsonantRow> consonantRows = <ConsonantRow>[
  ConsonantRow(
    _c('ㄱ', '기역', 'g'),
    _c('ㅋ', '키읔', 'k'),
    _c('ㄲ', '쌍기역', 'kk'),
  ),
  ConsonantRow(
    _c('ㄷ', '디귿', 'd'),
    _c('ㅌ', '티읕', 't'),
    _c('ㄸ', '쌍디귿', 'tt'),
  ),
  ConsonantRow(
    _c('ㅂ', '비읍', 'b'),
    _c('ㅍ', '피읖', 'p'),
    _c('ㅃ', '쌍비읍', 'pp'),
  ),
  ConsonantRow(
    _c('ㅈ', '지읒', 'j'),
    _c('ㅊ', '치읓', 'ch'),
    _c('ㅉ', '쌍지읒', 'jj'),
  ),
  ConsonantRow(
    _c('ㅅ', '시옷', 's'),
    null,
    _c('ㅆ', '쌍시옷', 'ss'),
  ),
];

/// 不屬於上面三組的子音。
final List<ChartLetter> otherConsonants = <ChartLetter>[
  _c('ㄴ', '니은', 'n'),
  _c('ㅁ', '미음', 'm'),
  _c('ㅇ', '이응', ''),
  _c('ㄹ', '리을', 'r'),
  _c('ㅎ', '히읗', 'h'),
];

/// 全部 40 個字母（母音在前、子音在後），供測試與查詢使用。
final List<ChartLetter> allChartLetters = <ChartLetter>[
  for (final g in vowelGroups) ...g.letters,
  for (final r in consonantRows) ...<ChartLetter>[
    if (r.plain != null) r.plain!,
    if (r.aspirated != null) r.aspirated!,
    if (r.tense != null) r.tense!,
  ],
  ...otherConsonants,
];
