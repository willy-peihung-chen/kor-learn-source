/// 韓文音節的字母分解（依 Unicode 韓文音節公式）。
///
/// 一個音節 = 初聲（子音）+ 中聲（母音）+ 終聲（尾音，可以沒有）：
/// 0xAC00 + (初聲索引 * 21 + 中聲索引) * 28 + 終聲索引。
library;

/// 初聲，依 Unicode 順序（共 19 個）。
const List<String> kInitialJamo = <String>[
  'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', //
  'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
];

/// 中聲，依 Unicode 順序（共 21 個）。
const List<String> kVowelJamo = <String>[
  'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', //
  'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ',
];

/// 終聲，依 Unicode 順序；索引 0 代表沒有尾音（共 28 個）。
const List<String> kFinalJamo = <String>[
  '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', //
  'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', //
  'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
];

const int _hangulBase = 0xAC00;
const int _hangulEnd = 0xD7A3;

/// 一個音節拆出來的字母。
class SyllableParts {
  const SyllableParts({
    required this.syllable,
    required this.initial,
    required this.vowel,
    this.finalJamo,
  });

  /// 原本的音節，例如「강」。
  final String syllable;

  /// 初聲，例如 ㄱ。ㅇ 在音節開頭不發音，只是佔位。
  final String initial;

  /// 中聲，例如 ㅏ。
  final String vowel;

  /// 終聲（尾音）；沒有尾音時為 null。
  final String? finalJamo;

  /// 初聲是不發音的 ㅇ。
  bool get hasSilentInitial => initial == 'ㅇ';

  /// 依序排列的字母（初聲、中聲、終聲）。
  List<String> get letters => <String>[
        initial,
        vowel,
        if (finalJamo != null) finalJamo!,
      ];

  /// 例如「ㄱ+ㅏ+ㅇ」。
  String get formula => letters.join('+');
}

/// 拆解單一韓文音節；不是完整的韓文音節（例如標點、字母本身）時回傳 null。
SyllableParts? decomposeSyllable(String char) {
  if (char.runes.length != 1) {
    return null;
  }
  final code = char.runes.first;
  if (code < _hangulBase || code > _hangulEnd) {
    return null;
  }
  final offset = code - _hangulBase;
  final finalIndex = offset % 28;
  final vowelIndex = (offset ~/ 28) % 21;
  final initialIndex = offset ~/ (28 * 21);
  return SyllableParts(
    syllable: char,
    initial: kInitialJamo[initialIndex],
    vowel: kVowelJamo[vowelIndex],
    finalJamo: finalIndex == 0 ? null : kFinalJamo[finalIndex],
  );
}

/// 把一段文字依空白分成「詞」，每個詞再拆成音節的字母。
/// 標點與非韓文字元會被略過，所以「안녕하세요?」只會得到五個音節。
List<List<SyllableParts>> decomposeText(String text) {
  final result = <List<SyllableParts>>[];
  for (final token in text.split(RegExp(r'\s+'))) {
    final parts = <SyllableParts>[];
    for (final rune in token.runes) {
      final decomposed = decomposeSyllable(String.fromCharCode(rune));
      if (decomposed != null) {
        parts.add(decomposed);
      }
    }
    if (parts.isNotEmpty) {
      result.add(parts);
    }
  }
  return result;
}

/// 組合初聲、中聲、（尾音）成音節；找不到對應字母時回傳 null。
String? composeSyllable(String initial, String vowel, [String? finalJamo]) {
  final i = kInitialJamo.indexOf(initial);
  final v = kVowelJamo.indexOf(vowel);
  final f = finalJamo == null ? 0 : kFinalJamo.indexOf(finalJamo);
  if (i < 0 || v < 0 || f < 0) {
    return null;
  }
  return String.fromCharCode(_hangulBase + (i * 21 + v) * 28 + f);
}
