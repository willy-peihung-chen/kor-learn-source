import '../data/catalog.dart';
import '../data/content_models.dart';

/// 單字辭典的查詢邏輯：輸入中文（或韓文），找出 App 內收錄的單字。
///
/// 只查得到 App 已收錄的單字，不是完整辭典。查詢內容全部來自教材資料，
/// 沒有另外寫死的詞條。
class DictionarySearch {
  DictionarySearch(Iterable<WordItem> words)
      : _entries = <_Entry>[for (final w in words) _Entry(w)];

  /// 查全部教材單字用的共用實例。
  static final DictionarySearch all = DictionarySearch(Catalog.words);

  final List<_Entry> _entries;

  /// 中文意思的「核心詞」：去掉括號補充後，依「；」「、」「，」「/」分開。
  /// 例如「名字（對長輩的敬語為 성함）」→「名字」。
  static List<String> meaningTokens(String meaning) {
    final cleaned = meaning.replaceAll(RegExp('（[^）]*）'), '');
    return cleaned
        .split(RegExp('[；、，,/]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// 查詢字串是否含有韓文（音節或字母）。
  static bool containsHangul(String text) =>
      RegExp('[ㄱ-ㆎ가-힣]').hasMatch(text);

  /// 依相關程度由高到低回傳最多 [limit] 筆。
  ///
  /// 中文查詢的排序：意思的核心詞完全相同 → 核心詞開頭相同 → 核心詞包含
  /// → 括號補充裡包含 → 漢字欄位 → 例句翻譯裡包含。
  /// 韓文查詢的排序：完全相同 → 開頭相同 → 包含 → 例句裡包含。
  /// 同分時，字數少的在前，再依教材原本的順序。
  List<WordItem> search(String query, {int limit = 50}) {
    final q = query.trim();
    if (q.isEmpty || limit <= 0) {
      return const <WordItem>[];
    }
    final korean = containsHangul(q);
    final scored = <({WordItem word, int score, int order})>[];
    for (var i = 0; i < _entries.length; i++) {
      final score = _entries[i].score(q, korean: korean);
      if (score != null) {
        scored.add((word: _entries[i].word, score: score, order: i));
      }
    }
    scored.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) {
        return byScore;
      }
      final byLength = a.word.hangul.length.compareTo(b.word.hangul.length);
      if (byLength != 0) {
        return byLength;
      }
      return a.order.compareTo(b.order);
    });
    return <WordItem>[for (final s in scored.take(limit)) s.word];
  }
}

class _Entry {
  _Entry(this.word) : tokens = DictionarySearch.meaningTokens(word.meaning);

  final WordItem word;
  final List<String> tokens;

  /// 符合時回傳分數（越小越相關），不符合回傳 null。
  int? score(String q, {required bool korean}) {
    if (korean) {
      if (word.hangul == q) {
        return 0;
      }
      if (word.hangul.startsWith(q)) {
        return 1;
      }
      if (word.hangul.contains(q)) {
        return 2;
      }
      if (word.example.contains(q)) {
        return 4;
      }
      return null;
    }
    if (tokens.contains(q)) {
      return 0;
    }
    if (tokens.any((t) => t.startsWith(q))) {
      return 1;
    }
    if (tokens.any((t) => t.contains(q))) {
      return 2;
    }
    if (word.meaning.contains(q)) {
      return 3;
    }
    final hanja = word.hanja;
    if (hanja != null && hanja.contains(q)) {
      return 4;
    }
    if (word.exampleMeaning.contains(q)) {
      return 5;
    }
    return null;
  }
}
