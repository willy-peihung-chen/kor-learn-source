# 在 iPhone 上使用（網頁版）

iPhone 的原生 App 必須用 Mac 打包，所以這個專案用「網頁版＋加入主畫面」：
網頁放到 GitHub Pages（免費），iPhone 用 Safari 打開後加入主畫面，就會有「韓文學習」的圖示，點開是全螢幕。

## 上傳網頁版（每次更新都一樣）

在 `C:\game\kor_learn` 執行：

```
powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1
```

腳本會：打包網頁版（`--base-href /kor-learn/`）→ 確認圖示字型等檔案都在 → 用 git 把 `build\web` 整包推到 GitHub 倉庫 `willy-peihung-chen/kor-learn`。
第一次執行會跳出瀏覽器要你登入 GitHub。

不要再用網頁「Upload files」拖曳上傳：拖曳時子資料夾（`assets`、`canvaskit`、`icons`）可能沒有上傳，App 會缺圖示字型，圖示全部變成方框（11/18 發生過）。

倉庫的 **Settings → Pages** 只要設定一次：Deploy from a branch、`main`、`/ (root)`。
推送後到倉庫的 **Actions** 等「pages build and deployment」出現綠色勾勾（約一兩分鐘），網址是 https://willy-peihung-chen.github.io/kor-learn/ 。

## iPhone

1. 用 **Safari** 打開上面的網址（其他瀏覽器不能加入主畫面成 App 的樣子）。
2. 按下方的「分享」按鈕 →「加入主畫面」→「加入」。
3. 之後從主畫面的「韓文學習」圖示打開。

## 注意

- **學習紀錄存在 iPhone 上**，不會上傳。從主畫面圖示打開的 App 和 Safari 分頁裡的網頁，紀錄是分開的，請固定用同一個入口。刪掉主畫面圖示或清除 Safari 網站資料，紀錄會不見。
- **朗讀**用的是 iPhone 內建的韓文語音。沒有聲音時：檢查音量與靜音開關；到「設定 → 輔助使用 → 朗讀內容 → 聲音 → 韓文」確認有韓文語音（可以下載品質較好的語音）。
- 第一次打開需要網路（下載程式和字型）；之後大多可以使用，但建議有網路時使用。
- 倉庫是公開的：只有教材和程式，沒有你的學習紀錄。

## 之後更新內容

1. 執行上面的 `deploy_web.ps1`。
2. 等 Actions 綠色勾勾。
3. iPhone 上把 App 完全關掉（從多工畫面往上滑掉）再打開。如果還是舊版，等幾分鐘再試。
