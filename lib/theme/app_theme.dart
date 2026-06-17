import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

/// 字体工具。
///
/// 标题与数字用 Noto Serif SC（思源宋体，编排质感）——与原型一致，原型亦从
/// Google Fonts 加载该字体；正文用系统字体（iOS 的 SF / 苹方，Android 的 Roboto）。
class AppText {
  AppText._();

  /// 衬线字体（标题、数字）。
  static TextStyle serif({
    required double size,
    FontWeight weight = FontWeight.w600,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSerifSc(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// 正文（系统字体）。
  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

/// 由调色板构建 [ThemeData]，主要用于 Scaffold 背景、亮暗模式与系统组件
/// （Cupertino 选择器、文本选择手柄等）取色。具体 UI 仍由 [AppPalette] 显式驱动。
ThemeData buildTheme(AppPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: p.brightness,
  ).copyWith(
    surface: p.surface,
    primary: p.accent,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(cursorColor: p.accent),
  );
}
