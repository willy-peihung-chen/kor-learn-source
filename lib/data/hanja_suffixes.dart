import 'content_models.dart';

/// 漢字詞的常見字尾（例如 교실、사무실 的「실（室）」）。
///
/// 單字卡上的漢字詞，如果字尾在這裡，就會顯示「字尾＝意思」與同字尾的其他單字，
/// 幫中文母語者一次記一排。同字尾的單字由單字庫自動找出，不必另外維護清單。
/// 字尾的意思只是「傾向」，不是嚴格規則；是編輯上的整理，尚未經母語者或老師確認。
class HanjaSuffix {
  const HanjaSuffix(
    this.hangul,
    this.hanja,
    this.meaning, {
    this.exclude = const <String>{},
  });

  /// 字尾的韓文（一個音節），例如「실」。
  final String hangul;

  /// 字尾的漢字，例如「室」。
  final String hanja;

  /// 簡短的中文意思，例如「房間」。
  final String meaning;

  /// 看起來有這個字尾、但意思不是這個字尾的單字（例如 인생 的「生」不是學生）。
  final Set<String> exclude;
}

const List<HanjaSuffix> hanjaSuffixes = <HanjaSuffix>[
  // 地方
  HanjaSuffix('실', '室', '房間；室'),
  HanjaSuffix('관', '館', '館（可以進去參觀、使用的建築）'),
  HanjaSuffix('점', '店', '店'),
  HanjaSuffix('장', '場', '場地、場所', exclude: <String>{'당장', '직장'}),
  HanjaSuffix('소', '所', '場所', exclude: <String>{'주소'}),
  HanjaSuffix('원', '院', '機構（院）'),
  HanjaSuffix('원', '園', '園'),
  // 人
  HanjaSuffix('원', '員', '人員'),
  HanjaSuffix('사', '師', '有專業技術的人'),
  HanjaSuffix('자', '者', '…的人'),
  HanjaSuffix(
    '생',
    '生',
    '學生',
    exclude: <String>{'남동생', '여동생', '인생', '고생', '평생'},
  ),
  HanjaSuffix('장', '長', '負責人'),
  // 東西
  HanjaSuffix('어', '語', '語言', exclude: <String>{'단어'}),
  HanjaSuffix('기', '機', '機器'),
  HanjaSuffix('복', '服', '衣服'),
  HanjaSuffix('증', '證', '證明用的單據；憑證'),
];

/// 單字卡上要顯示的字尾提示。
class HanjaSuffixHint {
  const HanjaSuffixHint(this.suffix, this.siblings, this.sameSound);

  final HanjaSuffix suffix;

  /// 同字尾的其他單字（最多 [maxSiblings] 個，照單字庫順序）。
  final List<WordItem> siblings;

  /// 韓文字尾相同、漢字不同的字尾（例如 원 的「院、園、員」），用來提醒「同音不同字」。
  final List<HanjaSameSound> sameSound;
}

/// 同音不同字的一個字尾，附單字庫裡的第一個例字（沒有時為 null）。
class HanjaSameSound {
  const HanjaSameSound(this.suffix, this.example);

  final HanjaSuffix suffix;
  final WordItem? example;
}

const int maxSiblings = 3;

/// [word] 的字尾，不是常見字尾（或不是漢字詞）時回傳 null。
///
/// 韓文音節數和漢字字數相同才判斷（一個音節對一個漢字），字尾取最後一個音節。
HanjaSuffix? hanjaSuffixOf(WordItem word) {
  final hanja = word.hanja;
  if (hanja == null || word.hangul.length < 2) {
    return null;
  }
  if (hanja.length != word.hangul.length) {
    return null;
  }
  final lastHangul = word.hangul.substring(word.hangul.length - 1);
  final lastHanja = hanja.substring(hanja.length - 1);
  for (final suffix in hanjaSuffixes) {
    if (suffix.hangul == lastHangul &&
        suffix.hanja == lastHanja &&
        !suffix.exclude.contains(word.hangul)) {
      return suffix;
    }
  }
  return null;
}

/// [word] 的字尾提示；[allWords] 是整個單字庫。沒有字尾提示時回傳 null。
HanjaSuffixHint? hanjaSuffixHintOf(WordItem word, Iterable<WordItem> allWords) {
  final suffix = hanjaSuffixOf(word);
  if (suffix == null) {
    return null;
  }
  final siblings = <WordItem>[];
  for (final other in allWords) {
    if (siblings.length >= maxSiblings) {
      break;
    }
    if (other.id != word.id && hanjaSuffixOf(other) == suffix) {
      siblings.add(other);
    }
  }
  return HanjaSuffixHint(
    suffix,
    siblings,
    <HanjaSameSound>[
      for (final s in hanjaSuffixes)
        if (s.hangul == suffix.hangul && s != suffix)
          HanjaSameSound(s, _firstWordWith(s, allWords)),
    ],
  );
}

WordItem? _firstWordWith(HanjaSuffix suffix, Iterable<WordItem> allWords) {
  for (final word in allWords) {
    if (hanjaSuffixOf(word) == suffix) {
      return word;
    }
  }
  return null;
}
