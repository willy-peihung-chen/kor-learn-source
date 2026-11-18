import 'catalog.dart';

/// 把項目 id 轉成人看得懂的標籤（用於錯題本、進度頁）。
String itemLabel(String itemId) {
  final letter = Catalog.letterById(itemId);
  if (letter != null) {
    return '${letter.jamo}（${letter.name}）';
  }
  final syllable = Catalog.syllableById(itemId);
  if (syllable != null) {
    return syllable.roman.isEmpty
        ? syllable.hangul
        : '${syllable.hangul}（${syllable.roman}）';
  }
  final word = Catalog.wordById(itemId);
  if (word != null) {
    return '${word.hangul}（${word.meaning}）';
  }
  final grammar = Catalog.grammarExample(itemId);
  if (grammar != null) {
    return '${grammar.example.plain}（${grammar.point.title}）';
  }
  final colon = itemId.indexOf(':');
  return colon >= 0 ? itemId.substring(colon + 1) : itemId;
}
