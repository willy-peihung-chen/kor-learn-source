# 交接包：韓文自學 App（2026-11-21 16:00）

新對話開頭請貼：這份交接包＋「專案開發標準流程（給 Claude 的指示）」的精簡指示。

## 1. 專案基本資料

| 項目 | 內容 |
| --- | --- |
| 專案 | 韓文自學 Flutter App（MVP v0.1），給零基礎繁中使用者，目標 TOPIK I；用敬語和陌生人有禮貌地溝通 |
| 資料夾 | `C:\game\kor_learn`（使用者的 Windows 電腦；Claude 透過連結的電腦讀寫一般檔案，不能執行指令、不能寫 `.git`、不能刪檔，但可以讀 `.git` 紀錄） |
| 原始碼倉庫 | https://github.com/willy-peihung-chen/kor-learn-source （Public） |
| 上線倉庫 | https://github.com/willy-peihung-chen/kor-learn （只放打包結果，由 `tool/deploy_web.ps1` 整包強制推送） |
| 線上網址 | https://willy-peihung-chen.github.io/kor-learn/ （iPhone 用 Safari「加入主畫面」） |
| commit 信箱 | `325269322+willy-peihung-chen@users.noreply.github.com`（不用 Gmail） |
| 使用者手機 | iPhone（用網頁版） |

## 2. 目前狀態（11/21 16:00）

- 內容：字母課 6 堂、文法課、半語額外課、單元 1～31、單字 **1,586 筆（約 1,379 個不同的字）、42 個主題**、辭典、語音檔 7,067 個。
- 最後一次檢查：`flutter analyze` No issues found、`flutter test` **163 項全部通過**（11/21 15:52，晚於最後一次寫入 15:50）。自動偵測 0 錯誤 0 警告。
- 最後一個 commit：「單字第5批新增100個2級字；單字主題拆成42個…」（11/21 14:52），已推到 `main`。
  **「單字複習改進第 1 步」已通過 analyze／test，但使用者還沒回報是否 commit**（下次先讀 `.git/logs/HEAD` 確認）。
- 上線：11/21 15:2x 部署（含主題細分、等級分段、全部語音檔）；**Actions 綠色勾勾使用者尚未回報**。複習改進第 1 步**還沒部署**（打算 C、E 做完一起部署）。
- 內容仍全部「待查核」。

## 3. 11/21 完成的批次（細節見 `docs/devlog.md`）

1. 單元 6～10 的文法改寫成說明卡＋`grammarRefs`，重寫 11 個文法點說明；偵測工具 `GRAMMAR_IN_CONCEPT_UNITS = 10`。
2. 單字擴充第 1～5 批（1,089 → 1,586）：依國立國語院「한국어 학습용 어휘 목록」選字（`docs/sources/` 有原檔，CP949），意思與例句自寫、待查核。
3. 單字分類細分：五個大主題拆成 21 個小主題（共 42 個）；主題頁依詞表等級分「1 級／2 級／其他」；等級表 `lib/data/word_level_data.dart` 由 `tool/gen_word_levels.py` 自動產生，偵測工具會比對。單字頁依大類顯示（`lib/data/topic_groups.dart`）。
4. 語音檔補齊：1,498 段新語音（`make_audio.py --prune`），共 7,067 個、99.9 MB；已部署。
5. 單字複習改進第 1 步：
   - A：評「不熟悉」的卡排回本輪最後重做（`ReviewRound`），2 小時內剛答錯過的卡再答對最多 1 天、重複答錯不重複扣分。
   - B：按鈕下方自評標準。
   - 新字順序：全部複習時「問候與日常表達」（片語主題）先，其餘 1 級 → 2 級 → 其他；主題複習與主題頁順序相同。
   - 修主題複習結束時「下一張到期」只看本主題。
   - 規劃見 `docs/review_improvements.md`。

## 4. 下一步（使用者已決定）

