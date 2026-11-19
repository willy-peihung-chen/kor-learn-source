# 交接包：韓文自學 App（2026-11-19 中午）

新對話開頭請貼：這份交接包＋「專案開發標準流程（給 Claude 的指示）」的精簡指示。

## 1. 專案基本資料

| 項目 | 內容 |
| --- | --- |
| 專案 | 韓文自學 Flutter App（MVP v0.1），給零基礎繁中使用者，目標 TOPIK I；用敬語和陌生人有禮貌地溝通 |
| 資料夾 | `C:\game\kor_learn`（使用者的 Windows 電腦，Claude 透過連結的電腦讀寫一般檔案；不能執行指令、不能寫 `.git`） |
| 原始碼倉庫 | https://github.com/willy-peihung-chen/kor-learn-source （Public） |
| 上線倉庫 | https://github.com/willy-peihung-chen/kor-learn （只放打包結果，由 `tool/deploy_web.ps1` 整包強制推送） |
| 線上網址 | https://willy-peihung-chen.github.io/kor-learn/ （iPhone 用 Safari「加入主畫面」） |
| commit 信箱 | `325269322+willy-peihung-chen@users.noreply.github.com`（不用 Gmail） |
| 本機網頁 | `flutter run -d chrome --web-port=5000` → http://localhost:5000 |
| 使用者手機 | iPhone（原生 App 做不了，用網頁版） |

## 2. 目前內容

- 韓文字母課 6 堂、基礎文法課（含「溝通常用說法」13 個文法點）、半語額外課 1 堂、單元 1～31、單字庫約 1,089 個、辭典。
- 單元 21～31：日期與生日、打電話、說味道、銀行換錢、東西不見了、描述人和東西、經驗、比較、心情、學校與工作、道別。
- 自動偵測：`python tool/validate_content.py`（0 錯誤、0 警告，649 句）；自我測試 `tool/validate_selftest.py`。
- 逐句查核清單：`docs/review_checklist.md`（也在 Project 的 `claude/review_checklist.md`）。
- 最後一次 analyze／test（11/19 00:45 前後）：No issues found、130 項全部通過。

## 3. 進行中：高品質語音檔（MeloTTS）

使用者在 Hugging Face 試聽 MeloTTS 韓文後覺得「比神經網路語音還好」，決定採用。說明：`docs/audio.md`。

- 做法：`tool/make_audio.py` 收集約 5,480 段韓文 → MeloTTS → `web/audio/<key>.mp3` ＋ `index.json`；網頁版點喇叭時有語音檔就播，沒有才用手機語音（`lib/audio/platform_speech_web.dart`、`lib/audio/audio_key.dart`，雜湊和 Python 一致，`test/audio_key_test.dart` 檢查）。
- 已完成：Python 3.10 安裝；`.venv_tts` 建好、MeloTTS／lameenc 裝好；`setuptools<81` 已裝（新版沒有 pkg_resources）；python-mecab-ko 裝在 `.venv_tts\mecab_ko`（g2pkk 在 Windows 只找 eunjeon，`make_audio.py` 用 shim 假裝成 eunjeon，並補了 `__spec__`）。
- **尚未成功**：最後一次修正（`__spec__`）之後使用者還沒重跑 `--sample`；`tool\audio_sample` 還沒有檔案、`web\audio` 還沒有語音檔。
- 下一步：
  1. `.venv_tts\Scripts\python tool\make_audio.py --sample` → `explorer tool\audio_sample` 試聽 6 句。
  2. 滿意 → `.venv_tts\Scripts\python tool\make_audio.py`（全部，可中斷續做，約一到數小時）。
  3. `powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1` 上線 → iPhone 滑掉 App 重開測試。
  4. 若出現「韓文詞性分析器無法使用」：會退回簡單斷詞（少數緊音規則可能不準），要再查 python-mecab-ko 載入問題。

## 4. 其他未完成／未確認

- iPhone 實機：圖示方框問題（拖曳上傳漏 `assets`）已改用 `deploy_web.ps1` 重新上傳，**使用者尚未回報圖示是否恢復**。
- iPhone 語音挑選修正（避開 Eloquence 語音）已在上線版，**聲音是否改善未回報**；根本解法是語音檔（第 3 節）。
- Git：最後一個 commit 是「新增網頁版上傳腳本，修正圖示缺漏」。之後的修改（語音挑選、語音檔功能、setup 修正、開發日誌、本交接包）**還沒 commit**。確認 analyze／test 通過後請使用者執行：

  ```
  git add .
  git commit -m "高品質語音檔（MeloTTS）與 iPhone 語音挑選修正"
  git push
  ```

