import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/audio/audio_key.dart';

void main() {
  // 期望值由 tool/make_audio.py 的 audio_key() 算出；兩邊算法必須一致，
  // 否則網頁版找不到語音檔，只會改用手機內建語音。
  test('語音檔檔名和產生語音檔的腳本一致', () {
    expect(audioKey('안녕하세요.'), '16-8d57f6cf');
    expect(audioKey('이거 얼마예요?'), '20-3eff88ce');
    expect(audioKey('가'), '3-cdd08b15');
  });

  test('前後空白不影響檔名', () {
    expect(audioKey('  가 '), audioKey('가'));
  });
}
