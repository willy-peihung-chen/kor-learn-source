// 依平台選擇朗讀服務的實作：
// - 網頁版：直接呼叫瀏覽器的語音功能（speechSynthesis）。
// - 其他平台（Windows、Android 等）：使用 flutter_tts。
export 'platform_speech_native.dart'
    if (dart.library.js_interop) 'platform_speech_web.dart';
