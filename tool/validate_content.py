#!/usr/bin/env python3
"""教材自動錯誤偵測工具。

用法（在專案根目錄）：
    python tool/validate_content.py          # 檢查全部，有錯誤時結束碼為 1
    python tool/validate_content.py --list   # 另外列出單元句子（給人工檢查用）
    python tool/validate_content.py --checklist  # 重新產生 docs/review_checklist.md

只用 Python 標準函式庫，不需要安裝任何套件，也不需要 Flutter。
它檢查的是「看得出規則的錯誤」：結構、語氣、助詞與收尾音、數字系統、常見拼寫與空格、
簡體字、單字範圍等。它無法判斷句子自不自然；那部分仍需要人工或母語者查核。
"""

from __future__ import annotations

import glob
import os
import re
import sys
from dataclasses import dataclass, field

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'lib', 'data')

# 與 lib/data/course_options.dart 相同的預設值；開關打開時請一併修改。
FLAGS = {'showWorkplace': False, 'showHonorific': False}

# ---------------------------------------------------------------- 韓文工具

HANGUL_RE = re.compile(r'[가-힣]')
JAMO_RE = re.compile(r'[ㄱ-ㅣ]')


def is_syllable(ch: str) -> bool:
    return '가' <= ch <= '힣'


def batchim(ch: str) -> int:
    """收尾音編號；0 代表沒有收尾音。8 是 ㄹ。"""
    return (ord(ch) - 0xAC00) % 28


def has_batchim(ch: str) -> bool:
    return batchim(ch) != 0


def is_rieul(ch: str) -> bool:
    return batchim(ch) == 8


# ---------------------------------------------------------------- 結果

@dataclass
class Issue:
    level: str  # 'ERROR' 或 'WARN'
    where: str
    message: str


@dataclass
class Report:
    issues: list[Issue] = field(default_factory=list)

    def error(self, where: str, message: str) -> None:
        self.issues.append(Issue('ERROR', where, message))

    def warn(self, where: str, message: str) -> None:
        self.issues.append(Issue('WARN', where, message))

    @property
    def errors(self) -> list[Issue]:
        return [i for i in self.issues if i.level == 'ERROR']

    @property
    def warnings(self) -> list[Issue]:
        return [i for i in self.issues if i.level == 'WARN']


# ---------------------------------------------------------------- Dart 掃描

def read(path: str) -> str:
    with open(path, encoding='utf-8') as f:
        return f.read()


def strip_comments(src: str) -> str:
    """去掉 // 與 /* */ 註解（保留字串內容）。"""
    out = []
    i, n = 0, len(src)
    quote = None
    while i < n:
        c = src[i]
        if quote:
            out.append(c)
            if c == '\\':
                out.append(src[i + 1:i + 2])
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in '\'"':
            quote = c
            out.append(c)
            i += 1
            continue
        if src.startswith('//', i):
            j = src.find('\n', i)
            i = n if j < 0 else j
            continue
        if src.startswith('/*', i):
            j = src.find('*/', i + 2)
            i = n if j < 0 else j + 2
            continue
        out.append(c)
        i += 1
    return ''.join(out)


def check_dart_structure(path: str, report: Report) -> None:
    """括號是否成對、字串是否有收尾。抓得到漏打括號、漏打引號這類錯。"""
    src = strip_comments(read(path))
    rel = os.path.relpath(path, ROOT)
    pairs = {')': '(', ']': '[', '}': '{'}
    stack: list[tuple[str, int]] = []
    line = 1
    quote = None
    quote_line = 0
    i = 0
    while i < len(src):
        c = src[i]
        if c == '\n':
            line += 1
            if quote and not src.startswith(quote * 3, i - 2):
                # 單行字串跨行 → 字串沒有收尾。
                report.error(f'{rel}:{quote_line}', '字串沒有收尾（可能漏了引號）')
                quote = None
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in '\'"':
            if src.startswith(c * 3, i):
                j = src.find(c * 3, i + 3)
                line += src.count('\n', i, j)
                i = j + 3
                continue
            quote = c
            quote_line = line
        elif c in '([{':
            stack.append((c, line))
        elif c in ')]}':
            if not stack or stack[-1][0] != pairs[c]:
                report.error(f'{rel}:{line}', f'括號不成對：多了「{c}」')
                return
            stack.pop()
        i += 1
    if stack:
        c, ln = stack[-1]
        report.error(f'{rel}:{ln}', f'括號不成對：「{c}」沒有關起來')


