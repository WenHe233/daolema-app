import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 把 [Color] 转成 `#rrggbb`（不依赖已废弃的 Color.value）。
String colorToHex(Color c) {
  int ch(double v) => (v * 255.0).round().clamp(0, 255);
  String h(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${h(ch(c.r))}${h(ch(c.g))}${h(ch(c.b))}';
}

/// 底部导航图标的内部 path（直接沿用源原型 `NAV_ICONS`）。
const Map<String, String> kNavIconPaths = {
  'home': '<path d="M3 11l9-8 9 8"/><path d="M5 10v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V10"/>',
  'cal': '<rect x="3" y="4" width="18" height="17" rx="2"/><path d="M3 9h18M8 2v4M16 2v4"/>',
  'stats': '<line x1="6" y1="20" x2="6" y2="13"/><line x1="12" y1="20" x2="12" y2="7"/><line x1="18" y1="20" x2="18" y2="10"/>',
  'settings': '<line x1="4" y1="8" x2="20" y2="8"/><circle cx="9" cy="8" r="2.4"/><line x1="4" y1="16" x2="20" y2="16"/><circle cx="15" cy="16" r="2.4"/>',
};

/// 描边矢量图标（fill=none，stroke=指定色），宽高与 viewBox 同源原型。
Widget strokeIcon(
  String inner,
  Color color, {
  double size = 24,
  double strokeWidth = 2,
}) {
  final svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
      'viewBox="0 0 24 24" fill="none" stroke="${colorToHex(color)}" '
      'stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">'
      '$inner</svg>';
  return SvgPicture.string(svg, width: size, height: size);
}
