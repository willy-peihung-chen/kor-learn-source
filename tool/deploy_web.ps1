# 打包網頁版並上傳到 GitHub Pages（倉庫 willy-peihung-chen/kor-learn）。
# 用法（在 C:\game\kor_learn 執行）：
#   powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1
#
# 做法：build\web 每次都重新建一個暫時的 git 倉庫，整包強制推到 kor-learn 的 main。
# kor-learn 只放打包結果，不需要保留歷史；原始碼的歷史在 kor-learn-source。

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host '1/3 打包網頁版…'
flutter build web --release --base-href /kor-learn/
if ($LASTEXITCODE -ne 0) { Write-Host '打包失敗，停止。'; exit 1 }

$out = Join-Path $root 'build\web'
if (-not (Test-Path (Join-Path $out 'assets\fonts\MaterialIcons-Regular.otf'))) {
  Write-Host '找不到圖示字型檔，打包結果不完整，停止。'; exit 1
}

Write-Host '2/3 準備上傳…'
Push-Location $out
try {
  if (Test-Path '.git') { Remove-Item -Recurse -Force '.git' }
  git init -q
  git config user.name 'willy-peihung-chen'
  git config user.email '325269322+willy-peihung-chen@users.noreply.github.com'
  git add -A
  $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
  git commit -q -m "Deploy web build $stamp"
  git branch -M main
  git remote add origin https://github.com/willy-peihung-chen/kor-learn.git

  Write-Host '3/3 上傳到 GitHub…'
  git push -f origin main
  if ($LASTEXITCODE -ne 0) { Write-Host '上傳失敗。'; exit 1 }
} finally {
  Pop-Location
}

Write-Host '完成。到 https://github.com/willy-peihung-chen/kor-learn/actions 等綠色勾勾，'
Write-Host '再打開 https://willy-peihung-chen.github.io/kor-learn/ （iPhone 上把 App 完全關掉再開）。'
