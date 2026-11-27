import 'content_models.dart';
import 'essential_words.dart';
import 'late_words.dart';
import 'word_level_data.dart';

/// 單字的常用程度，依國立國語院「한국어 학습용 어휘 목록」的等級（1 級最常用）。
///
/// 分五組，順序就是學新字的順序：
/// 「基本用語」（編輯挑選的問候、道謝、請求等固定說法，見 [essentialWordHangul]；
/// 詞表不收這類說法，所以沒有官方等級）、詞表 1 級、詞表 2 級、
/// 「其他」（詞表 3 級，或詞表沒有列出的字，例如片語和一些較新的外來語；不代表不重要，
/// 只是沒有官方等級可以依據），最後是「較少用」：日常比較少聽到的字（見 [lateWordHangul]），
/// 不管詞表等級，一律排在最後。
enum WordLevel {
  essential('基本用語', '問候與日常最先用到的說法（編輯挑選，非官方分級）'),
  level1('1 級', '最常用'),
  level2('2 級', '常用'),
  other('其他', '詞表 3 級或詞表沒有的字'),
  later('較少用', '日常比較少聽到，先學前面的字');

  const WordLevel(this.label, this.hint);

  final String label;
  final String hint;
}

/// [word] 的常用程度：在 [lateWordHangul] 的字是 [WordLevel.later]，
/// 在 [essentialWordHangul] 的字是 [WordLevel.essential]，
/// 其餘依國語院詞表的等級，詞表 3 級與沒有列出的字都是 [WordLevel.other]。
WordLevel wordLevelOf(WordItem word) {
  if (lateWordHangul.contains(word.hangul)) {
    return WordLevel.later;
  }
  if (essentialWordHangul.contains(word.hangul)) {
    return WordLevel.essential;
  }
  switch (wordLevelData[word.hangul]) {
    case 1:
      return WordLevel.level1;
    case 2:
      return WordLevel.level2;
    default:
      return WordLevel.other;
  }
}

/// 同一個等級的單字。
class LevelGroup {
  const LevelGroup(this.level, this.words);

  final WordLevel level;
  final List<WordItem> words;
}

/// 把單字依等級分段（空的段落省略）；段落內維持原本順序。
List<LevelGroup> groupByLevel(List<WordItem> words) {
  return <LevelGroup>[
    for (final level in WordLevel.values)
      if (words.any((w) => wordLevelOf(w) == level))
        LevelGroup(
          level,
          <WordItem>[for (final w in words) if (wordLevelOf(w) == level) w],
        ),
  ];
}

/// 主題頁要顯示的段落：每個主題都依等級分段，段落內維持主題原本的順序。
List<LevelGroup> levelGroupsOf(WordTopic topic) => groupByLevel(topic.words);

/// 一個主題學新字的順序，和主題頁畫面上的順序相同。
List<WordItem> studyOrderOf(WordTopic topic) => <WordItem>[
      for (final group in levelGroupsOf(topic)) ...group.words,
    ];

/// 全部主題一起學新字的順序：全部單字依等級排列
/// （基本用語、1 級、2 級、其他、較少用），同一級內維持主題順序。
List<WordItem> globalStudyOrder(List<WordTopic> topics) {
  final all = <WordItem>[
    for (final topic in topics) ...topic.words,
  ];
  return <WordItem>[
    for (final group in groupByLevel(all)) ...group.words,
  ];
}
