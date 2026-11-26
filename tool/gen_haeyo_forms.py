"""產生 lib/data/haeyo_forms.dart：動詞、形容詞的「해요體」現在式（例：비싸다 → 비싸요）。

單字卡上的字是辭典形（字尾是 다），說話時要把 다 拿掉、接語尾；這個檔案讓單字卡多顯示一行
「說話時（해요體）：비싸요」。

規則：
- 只處理動詞、形容詞：字尾是 다，且國立國語院詞表標為 동／형，或列在 EXTRA_VERBS；
  詞表標為名詞等其他詞類、又不在 EXTRA_VERBS 的字（例：바다）不處理。
- 已經是句子的片語（字尾是 요、니다）不處理。片語（中間有空白）只活用最後一個字。
- 規則活用由程式計算；不規則活用與例外寫在下面的表裡，表裡的字一律以表為準。
- 輸出前把每個結果和 OVERRIDES 再核對一次；`--check` 只比對、不寫檔（給自動偵測用）。

用法：python tool/gen_haeyo_forms.py          產生檔案
      python tool/gen_haeyo_forms.py --check  只檢查檔案是不是最新
      python tool/gen_haeyo_forms.py --list   列出全部結果（給審查用）
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VOCAB = ROOT / 'lib' / 'data' / 'vocab'
WORD_LIST = ROOT / 'docs' / 'sources' / '한국어 학습용 어휘 목록.txt'
OUT = ROOT / 'lib' / 'data' / 'haeyo_forms.dart'

# 詞表沒有、或詞表詞性不是 동／형，但確定是動詞、形容詞的字。
EXTRA_VERBS: set[str] = {
    '목마르다', '시다', '신나다', '싶다', '공손하다', '드시다', '편찮으시다', '돌아가시다',
    '여쭙다', '수영하다', '빨래하다',
}

# 字尾是 다、但不是動詞或形容詞的字（詞表沒收、程式無法判斷時用）。
NOT_VERBS: set[str] = {
    '바다', '해마다',
    # 뵙다 不接母音開頭的語尾，해요體要改用 뵈다 的 봬요，這裡不顯示。
    '뵙다',
    # 데리다 只用 데리고、데려가다 等形式，不單獨用해요體。
    '데리다',
}

# 不規則活用與例外：韓文（或 id 的 '韓文#sense'）→ 해요體。以表為準。
OVERRIDES: dict[str, str] = {
    # ㅂ 不規則
    '돕다': '도와요', '곱다': '고와요',
    # ㄷ 不規則
    '듣다': '들어요', '알아듣다': '알아들어요', '걷다': '걸어요', '묻다': '물어요', '싣다': '실어요', '깨닫다': '깨달아요',
    '일컫다': '일컬어요', '붇다': '불어요',
    # ㅅ 不規則
    '낫다': '나아요', '짓다': '지어요', '젓다': '저어요', '붓다': '부어요', '잇다': '이어요', '긋다': '그어요',
    # 러 不規則
    '이르다#reach': '이르러요', '푸르다': '푸르러요',
    # 르 動詞裡屬於 ㅡ 脫落（不是 르 不規則）的字
    '따르다': '따라요', '치르다': '치러요', '들르다': '들러요',
    # 우 不規則
    '푸다': '퍼요',
    # 尊敬語：-시다 → -세요
    '계시다': '계세요', '드시다': '드세요', '주무시다': '주무세요', '잡수시다': '잡수세요',
    '편찮으시다': '편찮으세요',
    # 其他
    '아니다': '아니에요',
    # 說話對象是長輩時的動作，實際都加 -시-
    '말씀하다': '말씀하세요',
    # 描述現在的狀態也用過去式（見 HINTS）
    '잘생기다': '잘생겼어요', '닮다': '닮았어요', '돌아가시다': '돌아가셨어요',
    # 피다 → 피어요（縮寫 펴요 容易和 펴다 混淆，這裡用不縮寫的形式）
    '피다': '피어요',
}

# ㅂ 結尾但屬於規則活用的字（其餘 ㅂ 結尾的動詞、形容詞當成 ㅂ 不規則：덥다 → 더워요）。
B_REGULAR = {'입다', '잡다', '좁다', '씹다', '뽑다', '접다', '업다', '집다', '꼽다', '수줍다', '굽다#bend'}
# ㄷ 結尾、ㅅ 結尾的不規則字已列在 OVERRIDES；其餘一律規則活用（받다 → 받아요、웃다 → 웃어요）。
# ㅎ 結尾的形容詞（좋다 以外）是 ㅎ 不規則；動詞（놓다、넣다、낳다…）是規則活用。
H_REGULAR = {'좋다', '놓다', '넣다', '낳다', '닿다', '쌓다'}
# ㅎ 不規則裡母音變成 ㅐ 的字（其餘：ㅓ→ㅔ、ㅕ→ㅖ、ㅑ→ㅒ、ㅏ→ㅐ）。
H_TO_AE = {'그렇다', '이렇다', '저렇다', '어떻다'}

# 顯示在해요體後面的提醒（id 的韓文 → 說明）。
HINTS: dict[str, str] = {
    '잘생기다': '說現在的樣子也用過去式',
    '닮다': '說現在像誰也用過去式',
    '돌아가시다': '「過世」幾乎都用過去式；돌아가세요 常是「請回去」',
    '말씀하다': '用在長輩身上要加 -시-',
    '늙다': '說現在的狀態常用過去式：늙었어요',
    '마르다': '說現在的狀態（瘦、乾了）常用過去式：말랐어요',
    '화나다': '說現在在生氣常用過去式：화났어요',
    '지치다': '說現在很累常用過去式：지쳤어요',
}
# 注意：HINTS 以韓文比對、不看 sense；之後若這些字出現同形異義字，要改成 韓文#sense。

BASE = 0xAC00
CHO = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ'
JUNG = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ'
JONG = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']


def split(ch: str) -> tuple[int, int, int]:
    n = ord(ch) - BASE
    return n // 588, (n % 588) // 28, n % 28


def join(cho: int, jung: int, jong: int = 0) -> str:
    return chr(BASE + cho * 588 + jung * 28 + jong)


def bright(jung: int) -> bool:
    """陽性母音（ㅏ、ㅗ、ㅑ）接 -아요，其他接 -어요。"""
    return JUNG[jung] in 'ㅏㅗㅑ'


def base_of(word: str, table) -> str | None:
    """複合字以最後的基本字為準（갈아입다 → 입다、알아듣다 → 듣다）：回傳最長的相符字尾。"""
    best = None
    for k in table:
        if '#' in k:
            continue
        if word.endswith(k) and (best is None or len(k) > len(best)):
            best = k
    return best


def conjugate(word: str, key: str, is_adj: bool) -> str:
    """辭典形 → 해요體現在式（只處理單一個字，不含空白）。"""
    # 例外表只做整字比對（字尾比對會誤配：파묻다 ≠ 묻다、살피다 ≠ 피다）；複合字要另外寫進表裡。
    for k in (key, word):
        if k in OVERRIDES:
            return OVERRIDES[k]
    assert word.endswith('다') and len(word) >= 2, word
    stem = word[:-1]
    head, last = stem[:-1], stem[-1]
    if stem.endswith('하'):
        return head + '해요'
    cho, jung, jong = split(last)
    v = JUNG[jung]
    # 有收尾音
    if jong:
        j = JONG[jong]
        if j == 'ㅂ' and key not in B_REGULAR and base_of(word, B_REGULAR) is None:
            return head + join(cho, jung) + '워요'
        if j == 'ㅎ' and base_of(word, H_REGULAR) is None and is_adj:
            # 그렇다 → 그래요、하얗다 → 하얘요
            if base_of(word, H_TO_AE) is not None:
                new = 'ㅐ'
            else:
                new = {'ㅑ': 'ㅒ', 'ㅓ': 'ㅔ', 'ㅕ': 'ㅖ'}.get(v, 'ㅐ')
            return head + join(cho, JUNG.index(new)) + '요'
        return stem + ('아요' if bright(jung) else '어요')
    # 沒有收尾音
    if v == 'ㅡ':
        if cho == CHO.index('ㄹ') and head:  # 르 不規則：모르다 → 몰라요
            pc, pj, pjong = split(head[-1])
            assert pjong == 0, word
            new_prev = join(pc, pj, JONG.index('ㄹ'))
            return head[:-1] + new_prev + ('라요' if bright(pj) else '러요')
        if head:  # ㅡ 脫落：바쁘다 → 바빠요
            pj = split(head[-1])[1]
            nv = 'ㅏ' if bright(pj) else 'ㅓ'
        else:  # 쓰다 → 써요
            nv = 'ㅓ'
        return head + join(cho, JUNG.index(nv)) + '요'
    merge = {'ㅏ': 'ㅏ', 'ㅓ': 'ㅓ', 'ㅕ': 'ㅕ', 'ㅐ': 'ㅐ', 'ㅔ': 'ㅔ', 'ㅗ': 'ㅘ', 'ㅜ': 'ㅝ', 'ㅣ': 'ㅕ', 'ㅚ': 'ㅙ'}
    if v in merge:
        return head + join(cho, JUNG.index(merge[v])) + '요'
    # ㅟ、ㅢ 等不縮合：쉬다 → 쉬어요
    return stem + ('아요' if bright(jung) else '어요')


# 規則自我測試：(辭典形, 是否形容詞, 預期)。包含目前單字庫沒有、但規則要算對的字。
GOLDEN = [
    ('비싸다', True, '비싸요'), ('오다', False, '와요'), ('마시다', False, '마셔요'), ('되다', False, '돼요'),
    ('쉬다', False, '쉬어요'), ('바쁘다', True, '바빠요'), ('쓰다', False, '써요'), ('모르다', False, '몰라요'),
    ('덥다', True, '더워요'), ('돕다', False, '도와요'), ('입다', False, '입어요'), ('갈아입다', False, '갈아입어요'),
    ('듣다', False, '들어요'), ('받다', False, '받아요'), ('파묻다', False, '파묻어요'), ('짓다', False, '지어요'),
    ('웃다', False, '웃어요'), ('살피다', False, '살펴요'), ('그렇다', True, '그래요'), ('하얗다', True, '하얘요'),
    ('누렇다', True, '누레요'), ('허옇다', True, '허예요'), ('좋다', True, '좋아요'), ('사이좋다', True, '사이좋아요'),
    ('넣다', False, '넣어요'), ('아니다', True, '아니에요'), ('다니다', False, '다녀요'), ('푸르다', True, '푸르러요'), ('따르다', False, '따라요'), ('하다', False, '해요'),
]


def self_test() -> list[str]:
    errors = []
    for text, want in (('아니다', False), ('다니다', False), ('감사합니다', True), ('고맙습니다', True), ('미안해요', True)):
        if is_sentence(text) != want:
            errors.append(f'句子判斷錯誤：{text}')
    for word, adj, want in GOLDEN:
        got = conjugate(word, word, adj)
        if got != want:
            errors.append(f'{word}：算出 {got}，應為 {want}')
    return errors


def load_pos() -> dict[str, set[str]]:
    pos: dict[str, set[str]] = {}
    text = WORD_LIST.read_bytes().decode('cp949')
    for line in text.splitlines():
        parts = line.split('\t')
        if len(parts) < 3 or not parts[0].strip().isdigit():
            continue
        word = re.sub(r'\d+$', '', parts[1].strip())
        pos.setdefault(word, set()).add(parts[2].strip())
    return pos


def load_words() -> list[tuple[str, str, str]]:
    """(id, 韓文, 意思)，依主題檔順序。"""
    out = []
    pat = re.compile(r"WordItem\(\s*'([^']+)',\s*'([^']+)'(.*?)\),\s*$", re.M)
    for path in sorted(VOCAB.glob('topic_*.dart')):
        for m in pat.finditer(path.read_text(encoding='utf-8')):
            hangul, meaning, rest = m.group(1), m.group(2), m.group(3)
            sense = re.search(r"sense:\s*'([^']+)'", rest)
            wid = f'word:{hangul}#{sense.group(1)}' if sense else f'word:{hangul}'
            out.append((wid, hangul, meaning))
    return out


def is_sentence(hangul: str) -> bool:
    """已經是句子的片語（…요、…ㅂ니다／습니다）；아니다、다니다 這類字不算。"""
    if hangul.endswith('요'):
        return True
    if hangul.endswith('니다') and len(hangul) >= 3:
        prev = hangul[-3]
        return '가' <= prev <= '힣' and split(prev)[2] == JONG.index('ㅂ')
    return False


def build() -> tuple[dict[str, str], list[str]]:
    pos = load_pos()
    forms: dict[str, str] = {}
    unknown: list[str] = []
    for wid, hangul, meaning in load_words():
        if not hangul.endswith('다') or is_sentence(hangul):
            continue
        last = hangul.split(' ')[-1]
        if last in NOT_VERBS or hangul in NOT_VERBS:
            continue
        tags = pos.get(last, set())
        is_verb = bool(tags & {'동', '형'}) or last in EXTRA_VERBS or hangul in EXTRA_VERBS
        if not is_verb:
            unknown.append(f'{wid}\t{meaning}\t詞表：{"、".join(sorted(tags)) or "沒有"}')
            continue
        key = last + ('#' + wid.split('#', 1)[1] if '#' in wid else '')
        is_adj = '형' in tags and '동' not in tags
        form = conjugate(last, key, is_adj)
        prefix = hangul[: len(hangul) - len(last)]
        forms[wid] = prefix + form
    return forms, unknown


def render(forms: dict[str, str]) -> str:
    lines = [
        '// 由 tool/gen_haeyo_forms.py 自動產生，請勿手改；改規則或例外表後重新執行。',
        '// 動詞、形容詞的해요體現在式（例：비싸다 → 비싸요），單字卡顯示「說話時」用。',
        '// 內容待查核：不規則活用以人工整理的例外表為準，只經過 AI 審查。',
        '',
        '/// 單字 id → 해요體現在式；不是動詞、形容詞的字沒有資料。',
        'const Map<String, String> haeyoForms = <String, String>{',
    ]
    for wid, form in forms.items():
        lines.append(f"  '{wid}': '{form}',")
    lines.append('};')
    lines.append('')
    lines.append('/// 顯示在해요體後面的提醒（例如說現在的樣子也用過去式）。')
    lines.append('const Map<String, String> haeyoHints = <String, String>{')
    for wid in forms:
        h = wid[len('word:'):].split('#')[0].split(' ')[-1]
        if h in HINTS:
            lines.append(f"  '{wid}': '{HINTS[h]}',")
    lines.append('};')
    return '\n'.join(lines) + '\n'


def main() -> int:
    bad = self_test()
    if bad:
        print('規則自我測試失敗：')
        for b in bad:
            print('  ' + b)
        return 1
    forms, unknown = build()
    if '--list' in sys.argv:
        for wid, form in forms.items():
            print(f'{wid}\t{form}')
        print(f'# 共 {len(forms)} 個；未判斷 {len(unknown)} 個', file=sys.stderr)
        for u in unknown:
            print('未判斷\t' + u, file=sys.stderr)
        return 0
    if unknown:
        print('有字尾是 다、但詞性無法判斷的字（請加進 EXTRA_VERBS 或 NOT_VERBS）：')
        for u in unknown:
            print('  ' + u)
        return 1
    text = render(forms)
    if '--check' in sys.argv:
        if not OUT.exists() or OUT.read_text(encoding='utf-8') != text:
            print('haeyo_forms.dart 不是最新，請執行 python tool/gen_haeyo_forms.py')
            return 1
        print(f'haeyo_forms.dart 與單字庫一致（{len(forms)} 個）。')
        return 0
    OUT.write_text(text, encoding='utf-8', newline='\n')
    print(f'已寫入 {OUT}（{len(forms)} 個）')
    return 0


if __name__ == '__main__':
    sys.exit(main())
