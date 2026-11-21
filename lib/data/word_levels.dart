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

/// 以片語為主的主題（例如問候語）：詞表大多沒收，依等級分段沒有意義。
/// 這些主題在主題頁不分段、照原順序，全部複習時也排在最前面。
const Set<String> phraseTopicIds = <String>{'greetings'};

bool isPhraseTopic(WordTopic topic) => phraseTopicIds.contains(topic.id);

/// 主題頁要顯示的段落：片語主題只有一段（照原順序），其他主題依等級分段。
List<LevelGroup> levelGroupsOf(WordTopic topic) {
  if (isPhraseTopic(topic)) {
    // 只有一段時畫面不顯示等級標題，這裡的等級不會被用到。
    return <LevelGroup>[LevelGroup(WordLevel.other, topic.words)];
  }
  return groupByLevel(topic.words);
}

/// 一個主題學新字的順序，和主題頁畫面上的順序相同。
List<WordItem> studyOrderOf(WordTopic topic) => <WordItem>[
      for (final group in levelGroupsOf(topic)) ...group.words,
    ];

/// 全部主題一起學新字的順序：片語主題先（照原順序），
/// 其餘單字依 1 級、2 級、其他排列，同一級內維持主題順序。
List<WordItem> globalStudyOrder(List<WordTopic> topics) {
  final phrases = <WordItem>[
    for (final topic in topics)
      if (isPhraseTopic(topic)) ...topic.words,
  ];
  final others = <WordItem>[
    for (final topic in topics)
      if (!isPhraseTopic(topic)) ...topic.words,
  ];
  return <WordItem>[
    ...phrases,
    for (final group in groupByLevel(others)) ...group.words,
  ];
}
