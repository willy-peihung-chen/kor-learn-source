import '../data/catalog.dart';
import '../data/content_models.dart';

/// 中文意思的「核心詞」：去掉全形括號裡的補充後，以「；」分開。
/// 兩個單字只要有任何一個核心詞相同，就視為意思重疊。
/// 測驗的干擾選項（quiz_generator）和中文→韓文複習卡都用這個規則。
Set<String> meaningTokens(String meaning) {
  final cleaned = meaning.replaceAll(RegExp('（[^）]*）'), '');
  return cleaned
      .split('；')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
}

/// 核心詞 → 有這個核心詞的單字；第一次用到時建立。
final Map<String, List<WordItem>> _wordsByToken = () {
  final map = <String, List<WordItem>>{};
  for (final word in Catalog.words) {
    for (final token in meaningTokens(word.meaning)) {
      map.putIfAbsent(token, () => <WordItem>[]).add(word);
    }
  }
  return map;
}();

/// 單字 id → 教材順序；第一次用到時建立。
final Map<String, int> _wordOrder = <String, int>{
  for (var i = 0; i < Catalog.words.length; i++) Catalog.words[i].id: i,
};

/// 和 [word] 有相同核心詞、但韓文寫法不同的單字，依教材順序。
/// 中文→韓文卡用來提醒「還有別的字也是這個意思」。
List<WordItem> sameMeaningWords(WordItem word) {
  final seen = <String>{};
  final result = <WordItem>[];
  for (final token in meaningTokens(word.meaning)) {
    for (final other in _wordsByToken[token] ?? const <WordItem>[]) {
      if (other.hangul != word.hangul && seen.add(other.id)) {
        result.add(other);
      }
    }
  }
  result.sort((a, b) => _wordOrder[a.id]!.compareTo(_wordOrder[b.id]!));
  return result;
}