**下一批：C＋E＋小問題全部一起做**（使用者 11/21 15:55 指示）。
- **C 每日上限**：新字每天 10 個（全 App 共用，兩個入口扣同一份額度）；到期卡每輪 20 張、不設每天上限；今天到期超過 100 張時暫停新字並說明；「今天再多學 10 個」按鈕。
  需要在 `ReviewState` 新增「第一次評的日期」（舊紀錄沒有這欄要能讀）；所有「到期／新字／今天剩幾個」數字從 `AppState` 同一處算；測試要涵蓋：主題扣同一份額度、額度用完只出到期卡、重做不重複計數、積壓暫停、跨午夜、讀舊紀錄。
- **E 難記的字**：答「不熟悉」累計 4 次以上（`lapses ≥ 4`）標「難記的字」，翻開時用法說明放前面，學習進度頁列出來。
- **小問題**：
  - 單元 9 的 스마트폰 副標題「智慧型手機」與單字庫不同步（`unit_lessons.dart` 約 3364 行附近）。
  - 隱藏卡片 `u1:polite_note` 有「比 해요體 更尊敬」的用詞要更新。
  - 只剩最後一張答錯時會立刻重複出現。
  - 首頁／近期活動「複習 n 張」把重做也算一次。
  - 使用者電腦上 5 個只剩註解的舊主題檔（`topic_verbs.dart`、`topic_adjectives.dart`、`topic_function.dart`、`topic_concepts.dart`、`topic_time.dart`）：可能已刪，Claude 不能刪檔，若還在請使用者刪。
- 之後：**D**（中文→韓文複習卡，正向間隔 ≥ 3 天才開啟、同一字兩個方向不同一天，需改紀錄格式）→ 部署＋iPhone 實測 → **單字補到 2,000**（約 414 個、4 批，第 6 批只選了候選字沒改檔）→ 每批加完字要重跑 `make_audio.py`。
- 仍待確認：測驗兩行選項的手機版面、iPhone 主畫面圖示、Actions 綠色勾勾。

## 5. 重要檔案

| 檔案 | 用途 |
| --- | --- |
| `lib/data/vocab/topic_*.dart`、`all_topics.dart` | 單字主題（42 個）；新主題要在 `all_topics.dart` 登記；測試依賴 `Catalog.topics` 前 3 個（greetings、numbers、time_day） |
| `lib/data/word_levels.dart`、`word_level_data.dart`、`tool/gen_word_levels.py` | 等級、片語主題（`phraseTopicIds`）、學習順序；改字後重跑 `python tool/gen_word_levels.py` |
| `lib/data/topic_groups.dart` | 單字頁大類（依主題 id 前綴） |
| `lib/logic/srs.dart` | 排程 `Srs`、`ReviewQueue`、`ReviewRound` |
| `lib/state/app_state.dart` | 唯一狀態來源（複習清單、到期數、學習順序） |
| `lib/ui/review_page.dart`、`lib/ui/vocab_page.dart` | 複習畫面、單字頁 |
| `lib/data/unit_lessons.dart`、`lib/data/grammar/*.dart` | 單元與文法課 |
| `lib/logic/quiz_generator.dart` | 出題；近義字要共用意思詞（`test/quiz_generator_test.dart` 近義字組 103 組） |
| `tool/validate_content.py`、`tool/validate_selftest.py` | 自動偵測與自我測試 |
| `tool/make_audio.py`、`tool/deploy_web.ps1` | 語音檔、部署 |
| `docs/devlog.md`、`docs/review_improvements.md`、`docs/content_sources.md` | 開發日誌、複習改進規劃、來源與查核狀態 |

## 6. 固定指令（在 `C:\game\kor_learn`）

```
python tool\validate_content.py *> validate_log.txt
flutter analyze *> analyze_log.txt
flutter test *> test_log.txt
.venv_tts\Scripts\python tool\make_audio.py --prune *>&1 | Tee-Object -FilePath audio_log.txt
powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1 *>&1 | Tee-Object -FilePath deploy_log.txt
git add .
git commit -m "這次改了什麼"
git push
```

Claude 讀 log：先確認時間戳記晚於這次寫入；log 是 UTF-16 要轉碼。產生語音時進度可看 `web\audio\index.json` 的筆數（每 25 段更新）。部署的紅字（Wasm dry run、LF/CRLF、字型 tree-shaking）是已知提醒。

