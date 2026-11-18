/// 課程內容開關。
///
/// 目前的目標是「能有禮貌地跟陌生人溝通」，所以先隱藏職場版與進階尊敬說法；
/// 內容都還在程式裡，之後要加回時把對應的開關改成 true 即可。
class CourseOptions {
  CourseOptions._();

  /// 職場／正式版（합니다體）卡片，以及單元 1 的「-ㅂ니다／습니다」文法卡。
  static bool showWorkplace = false;

  /// 對長輩的進階尊敬說法：-(으)시- 文法卡、성함 四級問名字、
  /// 「-(이)세요?」問身分、「주시겠어요?」請求。
  static bool showHonorific = false;
}