- 之後候選方向（由使用者決定）：TOPIK 題型練習；開啟隱藏的 합니다體 與尊敬說法；App 內「回報問題」按鈕；單字擴充。

## 5. 重要檔案

| 檔案 | 用途 |
| --- | --- |
| `lib/data/unit_lessons.dart` | 字母課 4～6、單元 1～31（新單元插在 `/// 問名字（簡單版）` 之前，並在 `_unitClothes()` 後登記） |
| `lib/data/grammar/*.dart`、`all_grammar.dart` | 文法課；新文法課要在 `all_grammar.dart` 登記 |
| `lib/data/lessons.dart` | 課程清單、`_unitWordPools`、尚未建立清單 |
| `lib/data/course_options.dart` | `showWorkplace`／`showHonorific`（目前 false，隱藏） |
| `lib/audio/*` | 朗讀：裝置語音挑選、網頁版語音檔播放 |
| `test/content_test.dart` | 單元數（31）、語氣標籤、測驗範圍等規則 |
| `tool/validate_content.py` | 教材自動偵測（`--checklist` 重產查核清單） |
| `tool/deploy_web.ps1` | 打包並上傳網頁版 |
| `tool/make_audio.py`、`tool/setup_tts.ps1` | 語音檔產生與安裝 |
| `docs/devlog.md` | 開發日誌（每批都要寫） |
| `docs/curriculum_plan.md`、`docs/content_sources.md`、`docs/deploy_iphone.md`、`docs/audio.md` | 課程規劃、來源、上線、語音檔 |

## 6. 固定指令（在 `C:\game\kor_learn`）

```
flutter analyze *> analyze_log.txt
flutter test *> test_log.txt
powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1
git add .
git commit -m "這次改了什麼"
git push
```

Claude 讀 log 時：先看時間戳記晚於這次寫入；log 是 UTF-16，要轉碼。

## 7. 累積注意事項（使用者交代過的，全部要遵守）

**角色與流程**
1. Claude 是產品經理＋開發＋代理：自行規劃、製作、除錯、建立錯誤偵測、反覆驗證，不需要提醒；使用者只出點子、把關、決定方向。
2. 每批修改：撰寫 → 自動偵測 → 獨立審查（子代理）→ 修正 → 第二輪複驗 → 寫回電腦 → 給指令 → 讀 log → 寫開發日誌 → 給 git 指令。
3. 沒讀過 log 不可說測試通過。
4. 每次改完檔案都給完整、可直接貼上的 analyze／test 指令，不要只說「請重跑」。
5. 不想為了看新畫面關掉網頁：改完請他在跑網頁的終端機按大寫 R（必要時 q 再重跑，熱重啟偶爾吃不到）；analyze／test 在第二個終端機跑。
6. 跑完 analyze／test，Claude 直接讀 log，回報結果與網頁網址 http://localhost:5000。
7. 每個新專案都要寫開發日誌，並 commit／push 到 GitHub 更新活躍度；信箱用 noreply，不用 Gmail；不補做假日期 commit；`--force` 只用來修剛推錯的。
8. 對話太長時主動給交接包；交接包要包含這份累積注意事項，並每次更新。

**內容規則**
9. 內容正確性第一；所有教材維持「待查核」，AI 審查不算查核；不確定就查或標待查核，不編造來源。
10. 單元與一般課程只用敬語（해요體）；每句標語氣；半語只放在「半語（額外學習）」。
11. 範圍以 TOPIK I～II、能和陌生人有禮貌地溝通為主；太難的先拿掉。職場版（합니다體）與尊敬長輩的進階說法目前隱藏、可用 `CourseOptions` 開回來。
12. 單元單字與測驗只用既有單字庫；單元測驗只考前面出現過的單字（錯誤選項也是）。
13. 一個文法點只放進一個單元；-(으)ㅂ시다 對陌生人不夠禮貌，不放進單元。
14. 說明文字裡的每段韓文後面都有小喇叭；測驗題目與選項也要能朗讀。
15. 繪本／故事書內容已全部移除（使用者覺得可怕），不要再加。
16. 不重製歌詞或有著作權的教材全文；可解釋單字文法、附官方連結。
17. 中文矩陣用語：橫＝「行」(row)、直＝「列」(column)。

**溝通**
18. 繁體中文、簡短、中立、不討好。
19. 使用者貼截圖或說「弄好了」，Claude 自己去讀 log 或檔案確認。
