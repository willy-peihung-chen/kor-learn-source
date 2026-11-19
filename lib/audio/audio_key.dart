import 'dart:convert';

/// 預先做好的語音檔檔名（不含副檔名）。
///
/// 算法：去掉前後空白後的 UTF-8 位元組數 + FNV-1a 32 位元雜湊（16 進位 8 碼），
/// 例如「안녕하세요.」→ `16-8d57f6cf`。
/// 必須和 tool/make_audio.py 的 audio_key() 完全一致，兩邊不可只改一邊。
///
/// 乘法拆成 (h << 24) + h × 403（16777619 = 2^24 + 403），
/// 讓網頁版（JavaScript 數字）和其他平台算出一樣的結果。
String audioKey(String text) {
  final bytes = utf8.encode(text.trim());
  var hash = 0x811c9dc5;
  for (final byte in bytes) {
    hash = (hash ^ byte) & 0xffffffff;
    hash = (((hash << 24) & 0xffffffff) + hash * 403) & 0xffffffff;
  }
  return '${bytes.length}-${hash.toRadixString(16).padLeft(8, '0')}';
}
