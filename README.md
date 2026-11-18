# 韓文自學 App（MVP v0.1）

給完全零基礎的繁體中文使用者的韓文自學工具，長期目標是準備 TOPIK I。
沒有帳號、廣告、排行榜或付費牆，學習紀錄只存在自己的裝置上。

- 線上版（iPhone 用 Safari 打開後「加入主畫面」）：https://willy-peihung-chen.github.io/kor-learn/
- 內容：韓文字母課、基礎文法課、31 個單元（用敬語跟陌生人溝通的生活情境）、約 1,090 個依主題整理的單字。
- 所有教材都是「待查核」：經過自動偵測與 AI 審查，但沒有經過母語者或官方查核（見 `docs/content_sources.md`、`docs/review_checklist.md`）。

## 第一次執行

在這個資料夾（`C:\game\kor_learn`）開終端機：

```powershell
# 1. 產生各平台的外殼（web / windows / android）。只需要做一次，不會覆蓋 lib/ 與 pubspec.yaml。
flutter create --project-name hangul_app --platforms=web,windows,android .

# 2. 安裝套件
flutter pub get

# 3. 檢查與測試
flutter analyze
flutter test
```

Windows 提醒：`shared_preferences` 屬於外掛套件，Windows 需要先開啟「開發人員模式」
（設定 → 系統 → 開發人員專用），否則 `flutter pub get` 會報符號連結錯誤。

## 執行

```powershell
flutter run -d chrome --web-port=5000   # 網頁版
flutter run -d windows                  # Windows 桌面版（需要 Visual Studio 的「使用 C++ 的桌面開發」）
flutter run                             # 接上的手機或模擬器
```

網頁版請固定連接埠（`--web-port=5000`）：瀏覽器的本機儲存是依網址（含連接埠）區分的，
連接埠每次不同，學習紀錄就會「消失」。

## 資料夾結構

```
lib/
  audio/     朗讀服務（介面 + flutter_tts 實作 + 語音挑選邏輯）
  data/      教材資料與查詢 — 不含 UI
    vocab/     單字，一個主題一個檔案（all_topics.dart 是總表）
    grammar/   文法課程，一堂課一個檔案（all_grammar.dart 是總表）
  logic/     間隔重複排程、出題與答題判定、進度統計 — 純邏輯，可單獨測試
  storage/   學習紀錄的資料模型與儲存（介面 + shared_preferences 實作）
  state/     AppState：把紀錄、排程與儲存接在一起
  ui/        頁面與元件
test/        排程、出題、統計、儲存、畫面的測試
tool/
  validate_content.py  教材自動錯誤偵測（python tool/validate_content.py）
docs/
  content_sources.md   教材來源、使用限制與查核狀態
  curriculum_plan.md   單元學習課程規劃
  review_checklist.md  逐句查核清單（給母語者或其他 AI 檢查）
  deploy_iphone.md     網頁版打包與放到 GitHub Pages、iPhone 加入主畫面
  devlog.md            開發日誌
  verification/        教材複查報告
```

## 目前有的功能

- 首頁「今日學習」：今日課程、新知識練習、舊知識複習、開始學習。
- 課程：韓文字母（用聽的學，含聽音辨字練習）、基礎文法（含「溝通常用說法」）、單元 1～31（自我介紹、點餐、問路、交通、住宿、看病、打電話、銀行、遺失物、描述人和東西、經驗、比較、道別等），每個單元融入文法卡，課後小測驗只考學過的單字。
- 單字：約 1,090 個單字、25 個主題（問候、數字、食物、交通、動詞、形容詞…）。
  「單字」頁籤把所有單字依主題放在一起：點進主題可瀏覽、點單字就聽發音；
  可以複習全部到期的單字，也可以只複習單一主題，評「不熟悉／普通／熟悉」，由排程決定下次出現時間。
  漢字詞會標出漢字（台灣常用字形）幫助聯想。
- 測驗與錯題本：字母、音節、單字（可選主題）、文法填空；答完顯示正確答案與解釋；錯題自動收進錯題本，可重練。
- 學習進度：目前不在畫面上顯示（「進度」頁籤已拿掉），學習紀錄仍會保存在本機，之後可以加回來。
- 朗讀：單字、例句旁的喇叭按鈕，用裝置內建的韓文語音念出來（機器合成，非真人錄音）。
  Windows 桌面版需要先安裝韓文語言包（設定 → 時間與語言 → 語言）；網頁版建議用 Edge（有較自然的 Natural 語音）。
- 教材說明頁：集中說明教材來源、查核方式與限制（學習畫面不再逐項標示「待查核」）。
- 本地保存：重新啟動後紀錄仍在。

## 還沒有的功能

- 真人錄音檔、TOPIK 題型練習；職場用的 합니다體 與對長輩的尊敬說法已做好但暫時隱藏（`lib/data/course_options.dart`）。
- 對照 TOPIK 官方詞彙表（目前的單字表是依主題自行整理，不等於 TOPIK I 範圍）。
- 手機與電腦之間的同步（資料層已與儲存分離，新增另一個 `ProgressRepository` 實作即可）。
- AI 自由回答評分。

## 教材品質

教材正確性優先。教材的來源、查核方式與限制，App 內集中在「教材說明」頁，詳細紀錄在 `docs/content_sources.md`。
單字與文法需要時由開發者手動要求整批網路複查（目前沒有自動排程），報告放在 `docs/verification/`；複查只出報告，修正教材前會先確認。
