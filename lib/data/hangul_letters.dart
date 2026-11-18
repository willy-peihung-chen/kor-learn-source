import 'content_models.dart';

// 教材資料：與 UI 完全分離。
//
// 查核狀態說明（詳見 docs/content_sources.md）：
// - romanStatus = verified：該字母的羅馬字標記，已對照國立國語院網站上的
//   「國語羅馬字標記法」說明頁面。
// - nameStatus：字母名稱目前只有二手來源交叉對照，沒有取得官方規範原文，
//   所以全部維持 pending。
// - note 為自行撰寫的補充說明，一律視為待查核。

const String _noteEo = 'ㅓ（eo）與 ㅗ（o）形狀相近、聲音也容易混淆，是初學者常見的混淆組合，請搭配音檔反覆聽辨。';
const String _noteEu = 'ㅡ（eu）與 ㅜ（u）容易混淆，請搭配音檔反覆聽辨。';

const List<HangulLetter> hangulVowels = <HangulLetter>[
  HangulLetter(
    jamo: 'ㅏ',
    name: '아',
    roman: 'a',
    type: LetterType.vowel,
    index: 0,
    romanStatus: ContentStatus.verified,
  ),
  HangulLetter(
    jamo: 'ㅑ',
    name: '야',
    roman: 'ya',
    type: LetterType.vowel,
    index: 2,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㅓ',
    name: '어',
    roman: 'eo',
    type: LetterType.vowel,
    index: 4,
    romanStatus: ContentStatus.verified,
    note: _noteEo,
  ),
  HangulLetter(
    jamo: 'ㅕ',
    name: '여',
    roman: 'yeo',
    type: LetterType.vowel,
    index: 6,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㅗ',
    name: '오',
    roman: 'o',
    type: LetterType.vowel,
    index: 8,
    romanStatus: ContentStatus.verified,
    note: _noteEo,
  ),
  HangulLetter(
    jamo: 'ㅛ',
    name: '요',
    roman: 'yo',
    type: LetterType.vowel,
    index: 12,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㅜ',
    name: '우',
    roman: 'u',
    type: LetterType.vowel,
    index: 13,
    romanStatus: ContentStatus.verified,
    note: _noteEu,
  ),
  HangulLetter(
    jamo: 'ㅠ',
    name: '유',
    roman: 'yu',
    type: LetterType.vowel,
    index: 17,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㅡ',
    name: '으',
    roman: 'eu',
    type: LetterType.vowel,
    index: 18,
    romanStatus: ContentStatus.verified,
    note: _noteEu,
  ),
  HangulLetter(
    jamo: 'ㅣ',
    name: '이',
    roman: 'i',
    type: LetterType.vowel,
    index: 20,
    romanStatus: ContentStatus.verified,
  ),
];

const List<HangulLetter> hangulConsonants = <HangulLetter>[
  HangulLetter(
    jamo: 'ㄱ',
    name: '기역',
    roman: 'g',
    type: LetterType.consonant,
    index: 0,
    romanStatus: ContentStatus.verified,
    note: 'ㄱ 在母音前標記為 g，在音節結尾標記為 k（國語羅馬字標記法）。'
        '羅馬字只是標記，實際發音請搭配音檔。',
  ),
  HangulLetter(
    jamo: 'ㄴ',
    name: '니은',
    roman: 'n',
    type: LetterType.consonant,
    index: 2,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㄷ',
    name: '디귿',
    roman: 'd',
    type: LetterType.consonant,
    index: 3,
    romanStatus: ContentStatus.verified,
    note: 'ㄷ 在母音前標記為 d，在音節結尾標記為 t。',
  ),
  HangulLetter(
    jamo: 'ㄹ',
    name: '리을',
    roman: 'r',
    type: LetterType.consonant,
    index: 5,
    romanStatus: ContentStatus.verified,
    note: 'ㄹ 在母音前標記為 r，在子音前或詞尾標記為 l。'
        '這只是標記規則；實際發音的細節留待後續課程。',
  ),
  HangulLetter(
    jamo: 'ㅁ',
    name: '미음',
    roman: 'm',
    type: LetterType.consonant,
    index: 6,
    romanStatus: ContentStatus.pending,
  ),
  HangulLetter(
    jamo: 'ㅂ',
    name: '비읍',
    roman: 'b',
    type: LetterType.consonant,
    index: 7,
    romanStatus: ContentStatus.verified,
    note: 'ㅂ 在母音前標記為 b，在音節結尾標記為 p。',
  ),
  HangulLetter(
    jamo: 'ㅅ',
    name: '시옷',
    roman: 's',
    type: LetterType.consonant,
    index: 9,
    romanStatus: ContentStatus.verified,
  ),
  HangulLetter(
    jamo: 'ㅇ',
    name: '이응',
    roman: '',
    type: LetterType.consonant,
    index: 11,
    romanStatus: ContentStatus.pending,
    note: 'ㅇ 在音節開頭不發音，只是佔位（例：아）；'
        '放在音節結尾（尾音）時發 ng 的音（例：강）。',
  ),
  HangulLetter(
    jamo: 'ㅈ',
    name: '지읒',
    roman: 'j',
    type: LetterType.consonant,
    index: 12,
    romanStatus: ContentStatus.verified,
  ),
  HangulLetter(
    jamo: 'ㅊ',
    name: '치읓',
    roman: 'ch',
    type: LetterType.consonant,
    index: 14,
    romanStatus: ContentStatus.verified,
    note: 'ㅊ 屬於「送氣音」，與 ㅈ 成對。',
  ),
  HangulLetter(
    jamo: 'ㅋ',
    name: '키읔',
    roman: 'k',
    type: LetterType.consonant,
    index: 15,
    romanStatus: ContentStatus.verified,
    note: 'ㅋ、ㅌ、ㅍ、ㅊ 屬於「送氣音」，分別與 ㄱ、ㄷ、ㅂ、ㅈ 成對。'
        '送氣音與「濃音」的差別是韓文發音的重點；本課只認識字形與名稱，細部發音請搭配音檔。',
  ),
  HangulLetter(
    jamo: 'ㅌ',
    name: '티읕',
    roman: 't',
    type: LetterType.consonant,
    index: 16,
    romanStatus: ContentStatus.verified,
    note: 'ㅌ 屬於「送氣音」，與 ㄷ 成對。',
  ),
  HangulLetter(
    jamo: 'ㅍ',
    name: '피읖',
    roman: 'p',
    type: LetterType.consonant,
    index: 17,
    romanStatus: ContentStatus.verified,
    note: 'ㅍ 屬於「送氣音」，與 ㅂ 成對。',
  ),
  HangulLetter(
    jamo: 'ㅎ',
    name: '히읗',
    roman: 'h',
    type: LetterType.consonant,
    index: 18,
    romanStatus: ContentStatus.pending,
  ),
];