def split_top(s: str) -> list[str]:
    """以最外層的逗號切開（略過字串與括號內）。"""
    parts, depth, cur, quote = [], 0, [], None
    i = 0
    while i < len(s):
        c = s[i]
        if quote:
            cur.append(c)
            if c == '\\':
                cur.append(s[i + 1])
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in '\'"':
            quote = c
        elif c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
        if c == ',' and depth == 0:
            parts.append(''.join(cur).strip())
            cur = []
        else:
            cur.append(c)
        i += 1
    tail = ''.join(cur).strip()
    if tail:
        parts.append(tail)
    return parts


def bracket_body(s: str, start: int) -> tuple[str, int]:
    """s[start] 是開括號；回傳括號內的內容與結束位置。"""
    open_c = s[start]
    close_c = {'(': ')', '[': ']', '{': '}'}[open_c]
    depth, quote, i = 0, None, start
    while i < len(s):
        c = s[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
        elif c in '\'"':
            quote = c
        elif c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                return s[start + 1:i], i
        i += 1
    raise ValueError('括號不成對')


STR_RE = re.compile(r"'((?:[^'\\]|\\.)*)'")


def strings_in(s: str) -> list[str]:
    return [m.group(1).replace("\\'", "'") for m in STR_RE.finditer(s)]


def named_arg(body: str, name: str) -> str | None:
    for part in split_top(body):
        if part.startswith(name + ':'):
            return part[len(name) + 1:].strip()
    return None


# ---------------------------------------------------------------- 資料載入

@dataclass
class Word:
    hangul: str
    meaning: str
    example: str
    example_zh: str
    sense: str | None
    file: str

    @property
    def id(self) -> str:
        return f'word:{self.hangul}' if self.sense is None else f'word:{self.hangul}#{self.sense}'


def load_words() -> list[Word]:
    words = []
    for path in sorted(glob.glob(os.path.join(DATA, 'vocab', 'topic_*.dart'))):
        src = strip_comments(read(path))
        for m in re.finditer(r'WordItem\(', src):
            body, _ = bracket_body(src, m.end() - 1)
            parts = split_top(body)
            pos = [strings_in(p)[0] if strings_in(p) else '' for p in parts[:4]]
            sense = None
            for p in parts[4:]:
                if p.startswith('sense:'):
                    sense = strings_in(p)[0]
            words.append(Word(*pos, sense=sense, file=os.path.basename(path)))
    return words


@dataclass
class GExample:
    ko: str
    zh: str
    wrong: list[str]


@dataclass
class GPoint:
    id: str
    title: str
    form: str
    explanation: list[str]
    examples: list[GExample]
    file: str


def load_grammar() -> list[GPoint]:
    points = []
    for path in sorted(glob.glob(os.path.join(DATA, 'grammar', 'lesson_*.dart'))):
        src = strip_comments(read(path))
        for m in re.finditer(r'GrammarPoint\(', src):
            body, _ = bracket_body(src, m.end() - 1)
            gid = strings_in(named_arg(body, 'id') or '')[0]
            title = strings_in(named_arg(body, 'title') or "''")[0]
            form = (strings_in(named_arg(body, 'form') or "''") or [''])[0]
            expl = strings_in(named_arg(body, 'explanation') or '')
            exs = []
            ex_src = named_arg(body, 'examples') or ''
            for em in re.finditer(r'GrammarExample\(', ex_src):
                eb, _ = bracket_body(ex_src, em.end() - 1)
                ep = split_top(eb)
                exs.append(GExample(strings_in(ep[0])[0], strings_in(ep[1])[0], strings_in(ep[2])))
            points.append(GPoint(gid, title, form, expl, exs, os.path.basename(path)))
    return points


@dataclass
class Item:
    display: str
    caption: str
    tag: str | None
    speaker: str | None = None


@dataclass
class Card:
    id: str
    kind: str  # concept / sound / grammar
    title: str = ''
    paragraphs: list[str] = field(default_factory=list)
    items: list[Item] = field(default_factory=list)
    grammar_id: str | None = None
    grammar_refs: list[str] = field(default_factory=list)


@dataclass
class Unit:
    func: str
    id: str
    title: str
    summary: str
    cards: list[Card]
    seed_words: list[str]
    seed_cloze: list[str]
    hidden_cards: list[str]


def flag_on(guard: str) -> bool:
    m = re.match(r'if \(CourseOptions\.(\w+)\)', guard)
    return FLAGS.get(m.group(1), False) if m else True


def strip_guard(elem: str) -> tuple[bool, str]:
    m = re.match(r'(if \(CourseOptions\.\w+\))\s*', elem)
    if not m:
        return True, elem
    return flag_on(m.group(1)), elem[m.end():].strip()


def parse_item(elem: str) -> Item | None:
    m = re.match(r'_(sound|line)\(', elem)
    if not m:
        return None
    body, _ = bracket_body(elem, m.end() - 1)
    parts = split_top(body)
    tag = None
    for p in parts:
        tm = re.match(r'SpeechTag\.(\w+)', p)
        if tm:
            tag = tm.group(1)
    if m.group(1) == 'line':
        return Item(strings_in(parts[1])[0], strings_in(parts[2])[0], tag, strings_in(parts[0])[0])
    return Item(strings_in(parts[0])[0], strings_in(parts[1])[0], tag)


def parse_card(elem: str, funcs: dict[str, str]) -> Card | None:
    gm = re.match(r"_grammarCard\('([^']*)'\)", elem)
    if gm:
        return Card(id=f'grammar:{gm.group(1)}', kind='grammar', grammar_id=gm.group(1))
    tm = re.match(r'CourseOptions\.(\w+)\s*\?\s*(_\w+)\(\)\s*:\s*(_\w+)\(\)', elem)
    if tm:
        name = tm.group(2) if FLAGS.get(tm.group(1), False) else tm.group(3)
        src = funcs[name]
        start = src.index('LessonCard.')
        return parse_card(src[start:].rstrip().rstrip(';'), funcs)
    m = re.match(r'LessonCard\.(\w+)\(', elem)
    if not m:
        return None
    body, _ = bracket_body(elem, m.end() - 1)
    card = Card(id=strings_in(named_arg(body, 'id') or "''")[0], kind=m.group(1))
    card.title = (strings_in(named_arg(body, 'title') or "''") or [''])[0]
    para = named_arg(body, 'paragraphs')
    if para:
        card.paragraphs = strings_in(para)
    refs = named_arg(body, 'grammarRefs')
    if refs:
        card.grammar_refs = strings_in(refs)
    items = named_arg(body, 'items')
    if items:
        lb = items.index('[')
        inner, _ = bracket_body(items, lb)
        for e in split_top(inner):
            on, e2 = strip_guard(e)
            if not on:
                continue
            it = parse_item(e2)
            if it:
                card.items.append(it)
    return card


def load_units() -> list[Unit]:
    src = strip_comments(read(os.path.join(DATA, 'unit_lessons.dart')))
    # 每個頂層函式：從「型別 名稱() =>」到下一個頂層定義。
    heads = list(re.finditer(r'^(\w[\w<>, ]*) (_\w+)\(\) =>', src, re.M))
    funcs = {}
    for i, h in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else len(src)
        funcs[h.group(2)] = src[h.start():end]
    order = re.findall(r'^\s+(_unit\w+)\(\),', src, re.M)
    units = []
    for name in order:
        body = funcs[name]
        lb = body.index('Lesson(') + len('Lesson')
        inner, _ = bracket_body(body, lb)
        uid = strings_in(named_arg(inner, 'id') or "''")[0]
        title = strings_in(named_arg(inner, 'title') or "''")[0]
        summary = (strings_in(named_arg(inner, 'summary') or "''") or [''])[0]
        cards_src = named_arg(inner, 'cards') or ''
        cb = cards_src.index('[')
        cards_inner, _ = bracket_body(cards_src, cb)
        cards, hidden = [], []
        for e in split_top(cards_inner):
            on, e2 = strip_guard(e)
            card = parse_card(e2, funcs)
            if card is None:
                continue
            (cards if on else hidden).append(card if on else card.id)
        seeds_src = named_arg(inner, 'quizSeeds') or ''
        seed_words, seed_cloze = [], []
        for m in re.finditer(r'_wordSeeds\(', seeds_src):
            b, _ = bracket_body(seeds_src, m.end() - 1)
            seed_words += strings_in(b)
        for m in re.finditer(r'_clozeSeeds\(', seeds_src):
            b, _ = bracket_body(seeds_src, m.end() - 1)
            seed_cloze += strings_in(b)
        units.append(Unit(name, uid, title, summary, cards, seed_words, seed_cloze, hidden))
    return units


# ---------------------------------------------------------------- 韓文規則

SINO = '일이삼사오육칠팔구십백천만'
NATIVE_SHORT = ['한', '두', '세', '네', '다섯', '여섯', '일곱', '여덟', '아홉', '열', '열한', '열두', '스무']
NATIVE_COUNTERS = ['시', '개', '명', '마리', '살', '잔', '병', '권', '대', '시간', '번째']
SINO_COUNTERS = ['분', '월', '층', '원', '년', '호']

MISSPELLINGS = {
    '되요': '돼요', '안되요': '안 돼요', '됬': '됐', '몇일': '며칠', '금새': '금세',
    '어떻해': '어떡해', '할께요': '할게요', '갈께요': '갈게요', '아니예요': '아니에요',
    '웬지': '왠지', '오랫만': '오랜만', '희안': '희한', '설겆이': '설거지',
    '육월': '유월', '십월': '시월',
}

SIMPLIFIED = set('这们说时会还对没发学习问题见让给过来点开关门书语话读写听买卖钱吗么应该认识请谢欢场业东车长头实现为与个号进远运动务办备气电脑网页纸笔饭鱼鸡猪马鸟飞爱亲难觉离历万岁兴乐医药简单复杂节产农级经济结际线红绿蓝银铁钟错间闭阳阴陆双变边')

# 單字卡上允許的片語（不是單字庫裡的單一詞條，但由單字庫的詞組成）。
PHRASES = {'주세요', '몇 시', '있어요', '없어요', '왜요', '이번 주', '다음 주', '여행할 거예요', '좋아요'}

POLITE_END = re.compile(r'(요|죠|니다|니까|십시오)$')
BANMAL_PRONOUN = re.compile(r'(^|[\s“"‘])(너|너는|넌|네가|니가|너의|너한테)(?=[\s,.?!”"]|$)')


def last_clause(text: str) -> str:
    parts = re.split(r'(?<=[.?!])\s+', text.strip())
    return re.sub(r'[.?!…~”"’\s]+$', '', parts[-1])


def lint_korean(text: str, where: str, report: Report, *, sentence: bool) -> None:
    """韓文句子的規則檢查。sentence=True 代表這是要朗讀的句子（不是說明文字）。"""
    if sentence and JAMO_RE.search(text):
        report.error(where, f'句子裡有單獨的字母（電腦語音念不準）：{text}')
    # 說明文字裡刻意舉出的錯誤寫法（例如「不要寫成 몇일」）不算錯：
    # 「不要寫成」後面、到。；，：（ 為止的韓文不檢查（列舉時用「、」）。
    if not sentence:
        text = re.sub(r'不要寫成[^。；，：（\n]*', '不要寫成…', text)
    shows_wrong_form = not sentence and re.search(r'（不是', text)
    for bad, good in MISSPELLINGS.items():
        if bad in text and not shows_wrong_form:
            report.error(where, f'拼寫錯誤「{bad}」應為「{good}」：{text}')
    # -(으)ㄹ게요／-(으)ㄹ걸요 拼寫是 게／걸，不是 께／껄（只是讀音像）。
    for m in re.finditer(r'([가-힣])(께요|껄요)', text):
        if (ord(m.group(1)) - 0xAC00) % 28 == 8:  # 前一個字的終聲是 ㄹ
            report.error(where, f'「{m.group(0)}」拼寫應為「…ㄹ{m.group(2)[0].replace("께", "게").replace("껄", "걸")}요」：{text}')
    # 月份：數字與 월 之間不空格（삼월）。
    m = re.search(rf'(^|[^가-힣])([{SINO}]) 월', text)
    if m:
        report.error(where, f'月份應連寫（例如 삼월）：{text}')
    # 漢字數詞＋固有數詞量詞（예：구 시、삼 개）。
    for c in NATIVE_COUNTERS:
        # 只檢查 1～99（백、천、만 以上可以接固有數詞的量詞，例如 백 개）。
        m = re.search(r'(^|[^가-힣])([일이삼사오육칠팔구십]+) ' + c + r'(?=[^가-힣]|[이에은을도부까예요만]|$)', text)
        if m:
            report.error(where, f'「{m.group(2)} {c}」：{c} 前面要用固有數詞（한、두、세…）：{text}')
    # 固有數詞＋漢字數詞量詞（예：세 층、다섯 원）。분 也可能是「位」，只警告。
    for c in SINO_COUNTERS:
        for n in NATIVE_SHORT:
            if re.search(rf'(^|[^가-힣]){n} {c}(?=[^가-힣]|[이에은을도부까예요만]|$)', text):
                (report.warn if c == '분' else report.error)(
                    where, f'「{n} {c}」：{c} 前面通常用漢字數詞（일、이、삼…）：{text}')
    # 하나／둘／셋／넷 直接接量詞要縮短。
    m = re.search(r'(하나|둘|셋|넷|스물) (개|명|마리|잔|병|권|살|시)(?=[^가-힣]|$)', text)
    if m:
        report.error(where, f'「{m.group(0)}」：接量詞時要縮短（한、두、세、네、스무）：{text}')
    # 空格：-(으)ㄹ 수 있다、-고 있다、것。
    for m in re.finditer(r' 수(있|없)(?!이)', text):
        report.error(where, f'「수{m.group(1)}」：수 與 있다／없다 之間要空格：{text}')
    for m in re.finditer(r'([가-힣])수(있|없)', text):
        report.error(where, f'「{m.group(0)}」應寫成「{m.group(1)} 수 {m.group(2)}」：{text}')
    for m in re.finditer(r'([가-힣])수 (있|없)', text):
        if is_rieul(m.group(1)) and not text[max(0, m.start() - 1):m.start()].strip() == '':
            pass
        if is_rieul(m.group(1)):
            report.error(where, f'「{m.group(0)}」：ㄹ 與 수 之間要空格：{text}')
    for m in re.finditer(r'([가-힣])고있', text):
        report.error(where, f'「{m.group(0)}」：-고 與 있다 之間要空格：{text}')
    for m in re.finditer(r'([가-힣])것', text):
        prev = m.group(1)
        word_start = m.start() == 0 or not is_syllable(text[m.start() - 1])
        if prev in '이그저무' and word_start:
            continue  # 이것、그것、저것
        if is_rieul(prev) or prev in '는은':
            report.warn(where, f'「{m.group(0)}」：冠形詞與「것」之間通常要空格：{text}')
    # 이에요／예요 與收尾音。
    for m in re.finditer(r'([가-힣])(이에요|예요)', text):
        prev = m.group(1)
        if m.group(2) == '예요' and has_batchim(prev):
            report.error(where, f'「{prev}예요」：有收尾音要用「이에요」：{text}')
        if m.group(2) == '이에요' and not has_batchim(prev) and prev != '니':
            report.error(where, f'「{prev}이에요」：沒有收尾音要用「예요」：{text}')
    for m in re.finditer(r'([가-힣])이예요', text):
        if has_batchim(m.group(1)):
            report.error(where, f'「{m.group(0)}」應為「{m.group(1)}이에요」：{text}')


def lint_particles(text: str, nouns: set[str], where: str, report: Report) -> None:
    """已知名詞後面的助詞是否配合收尾音（은／는、이／가、을／를、와／과、으로／로）。"""
    for m in re.finditer(r'(?<![가-힣])([가-힣]+?)(은|는|이|가|을|를|과|와|으로|로)(?=[\s,.?!”"…]|$)', text):
        noun, p = m.group(1), m.group(2)
        if noun not in nouns or len(noun) < 2 and noun not in {'물', '차', '집', '방', '책', '역', '밥', '빵', '옷', '돈', '말', '개', '소', '배', '눈', '비', '산', '강', '불', '꽃', '술', '약', '표', '컵', '공', '팔', '발', '손', '귀', '코', '입', '목', '등', '키', '병', '반', '밖', '안', '앞', '뒤', '옆', '위'}:
            continue
        last = noun[-1]
        need_batchim = p in ('은', '이', '을', '과', '으로')
        if p == '으로' and is_rieul(last):
            report.error(where, f'「{noun}{p}」：收尾音 ㄹ 後面用「로」：{text}')
            continue
        if p == '로' and is_rieul(last):
            continue
        if need_batchim != has_batchim(last):
            fix = {'은': '는', '는': '은', '이': '가', '가': '이', '을': '를', '를': '을',
                   '과': '와', '와': '과', '으로': '로', '로': '으로'}[p]
            report.error(where, f'「{noun}{p}」：助詞與收尾音不合，應為「{noun}{fix}」：{text}')


def lint_chinese(text: str, where: str, report: Report) -> None:
    bad = sorted({c for c in text if c in SIMPLIFIED})
    if bad:
        report.error(where, f'出現簡體字 {"".join(bad)}：{text}')


# ---------------------------------------------------------------- 單元規則

def check_units(units: list[Unit], words: list[Word], grammar: list[GPoint], report: Report) -> None:
    word_by_id = {w.id: w for w in words}
    gids = {g.id for g in grammar}
    nouns = {w.hangul for w in words if not w.hangul.endswith('다') and ' ' not in w.hangul}
    shown_text = ''
    used_grammar: dict[str, str] = {}
    for idx, u in enumerate(units, start=1):
        where = f'{u.id}（{u.title}）'
        if u.id != f'unit-{idx}':
            report.error(where, f'單元 id 應為 unit-{idx}')
        ids = [c.id for c in u.cards]
        if len(ids) != len(set(ids)):
            report.error(where, '卡片 id 重複')
        if len(u.cards) < 5:
            report.error(where, '卡片少於 5 張')
        if not u.cards or not u.cards[-1].id.endswith(':dialog'):
            report.error(where, '最後一張卡片應該是對話（:dialog）')
        if idx <= 5 and any(c.kind == 'grammar' for c in u.cards):
            report.error(where, '單元 1～5 的文法要寫在說明卡（grammarRefs），不要插入文法庫的卡片')
        for c in u.cards:
            cw = f'{u.id} {c.id}'
            for gid in ([c.grammar_id] if c.kind == 'grammar' else []) + c.grammar_refs:
                if gid not in gids:
                    report.error(cw, f'文法點不存在：{gid}')
                if gid in used_grammar:
                    report.error(cw, f'文法點已放在 {used_grammar[gid]}')
                used_grammar[gid] = u.id
            if c.grammar_refs and c.kind != 'concept':
                report.error(cw, 'grammarRefs 只能放在說明卡（concept）')
            if c.kind == 'grammar':
                continue
            if not c.id.startswith(f'u{idx}:'):
                report.error(cw, f'卡片 id 應以 u{idx}: 開頭')
            lint_chinese(c.title, cw, report)
            for p in c.paragraphs:
                lint_chinese(p, cw, report)
                lint_korean(p, cw, report, sentence=False)
            for it in c.items:
                lint_chinese(it.caption, cw, report)
                lint_korean(it.display, cw, report, sentence=True)
                lint_particles(it.display, nouns, cw, report)
                if BANMAL_PRONOUN.search(it.display):
                    report.error(cw, f'單元句子出現半語代名詞：{it.display}')
                is_sentence = bool(re.search(r'[.?!]$', it.display))
                if is_sentence:
                    if it.tag is None:
                        report.error(cw, f'句子沒有語氣標籤：{it.display}')
                    elif it.tag not in ('polite', 'formal', 'honorific'):
                        report.error(cw, f'不允許的語氣標籤 {it.tag}：{it.display}')
                    if not POLITE_END.search(last_clause(it.display)):
                        report.error(cw, f'句尾不是敬語：{it.display}')
                    if it.tag == 'formal' and not re.search(r'(니다|니까|십시오)$', last_clause(it.display)):
                        report.warn(cw, f'標成 합니다體，但句尾不是 -ㅂ니다：{it.display}')
                    if it.tag == 'polite' and re.search(r'(시|세)요$', last_clause(it.display)) \
                            and not re.search(r'(주세요|안녕하세요|여보세요)$', last_clause(it.display)):
                        report.warn(cw, f'句尾有 -(으)세요，標籤可能應為 honorific：{it.display}')
                    if it.tag == 'honorific' and not re.search(r'(세요|셔요|시[겠었]|십니|으세|하세|되세)', it.display):
                        report.warn(cw, f'標成尊敬說法，但看不到 -(으)시-：{it.display}')
                elif it.tag is not None:
                    report.warn(cw, f'不是句子卻有語氣標籤：{it.display}')
            shown_text += c.title + '\n' + '\n'.join(c.paragraphs) + '\n'
            shown_text += '\n'.join(f'{it.display}\n{it.caption}' for it in c.items) + '\n'
        if u.seed_cloze:
            report.error(where, f'單元測驗不應有文法填空題（例句可能含沒學過的字）：{u.seed_cloze}')
        if len(u.seed_words) * 2 < 20:
            report.error(where, f'單字測驗種子太少（{len(u.seed_words)} 個字，至少 10 個）')
        if len(u.seed_words) != len(set(u.seed_words)):
            report.error(where, '單字測驗種子重複')
        for sid in u.seed_words:
            w = word_by_id.get(sid)
            if w is None:
                report.error(where, f'單字不存在於單字庫：{sid}')
                continue
            if w.hangul not in shown_text:
                report.error(where, f'測驗考了還沒出現過的字：{w.hangul}')
        # 單字卡上的詞要在單字庫裡（動詞以活用形顯示時，括號裡要有原形）。
        for c in u.cards:
            if c.id.endswith(':words'):
                for it in c.items:
                    base = re.search(r'（([가-힣 ]+다)）', it.caption)
                    key = base.group(1) if base else it.display
                    if key not in {w.hangul for w in words} and key not in PHRASES:
                        report.warn(f'{u.id} {c.id}', f'單字卡的詞不在單字庫：{it.display}')


def check_words(words: list[Word], report: Report) -> None:
    ids = [w.id for w in words]
    for wid in {i for i in ids if ids.count(i) > 1}:
        report.error('單字庫', f'id 重複：{wid}')
    nouns = {w.hangul for w in words if not w.hangul.endswith('다') and ' ' not in w.hangul}
    for w in words:
        where = f'單字 {w.hangul}（{w.file}）'
        lint_chinese(w.meaning + w.example_zh, where, report)
        lint_korean(w.example, where, report, sentence=True)
        lint_particles(w.example, nouns, where, report)
        if not POLITE_END.search(last_clause(w.example)):
            report.error(where, f'例句句尾不是敬語：{w.example}')


def check_grammar(points: list[GPoint], report: Report) -> None:
    for g in points:
        where = f'文法 {g.id}（{g.file}）'
        for e in g.explanation:
            lint_chinese(e, where, report)
            lint_korean(e, where, report, sentence=False)
        if len(g.examples) < 3:
            report.error(where, '例句少於 3 句')
        casual = g.file == 'lesson_speech_levels.dart' and (g.id.startswith('banmal') or g.id == 'speech_banmal')
        for e in g.examples:
            if e.ko.count('[') != 1 or e.ko.count(']') != 1:
                report.error(where, f'例句要有一組 [答案]：{e.ko}')
                continue
            answer = e.ko[e.ko.index('[') + 1:e.ko.index(']')]
            plain = e.ko.replace('[', '').replace(']', '')
            lint_chinese(e.zh, where, report)
            lint_korean(plain, where, report, sentence=True)
            if len(e.wrong) != 3 or len(set(e.wrong)) != 3:
                report.error(where, f'錯誤選項要剛好 3 個且不重複：{e.ko}')
            if answer in e.wrong:
                report.error(where, f'錯誤選項包含正確答案：{e.ko}')
            if not casual and g.id != 'eu_bsida' and not re.search(r'ㅂ시다$|읍시다$|합시다$', last_clause(plain)) \
                    and not POLITE_END.search(last_clause(plain)):
                report.warn(where, f'例句句尾不是敬語：{plain}')


def check_speak_strings(report: Report) -> None:
    for path in [os.path.join(DATA, 'unit_lessons.dart'), os.path.join(DATA, 'lessons.dart')]:
        src = strip_comments(read(path))
        for m in re.finditer(r"speak: '([^']*)'", src):
            if JAMO_RE.search(m.group(1)):
                report.error(os.path.basename(path), f'speak 含單獨字母：{m.group(1)}')


# ---------------------------------------------------------------- 主程式

def main() -> int:
    report = Report()
    for path in sorted(glob.glob(os.path.join(ROOT, 'lib', '**', '*.dart'), recursive=True)) + \
            sorted(glob.glob(os.path.join(ROOT, 'test', '*.dart'))):
        check_dart_structure(path, report)
    if report.errors:
        print_report(report, [])
        return 1
    words = load_words()
    grammar = load_grammar()
    units = load_units()
    check_words(words, report)
    check_grammar(grammar, report)
    check_units(units, words, grammar, report)
    check_speak_strings(report)
    print_report(report, units)
    if '--list' in sys.argv:
        for u in units:
            print(f'\n## {u.id} {u.title}')
            for c in u.cards:
                for it in c.items:
                    if re.search(r'[.?!]$', it.display):
                        sp = f'({it.speaker}) ' if it.speaker else ''
                        print(f'  [{c.id}] {sp}{it.display}｜{it.caption}｜{it.tag}')
    if '--checklist' in sys.argv:
        print('已產生', write_checklist(units))
    return 1 if report.errors else 0


# 審查時記下、但沒有改的地方（請母語者特別看）。
CHECKLIST_NOTES = {
    '이것은 뭐예요?': '正確但偏書面；口語常說「이건 뭐예요?」「이게 뭐예요?」',
    '더 주세요.': '也常說「좀 더 주세요.」',
    '라면 둘 주세요.': '也常說「라면 두 개 주세요.」',
    '콜라 세 잔 주세요.': '罐裝、瓶裝可樂通常用 캔／병',
    '열쇠 주세요.': '飯店多半是房卡（카드키）',
    '여기서 내려 주세요.': '兩個 AI 審查意見不同，請母語者判斷是否自然',
    '영어 할 수 있어요?': '對陌生人更客氣可說「영어 하실 수 있어요?」（含 -시-，目前隱藏）',
    '가족이 몇 명이에요?': '對長輩更客氣可說「가족이 어떻게 되세요?」',
}

TAG_NAMES = {'polite': '日常禮貌（해요體）', 'formal': '正式（합니다體）', 'honorific': '尊敬說法（-세요）'}


def write_checklist(units: list[Unit]) -> str:
    out = ['# 查核清單：單元句子', '',
           '用途：交給 Copilot、其他 AI 或母語者逐句檢查。請不要先告訴對方這些句子是對的，只問「自然嗎？對陌生人夠禮貌嗎？」。',
           '',
           '這份清單由 `python tool/validate_content.py --checklist` 自動產生，內容就是 App 目前顯示的句子（隱藏的職場版與進階尊敬說法不在裡面）。',
           '所有句子都經過自動錯誤偵測與 AI 審查，**仍屬「待查核」**，不是官方或母語者確認。',
           '',
           '請檢查者在最後一欄填：✅ 自然／⚠️ 不自然（請寫更自然的說法）／❌ 錯誤。', '']
    for u in units:
        out += [f'## {u.title}', '', '| # | 韓文 | 中文 | 語氣 | 備註 | 檢查結果 |', '|---|---|---|---|---|---|']
        n = 0
        for c in u.cards:
            for it in c.items:
                if not re.search(r'[.?!]$', it.display):
                    continue
                n += 1
                sp = f'({it.speaker}) ' if it.speaker else ''
                out.append(f'| {n} | {sp}{it.display} | {it.caption} | {TAG_NAMES.get(it.tag, "")} | '
                           f'{CHECKLIST_NOTES.get(it.display, "")} | |')
        out.append('')
    path = os.path.join(ROOT, 'docs', 'review_checklist.md')
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))
    return path


def print_report(report: Report, units: list[Unit]) -> None:
    for i in report.issues:
        print(f'[{i.level}] {i.where}：{i.message}')
    n_sent = sum(1 for u in units for c in u.cards for it in c.items if re.search(r'[.?!]$', it.display))
    print(f'\n單元 {len(units)} 個、單元句子 {n_sent} 句；錯誤 {len(report.errors)} 個、警告 {len(report.warnings)} 個。')


if __name__ == '__main__':
    sys.exit(main())
