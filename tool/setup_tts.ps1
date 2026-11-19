# 安裝產生語音檔需要的 MeloTTS（只要做一次）。
# 用法（在 C:\game\kor_learn 執行）：
#   powershell -ExecutionPolicy Bypass -File tool\setup_tts.ps1
#
# 需要先安裝 Python 3.10（MeloTTS 用的 torch 1.x 不支援更新的 Python），見 docs\audio.md。
# 會在專案裡建立 .venv_tts 資料夾（已列在 .gitignore，不會上傳），下載量約 2～3 GB。

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

py -3.10 --version
if ($LASTEXITCODE -ne 0) {
  Write-Host '找不到 Python 3.10。請先照 docs\audio.md 安裝，再重新執行。'
  exit 1
}

if (-not (Test-Path '.venv_tts')) {
  Write-Host '1/4 建立獨立的 Python 環境 .venv_tts …'
  py -3.10 -m venv .venv_tts
  if ($LASTEXITCODE -ne 0) { Write-Host '建立環境失敗。'; exit 1 }
}
$python = Join-Path $root '.venv_tts\Scripts\python.exe'

Write-Host '2/4 更新 pip …'
& $python -m pip install --upgrade pip

Write-Host '3/4 安裝 MeloTTS 與 mp3 編碼器（需要一段時間）…'
& $python -m pip install 'git+https://github.com/myshell-ai/MeloTTS.git' lameenc 'setuptools<81'  # 新版 setuptools 拿掉了 pkg_resources，舊套件還需要它
if ($LASTEXITCODE -ne 0) { Write-Host '安裝失敗：把畫面最後幾十行貼給 Claude。'; exit 1 }

# Windows 上的韓文詞性分析器（給 MeloTTS 的韓文發音轉換用），另外放一個資料夾，避免和日文 MeCab 衝突。
& $python -m pip install --target .venv_tts\mecab_ko python-mecab-ko
if ($LASTEXITCODE -ne 0) { Write-Host '韓文詞性分析器安裝失敗（仍可產生語音，但少數發音規則可能不準）。' }

Write-Host '4/4 下載 MeloTTS 需要的字典 …'
& $python -m unidic download
if ($LASTEXITCODE -ne 0) { Write-Host '字典下載失敗：把畫面最後幾十行貼給 Claude。'; exit 1 }

Write-Host '安裝完成。先試聽：.venv_tts\Scripts\python tool\make_audio.py --sample'
