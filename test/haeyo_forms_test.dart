import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_app/data/catalog.dart';
import 'package:hangul_app/data/haeyo_forms.dart';

/// 已經是句子的片語（…요、…ㅂ니다／습니다）；아니다、다니다 這類字不算。
bool _isSentence(String h) {
  if (h.endsWith('요')) {
    return true;
  }
  if (h.endsWith('니다') && h.length >= 3) {
    final code = h.codeUnitAt(h.length - 3) - 0xAC00;
    return code >= 0 && code < 11172 && code % 28 == 17; // 17＝收尾音 ㅂ
  }
  return false;
}

void main() {
  group('해요體（單字卡「說話時」那一行）', () {
    test('每筆資料都對應到單字庫裡的字，結果是韓文且以 요 結尾', () {
      final ids = Catalog.words.map((w) => w.id).toSet();
      for (final entry in haeyoForms.entries) {
        expect(ids, contains(entry.key));
        expect(entry.value, matches(RegExp(r'^[가-힣 ]+요$')), reason: entry.key);
      }
    });

    test('字尾是 다 的單字（片語句子除外）都有資料，只有刻意排除的字沒有', () {
      // 바다、해마다 不是動詞或形容詞；뵙다、데리다 沒有單獨的해요體。
      const excluded = <String>{'바다', '해마다', '뵙다', '데리다'};
      for (final word in Catalog.words) {
        final h = word.hangul;
        if (!h.endsWith('다') || _isSentence(h)) {
          continue;
        }
        if (excluded.contains(h)) {
          expect(haeyoForms.containsKey(word.id), isFalse, reason: h);
        } else {
          expect(haeyoForms.containsKey(word.id), isTrue, reason: h);
        }
      }
    });

    test('規則與不規則活用的代表字', () {
      String form(String hangul) => haeyoForms[
          Catalog.words.firstWhere((w) => w.hangul == hangul).id]!;
      const expected = <String, String>{
        '비싸다': '비싸요', // ㅏ 縮合
        '먹다': '먹어요',
        '오다': '와요',
        '마시다': '마셔요',
        '하다': '해요',
        '되다': '돼요',
        '바쁘다': '바빠요', // ㅡ 脫落
        '모르다': '몰라요', // 르 不規則
        '덥다': '더워요', // ㅂ 不規則
        '돕다': '도와요',
        '입다': '입어요', // ㅂ 規則
        '듣다': '들어요', // ㄷ 不規則
        '받다': '받아요', // ㄷ 規則
        '짓다': '지어요', // ㅅ 不規則
        '웃다': '웃어요', // ㅅ 規則
        '하얗다': '하얘요', // ㅎ 不規則
        '좋다': '좋아요',
        '푸르다': '푸르러요', // 러 不規則
        '계시다': '계세요', // 尊敬語
        '갈아입다': '갈아입어요', // 複合字以最後的基本字為準
        '알아듣다': '알아들어요',
        '보고 싶다': '보고 싶어요', // 片語只活用最後一個字
        '잘생기다': '잘생겼어요', // 說現在的樣子也用過去式（附提醒）
        '아니다': '아니에요',
        '다니다': '다녀요',
      };
      expected.forEach((hangul, want) {
        expect(form(hangul), want, reason: hangul);
      });
    });

    test('提醒只放在有해요體資料的字上', () {
      for (final id in haeyoHints.keys) {
        expect(haeyoForms.containsKey(id), isTrue, reason: id);
      }
      expect(haeyoHints.length, greaterThan(0));
    });
  });
}
