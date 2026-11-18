import 'package:flutter/material.dart';

/// 韓文與繁體中文的備援字型。
/// Windows / macOS 會用系統字型；Web 在需要時由 Flutter 自動載入備援字型。
const List<String> kFontFallback = <String>[
  'Noto Sans KR',
  'Malgun Gothic',
  'Apple SD Gothic Neo',
  'Noto Sans TC',
  'Microsoft JhengHei',
  'PingFang TC',
];

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F4858),
    brightness: Brightness.light,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF6F6F3),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamilyFallback: kFontFallback),
    primaryTextTheme:
        base.primaryTextTheme.apply(fontFamilyFallback: kFontFallback),
  );
}

/// 顯示韓文字（以及混合文字）用的樣式。
TextStyle hangulStyle(double size, {Color? color, FontWeight? weight}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: 1.25,
    fontFamilyFallback: kFontFallback,
  );
}
