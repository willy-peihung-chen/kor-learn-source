"""把 App 裡所有會朗讀的韓文，預先做成高品質語音檔（MeloTTS 韓文模型）。

App（網頁版）點喇叭時，先找有沒有對應的語音檔；有就播放語音檔，沒有才用手機內建的語音。

用法（在專案資料夾執行，要先照 docs/audio.md 裝好 MeloTTS）：

    .venv_tts\\Scripts\\python tool\\make_audio.py --list      只列出要做的句子數量，不產生聲音
    .venv_tts\\Scripts\\python tool\\make_audio.py --sample    先做 6 句試聽，放在 tool\\audio_sample\\
    .venv_tts\\Scripts\\python tool\\make_audio.py             做全部（已經做過的會跳過，可以中斷後再接著做）
    .venv_tts\\Scripts\\python tool\\make_audio.py --prune     做完後刪掉已經不用的舊語音檔

語音檔放在 web/audio/<key>.mp3，清單在 web/audio/index.json。
<key> 的算法和 lib/audio/audio_key.dart 完全相同（UTF-8 位元組數 + FNV-1a 32 位元雜湊），兩邊不可只改一邊。
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / 'lib' / 'data'
OUT_DIR = ROOT / 'web' / 'audio'
SAMPLE_DIR = ROOT / 'tool' / 'audio_sample'
TEXT_LIST = ROOT / 'tool' / 'audio_texts.tsv'

# 語速：1.0 為模型預設；學習用稍微放慢。
SPEED = 0.9
# mp3 位元率（kbps）。人聲 48 kbps 單聲道已經很清楚，檔案也小。
BITRATE = 48

# 和 lib/util/korean_runs.dart 相同：韓文音節，中間可以夾一般空白或不換行空白。
KOREAN_RUN = re.compile(r'[가-힣]+(?:[  ]+[가-힣]+)*')
HANGUL = re.compile(r'[가-힣]')
# 整段都是韓文句子（韓文、空白、標點、數字）時，整句也做一個語音檔（保留問號等語調）。
KOREAN_ONLY = re.compile(r'[가-힣\s.,?!~…\'"0-9]+')
DART_STRING = re.compile(r"'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"")

SAMPLE_TEXTS = [
    '안녕하세요. 저는 민수예요.',
    '이거 얼마예요?',
    '천천히 말해 주세요.',
    '지하철이 버스보다 더 빨라요.',
    '와, 오늘이 생일이네요! 생일 축하해요.',
    '사과',
]

# 基本子音（初聲索引）與基本母音（中聲索引），和字母課的音節表一致。
BASIC_INITIALS = [0, 2, 3, 5, 6, 7, 9, 11, 12, 14, 15, 16, 17, 18]
BASIC_MEDIALS = [0, 2, 4, 6, 8, 12, 13, 17, 18, 20]


def audio_key(text: str) -> str:
    """和 lib/audio/audio_key.dart 的 audioKey() 相同。"""
    data = text.strip().encode('utf-8')
    h = 0x811C9DC5
    for byte in data:
        h ^= byte
        h = (h * 16777619) & 0xFFFFFFFF
    return f'{len(data)}-{h:08x}'


def _unescape(raw: str) -> str:
    """Dart 字串的跳脫字元：\\n 換行，其他 \\x 就是 x 本身。"""
    return re.sub(r'\\(.)', lambda m: '\n' if m.group(1) == 'n' else m.group(1), raw)


def collect_texts() -> list[str]:
    """從教材資料檔收集所有可能被朗讀的韓文。"""
    texts: set[str] = set()

    def add(text: str) -> None:
        text = text.strip()
        if text and HANGUL.search(text):
            texts.add(text)

    for path in sorted(DATA_DIR.rglob('*.dart')):
        source = path.read_text(encoding='utf-8')
        for match in DART_STRING.finditer(source):
            literal = _unescape(match.group(1) if match.group(1) is not None else match.group(2))
            if not HANGUL.search(literal):
                continue
            # 文法例句：'한국어를 잘하[네요].' → 朗讀的是填好答案的整句。
            if '[' in literal and ']' in literal and literal.index('[') < literal.index(']'):
                literal = literal.replace('[', '').replace(']', '')
            if KOREAN_ONLY.fullmatch(literal):
                add(literal)
            for run in KOREAN_RUN.findall(literal):
                add(run)

    # 字母課與測驗用的基本音節（程式算出來的，不在資料檔的字串裡）。
    for initial in BASIC_INITIALS:
        for medial in BASIC_MEDIALS:
            add(chr(0xAC00 + (initial * 21 + medial) * 28))

    return sorted(texts)


def check_collisions(texts: list[str]) -> None:
    seen: dict[str, str] = {}
    for text in texts:
        key = audio_key(text)
        if key in seen and seen[key] != text:
            sys.exit(f'雜湊碰撞，請回報：{seen[key]!r} 與 {text!r} 都是 {key}')
        seen[key] = text


def _install_mecab_shim() -> None:
    """Windows 上讓 MeloTTS 的韓文發音轉換（g2pkk）能用韓文詞性分析器。

    g2pkk 在 Windows 只找 eunjeon 套件，但 eunjeon 需要自己編譯、很難裝。
    這裡改用 python-mecab-ko（有現成的 Windows 版本），包成 eunjeon 的樣子給 g2pkk 用。
    python-mecab-ko 裝在 .venv_tts/mecab_ko（和日文的 MeCab 分開，避免 Windows 不分大小寫的資料夾名稱衝突）。
    兩個都不能用時退回簡單斷詞：仍可產生語音，但少數發音規則（例如部分緊音）可能不準。
    """
    import platform
    import types

    if platform.system() != 'Windows' or 'eunjeon' in sys.modules:
        return
    extra = ROOT / '.venv_tts' / 'mecab_ko'
    if extra.exists():
        sys.path.insert(0, str(extra))
    try:
        from mecab import MeCab as KoreanMeCab
        tagger = KoreanMeCab()

        def pos(text: str):
            return tagger.pos(text)
    except Exception as error:  # 退回簡單斷詞
        print(f'注意：韓文詞性分析器無法使用（{error}），改用簡單斷詞；少數發音規則可能不準。')

        def pos(text: str):
            return [(word, 'NNG') for word in text.split()]

    class Mecab:  # 和 eunjeon.Mecab 相同的用法
        def __init__(self, *args, **kwargs) -> None:
            pass

        def pos(self, text, *args, **kwargs):
            return pos(text)

    import importlib.machinery

    module = types.ModuleType('eunjeon')
    module.Mecab = Mecab
    # g2pkk 先用 importlib.util.find_spec('eunjeon') 檢查有沒有裝，需要 __spec__。
    module.__spec__ = importlib.machinery.ModuleSpec('eunjeon', None)
    sys.modules['eunjeon'] = module


class Synth:
    """MeloTTS 韓文模型 → mp3。"""

    def __init__(self) -> None:
        _install_mecab_shim()
        try:
            import lameenc  # noqa: F401
            import numpy  # noqa: F401
            import soundfile  # noqa: F401
            from melo.api import TTS
        except ImportError as error:
            sys.exit(f'缺少套件（{error}）。請先照 docs/audio.md 安裝 MeloTTS 與 lameenc。')
        print('載入 MeloTTS 韓文模型（第一次會下載模型，需要幾分鐘）…')
        self.model = TTS(language='KR', device='auto')
        self.speaker = self.model.hps.data.spk2id['KR']
        self.tmp = Path(tempfile.mkdtemp()) / 'clip.wav'

    def to_mp3(self, text: str, out_path: Path) -> None:
        import lameenc
        import numpy as np
        import soundfile as sf

        self.model.tts_to_file(text, self.speaker, str(self.tmp), speed=SPEED, quiet=True)
        audio, rate = sf.read(str(self.tmp), dtype='float32')
        if audio.ndim > 1:
            audio = audio.mean(axis=1)
        peak = float(np.max(np.abs(audio))) if audio.size else 0.0
        if peak > 0:
            audio = audio * (0.9 / peak)
        pcm = (np.clip(audio, -1.0, 1.0) * 32767).astype('<i2').tobytes()

        encoder = lameenc.Encoder()
        encoder.set_bit_rate(BITRATE)
        encoder.set_in_sample_rate(int(rate))
        encoder.set_channels(1)
        encoder.set_quality(2)
        mp3 = encoder.encode(pcm) + encoder.flush()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        tmp_out = out_path.with_suffix('.part')
        tmp_out.write_bytes(mp3)
        tmp_out.replace(out_path)


def write_index(texts: list[str]) -> int:
    keys = [audio_key(t) for t in texts if (OUT_DIR / f'{audio_key(t)}.mp3').exists()]
    index = {
        'version': 1,
        'voice': 'MeloTTS-KR',
        'speed': SPEED,
        'files': sorted(set(keys)),
    }
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / 'index.json').write_text(json.dumps(index, ensure_ascii=False), encoding='utf-8')
    return len(index['files'])


def main() -> None:
    # 輸出存成記錄檔時，Windows 用 cp950（繁中）編碼，印不出韓文會直接當掉。
    # 印不出的字改成 \uXXXX 顯示，中文訊息照常；語音檔本身不受影響。
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors='backslashreplace')
        except AttributeError:
            pass
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--list', action='store_true', help='只列出要做的句子，不產生聲音')
    parser.add_argument('--sample', action='store_true', help='先做幾句試聽')
    parser.add_argument('--prune', action='store_true', help='刪掉已經不用的舊語音檔')
    parser.add_argument('--limit', type=int, default=0, help='這次最多做幾句（0 = 全部）')
    args = parser.parse_args()

    texts = collect_texts()
    check_collisions(texts)
    with TEXT_LIST.open('w', encoding='utf-8') as f:
        for text in texts:
            f.write(f'{audio_key(text)}\t{text}\n')
    todo = [t for t in texts if not (OUT_DIR / f'{audio_key(t)}.mp3').exists()]
    print(f'共 {len(texts)} 段韓文，已有語音檔 {len(texts) - len(todo)} 段，待產生 {len(todo)} 段。')
    print(f'清單：{TEXT_LIST.relative_to(ROOT)}')
    if args.list:
        return

    synth = Synth()

    if args.sample:
        for i, text in enumerate(SAMPLE_TEXTS, 1):
            out = SAMPLE_DIR / f'sample_{i}.mp3'
            synth.to_mp3(text, out)
            print(f'  {out.relative_to(ROOT)}  {text}')
        print('完成。請打開 tool\\audio_sample 資料夾試聽。')
        return

    if args.limit:
        todo = todo[:args.limit]
    start = time.time()
    for i, text in enumerate(todo, 1):
        try:
            synth.to_mp3(text, OUT_DIR / f'{audio_key(text)}.mp3')
        except Exception as error:  # 單句失敗不中斷，最後列出
            print(f'  失敗：{text!r}：{error}')
        if i % 25 == 0 or i == len(todo):
            elapsed = time.time() - start
            left = elapsed / i * (len(todo) - i)
            print(f'  {i}/{len(todo)}，已花 {elapsed / 60:.1f} 分鐘，預估剩 {left / 60:.1f} 分鐘')
            write_index(texts)  # 隨時可以中斷：已做好的會寫進清單

    if args.prune:
        used = {audio_key(t) for t in texts}
        removed = 0
        for path in OUT_DIR.glob('*.mp3'):
            if path.stem not in used:
                path.unlink()
                removed += 1
        print(f'刪掉 {removed} 個不用的語音檔。')

    count = write_index(texts)
    total_mb = sum(p.stat().st_size for p in OUT_DIR.glob('*.mp3')) / 1e6
    print(f'完成：web/audio 共有 {count} 個語音檔，{total_mb:.1f} MB。')


if __name__ == '__main__':
    main()
