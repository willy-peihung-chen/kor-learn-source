#!/usr/bin/env python3
"""依國立國語院「한국어 학습용 어휘 목록」產生 lib/data/word_level_data.dart。

用法（在專案根目錄）：
    python tool/gen_word_levels.py           # 重新產生檔案
    python tool/gen_word_levels.py --check   # 只檢查檔案是否與詞表一致（不一致時結束碼為 1）

只記錄 1 級（A）與 2 級（B）的字；3 級（C）與詞表沒有的字，App 內一律歸在「其他」。
同形詞（詞表中同一個字有多筆）取最常用的等級。
詞表檔案放在 docs/sources/，CP949 或 UTF-8 皆可。
"""

from __future__ import annotations

import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB = os.path.join(ROOT, 'lib', 'data', 'vocab')
OUT = os.path.join(ROOT, 'lib', 'data', 'word_level_data.dart')
LIST_DIR = os.path.join(ROOT, 'docs', 'sources')
GRADE = {'A': 1, 'B': 2}


def find_list(path: str | None = None) -> str | None:
    if path:
        return path
    hits = glob.glob(os.path.join(LIST_DIR, '*어휘*목록*.txt'))
    return hits[0] if hits else None


def read_text(path: str) -> str:
    raw = open(path, 'rb').read()
    for enc in ('utf-8-sig', 'cp949'):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    raise SystemExit(f'無法解碼詞表：{path}')


def official_levels(path: str) -> dict[str, int]:
    levels: dict[str, int] = {}
    for line in read_text(path).splitlines():
        parts = line.split('\t')
        if len(parts) < 5 or not parts[0].strip().isdigit():
            continue
        word = re.sub(r'\d+$', '', parts[1].strip())
        grade = GRADE.get(parts[-1].strip())
        if grade is not None:
            levels[word] = min(levels.get(word, 9), grade)
    return levels


def vocab_words() -> list[str]:
    words: list[str] = []
    for path in sorted(glob.glob(os.path.join(VOCAB, 'topic_*.dart'))):
        text = '\n'.join(
            l for l in open(path, encoding='utf-8').read().split('\n')
            if not l.lstrip().startswith('//'))
        words += re.findall(r"WordItem\(\s*'([^']+)'", text)
    return words


def render(levels: dict[str, int]) -> str:
    items = sorted(levels.items())
    rows = []
    for i in range(0, len(items), 4):
        rows.append('  ' + ' '.join(f"'{w}': {g}," for w, g in items[i:i + 4]))
    return (
        '// 自動產生，請勿手改。重新產生：python tool/gen_word_levels.py\n'
        '// 資料來源：國立國語院「한국어 학습용 어휘 목록」（2003），1 = 1 級（A），2 = 2 級（B）。\n'
        '// 只列出本 App 單字庫有收錄、且在詞表 1 級或 2 級的字；其餘一律視為「其他」。\n'
        'const Map<String, int> wordLevelData = <String, int>{\n'
        + '\n'.join(rows) + '\n};\n')


def expected(list_path: str | None = None) -> str | None:
    path = find_list(list_path)
    if path is None or not os.path.exists(path):
        return None
    official = official_levels(path)
    mine = {w: official[w] for w in set(vocab_words()) if w in official}
    return render(mine)


def main() -> int:
    list_path = None
    for a in sys.argv[1:]:
        if not a.startswith('--'):
            list_path = a
    text = expected(list_path)
    if text is None:
        print('找不到詞表檔（docs/sources/ 底下的「한국어 학습용 어휘 목록」）。')
        return 1
    if '--check' in sys.argv:
        current = open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else ''
        if current != text:
            print('lib/data/word_level_data.dart 與詞表不一致，請重新執行 gen_word_levels.py。')
            return 1
        print('word_level_data.dart 與詞表一致。')
        return 0
    with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    print('已寫入', OUT)
    return 0


if __name__ == '__main__':
    sys.exit(main())