## 7. 累積注意事項（使用者交代過的，全部要遵守）

**角色與流程**
1. Claude 是產品經理＋開發＋代理：自行規劃、製作、除錯、建立錯誤偵測、反覆驗證，不需要提醒；使用者只出點子、把關、決定方向。
2. 每批修改：撰寫 → 自動偵測 → 獨立審查（子代理，一律要做）→ 修正 → 第二輪複驗 → 寫回電腦（寫完核對檔案大小）→ 給指令 → 讀 log → 寫開發日誌 → 給 git 指令。
3. 沒讀過 log 不可說測試通過；讀之前先確認時間戳記晚於這次寫入。
4. 每次改完檔案都給完整、可直接貼上的 analyze／test 指令。
5. 不想為了看新畫面關掉網頁：改完請他在跑網頁的終端機按大寫 R；analyze／test 在第二個終端機跑。
6. 跑完 analyze／test，Claude 直接讀 log 回報結果。
7. 寫開發日誌並 commit／push；信箱用 noreply；不補做假日期 commit；`--force` 只用來修剛推錯的。
8. 對話太長時主動給交接包，包含這份累積注意事項並每次更新。

**內容規則**
9. 內容正確性第一；所有教材維持「待查核」，AI 審查不算查核；不確定就查或標待查核，不編造來源。
10. 單元與一般課程只用敬語（해요體）；每句標語氣；半語只放在「半語（額外學習）」。
11. 範圍以 TOPIK I～II、能和陌生人有禮貌地溝通為主；職場版（합니다體）與尊敬長輩的進階說法目前隱藏（`CourseOptions`）。
12. 單元單字與測驗只用既有單字庫；單元測驗只考前面出現過的單字（錯誤選項也是）。
13. 一個文法點只放進一個單元；-(으)ㅂ시다 不放進單元。
14. 說明文字裡的每段韓文後面都有小喇叭；「單字→中文」題的選項是中文，不放喇叭。
15. 繪本／故事書內容已全部移除，不要再加。
16. 不重製歌詞或有著作權的教材全文。
17. 中文矩陣用語：橫＝「行」(row)、直＝「列」(column)。

**溝通**
18. 繁體中文、簡短、中立、不討好。
19. 使用者貼截圖或說「弄好了」，Claude 自己去讀 log 或檔案確認。

**11/20 追加**
20. 每一次改動都要自動找沒看過撰寫過程的子代理做獨立審查，不用使用者提醒；只有純錯字可以不審。回覆要寫審查的「必改／建議」如何處理。
21. 文法說明改寫：單元只教該單元例句實際用到的文法，寫在說明卡（`grammarRefs` 連到文法課）；多用中文講清楚；一次先做一小批。
22. 例行工作可用 Sonnet；改寫文法、檢查韓文正確性、設計判斷建議用 Opus。換模型不會丟進度。
23. 使用者看到畫面不對時，先確認他看的是線上舊版還是本機新版。

**11/21 追加**
24. 單字擴充：每批約 100 個，依國立國語院「한국어 학습용 어휘 목록」選字（只用來決定收哪些字），偏書面／學術的字不收；中文意思、例句自寫並標待查核；每批要做近義字掃描（意思不同但近義的字要共用一個意思詞，並加進 `quiz_generator_test` 近義字組）、單元測驗干擾選項模擬、三輪審查。
25. 漢字欄採台灣常用寫法（例：預約、預定、化妝品、祕密），只寫純漢字詞部分。
26. 單字的「常用程度」一律用國語院詞表等級（1 級＝A、2 級＝B，3 級與詞表沒有的字合併成「其他」），等級表自動產生不手改。
27. 加完字要重跑 `make_audio.py`，新字才有語音；跑音檔時可以同時在另一個視窗 commit（`web/audio/`、`tool/audio_texts.tsv`、`*_log.txt` 都不進 git）。
28. 使用者偏好的複習設計：主題只是篩選、只有一副牌、額度全 App 共用；C 的數字照 Claude 預設（10／20／100／4），之後可調。
29. 使用者說「先停」時，立即停下目前批次、不改檔案，先做他指定的事。
