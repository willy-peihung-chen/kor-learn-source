enum QuizKind {
  letterRoman('字母→羅馬字'),
  letterName('字母→名稱'),
  syllableRoman('音節→羅馬字'),
  syllableFromRoman('羅馬字→音節'),
  wordMeaning('單字→中文'),
  meaningWord('中文→單字'),
  listenSyllable('聽音辨字'),
  grammarCloze('文法填空');

  const QuizKind(this.label);
  final String label;
}

/// 出題用的「種子」：哪一種題型 + 哪一個教材項目。
/// 錯題本就是用種子重新出題。
class QuizSeed {
  const QuizSeed(this.kind, this.itemId);

  final QuizKind kind;
  final String itemId;

  String get key => '${kind.name}|$itemId';
}

class QuizQuestion {
  const QuizQuestion({
    required this.kind,
    required this.itemId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.stimulus,
    this.speakText,
    this.optionNotes,
  });

  final QuizKind kind;
  final String itemId;
  final String prompt;

  /// 題目中要放大顯示的內容（韓文字、羅馬字、中文或挖空的句子）。
  final String? stimulus;

  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// 作答後可以朗讀的韓文（例句）；沒有時為 null。
  final String? speakText;

  /// 作答後顯示在每個選項底下的補充說明（例如選項的意思）。
  /// 長度與 [options] 相同；某個選項沒有說明時該位置為 null；整題沒有時為 null。
  final List<String?>? optionNotes;

  /// 答題判定：選到的選項索引是否為正確答案。
  bool isCorrect(int selected) => selected == correctIndex;

  String get correctAnswer => options[correctIndex];

  QuizSeed get seed => QuizSeed(kind, itemId);
}
