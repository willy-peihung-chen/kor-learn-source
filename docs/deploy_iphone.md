# 在 iPhone 上使用（網頁版）

iPhone 的原生 App 必須用 Mac 打包，所以這個專案用「網頁版＋加入主畫面」：
網頁放到 GitHub Pages（免費），iPhone 用 Safari 打開後加入主畫面，就會有「韓文學習」的圖示，點開是全螢幕。

## 第一次設定

1. 在電腦打包網頁版（在 `C:\game\kor_learn` 執行）：

   ```
   flutter build web --release --base-href /kor-learn/ *> build_web_log.txt
   ```

   `/kor-learn/` 要和下一步的 GitHub 倉庫名稱一樣（前後都要有斜線）。打包好的檔案在 `build\web`。

2. 到 GitHub 建一個新的 **Public** 倉庫，名稱 `kor-learn`。
3. 在倉庫頁面按 **Add file → Upload files**，把 `build\web` **裡面的所有檔案和資料夾**拖進去（不是拖 `web` 資料夾本身），再按 **Commit changes**。
4. 倉庫的 **Settings → Pages**：Source 選 **Deploy from a branch**，Branch 選 `main`、資料夾選 `/ (root)`，按 Save。
5. 等一兩分鐘，網址會是 `https://你的帳號.github.io/kor-learn/`。

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

1. 重新執行第一步的打包指令。
2. 到 GitHub 倉庫按 **Add file → Upload files**，再把 `build\web` 裡的全部檔案拖進去、Commit（同名檔案會被覆蓋）。
3. iPhone 上把 App 完全關掉（從多工畫面往上滑掉）再打開。如果還是舊版，等幾分鐘再試。
