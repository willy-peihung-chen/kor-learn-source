# 高品質語音檔（MeloTTS）

網頁版（iPhone）原本用手機內建的語音，iOS 18 之後 Safari 常只給機器感很重的語音。
改成：事先用 MeloTTS 韓文模型把 App 裡會朗讀的韓文全部做成 mp3，App 點喇叭時有語音檔就播語音檔，沒有才用手機語音。

- 模型：MeloTTS 韓文（myshell-ai/MeloTTS-Korean），MIT 授權，可以放進公開的 App。
- 試聽：2026-11-19 你在 Hugging Face 試用頁聽過，覺得比神經網路語音還好。
- 仍然是機器合成，不是真人錄音；發音規則（連音、緊音等）偶爾可能念錯，聽到怪的請記下句子。

## 第一次安裝（只做一次）

1. 安裝 **Python 3.10**（MeloTTS 用的 torch 1.x 不支援 3.11 以後）：到 python.org 下載 Python 3.10 的 Windows installer（3.10.11 是最後一個有 installer 的版本），安裝時保留預設勾選的「py launcher」即可。裝好後 `py -3.10 --version` 要能顯示版本。
2. 在 `C:\game\kor_learn` 執行：

   ```
   powershell -ExecutionPolicy Bypass -File tool\setup_tts.ps1
   ```

   會建立 `.venv_tts`（不上傳 GitHub），下載約 2～3 GB，需要一段時間。

## 產生語音檔

```
.venv_tts\Scripts\python tool\make_audio.py --sample
```
先做 6 句放在 `tool\audio_sample\`，用電腦播放器試聽。沒問題再做全部：

```
.venv_tts\Scripts\python tool\make_audio.py
```

- 目前約 5,480 段韓文（單元句子、單字、例句、文法例句、說明裡的韓文、音節）。第一次會花一段時間（約一到數小時，看電腦速度）。
- 可以隨時按 Ctrl+C 中斷，下次執行會從沒做完的接著做。
- 做好的放在 `web\audio\`（`index.json` 是清單）。這個資料夾不放進原始碼倉庫（太大，而且可以重新產生），但打包網頁版時會一起上線。
- 教材有新增或修改後，再執行一次 `make_audio.py`：只會補做新的句子。加上 `--prune` 會刪掉已經不用的舊檔。
- `tool\audio_texts.tsv` 列出每個語音檔對應的韓文，聽到念錯時可以查。

做完之後照平常上傳網頁版：

```
powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1
```

## 原理

- 檔名 = 句子 UTF-8 位元組數 + FNV-1a 雜湊，Python（`tool/make_audio.py` 的 `audio_key`）和 App（`lib/audio/audio_key.dart`）算法相同，`test/audio_key_test.dart` 檢查兩邊一致。
- App 啟動時讀 `audio/index.json`；點喇叭時算出檔名，在清單裡就播 `audio/<檔名>.mp3`，不在就用手機語音。
- 只有網頁版用語音檔；Windows、Android 版仍用裝置語音。
