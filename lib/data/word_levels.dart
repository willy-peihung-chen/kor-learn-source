import 'content_models.dart';
import 'word_level_data.dart';

/// 單字的常用程度，依國立國語院「한국어 학습용 어휘 목록」的等級（1 級最常用）。
///
/// 只分三組：詞表 1 級、詞表 2 級，以及「其他」（詞表 3 級，或詞表沒有列出的字，
/// 例如問候語、片語和一些較新的外來語）。「其他」不代表不重要，只是沒有官方等級可以依據。
enum WordLevel {
  level1('1 級', '最常用'),
  level2('2 級', '常用'),
  other('其他', '詞表 3 級或詞表沒有的字');

  const WordLevel(this.label, this.hint);

  final String label;
  final String hint;
}

/// [word] 在國語院詞表中的等級；詞表 3 級與沒有列出的字都是 [WordLevel.other]。
WordLevel wordLevelOf(WordItem word) {
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

/// 把單字依等級分成 1 級、2 級、其他三段（空的段落省略）；段落內維持原本順序。
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
