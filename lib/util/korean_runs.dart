/// 一段文字中的一小段：韓文或非韓文。
class TextRun {
  const TextRun(this.text, {required this.isKorean});

  final String text;
  final bool isKorean;

  @override
  bool operator ==(Object other) =>
      other is TextRun && other.text == text && other.isKorean == isKorean;

  @override
  int get hashCode => Object.hash(text, isKorean);

  @override
  String toString() => 'TextRun($text, $isKorean)';
}

/// 韓文音節（가～힣），中間可以夾空白，例如「메뉴 좀 주세요」算同一段。
/// 單獨的字母（ㄱ、ㅏ 等）不算：電腦語音念單獨字母不準，不給它加喇叭。
final RegExp _koreanRun =
    RegExp(r'[가-힣]+(?:[  ]+[가-힣]+)*');

/// 把說明文字切成韓文與非韓文的小段，畫面用來在每段韓文後面加朗讀按鈕。
List<TextRun> splitKoreanRuns(String text) {
  final runs = <TextRun>[];
  var index = 0;
  for (final match in _koreanRun.allMatches(text)) {
    if (match.start > index) {
      runs.add(TextRun(text.substring(index, match.start), isKorean: false));
    }
    runs.add(TextRun(match.group(0)!, isKorean: true));
    index = match.end;
  }
  if (index < text.length) {
    runs.add(TextRun(text.substring(index), isKorean: false));
  }
  return runs;
}
