import 'package:flutter/material.dart';

/// 颜色工具：把源原型里的 `#rrggbb` 十六进制字符串转成 [Color]。
Color _hex(String h) {
  final v = int.parse(h.replaceFirst('#', ''), radix: 16);
  return Color(0xff000000 | v);
}

/// 主题键：浅色 / 深色。
enum ThemeKey { light, dark }

/// 主色调键：森绿 / 墨蓝 / 藕紫 / 琥珀。
enum AccentKey { green, blue, purple, amber }

extension AccentKeyLabel on AccentKey {
  String get label => switch (this) {
        AccentKey.green => '森绿',
        AccentKey.blue => '墨蓝',
        AccentKey.purple => '藕紫',
        AccentKey.amber => '琥珀',
      };

  String get storageId => name;

  static AccentKey fromId(String? id) =>
      AccentKey.values.firstWhere((e) => e.name == id, orElse: () => AccentKey.green);
}

/// 一套主题的基础色（不含主色调，由 [AccentColors] 覆盖）。
/// 移植自源原型 `THEMES`。
class _BaseTheme {
  const _BaseTheme({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.nav,
    required this.swoff,
    required this.brightness,
    required this.shadow,
  });

  final Color bg, surface, surface2, ink, ink2, ink3, line, nav, swoff;
  final Brightness brightness;
  final List<BoxShadow> shadow;
}

final _light = _BaseTheme(
  bg: _hex('#f1ece3'),
  surface: _hex('#ffffff'),
  surface2: _hex('#f7f3ec'),
  ink: _hex('#262019'),
  ink2: _hex('#6f665a'),
  ink3: _hex('#a89e8f'),
  line: _hex('#e6ded1'),
  nav: const Color(0xD9F1ECE3), // rgba(241,236,227,0.85)
  swoff: _hex('#d8d0c2'),
  brightness: Brightness.light,
  shadow: const [
    BoxShadow(color: Color(0x0D282116), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x59282116), offset: Offset(0, 10), blurRadius: 26, spreadRadius: -16),
  ],
);

final _dark = _BaseTheme(
  bg: _hex('#15110b'),
  surface: _hex('#1f1a13'),
  surface2: _hex('#272018'),
  ink: _hex('#f1e9db'),
  ink2: _hex('#b0a692'),
  ink3: _hex('#7a7160'),
  line: _hex('#322a1f'),
  nav: const Color(0xD115110B), // rgba(21,17,11,0.82)
  swoff: _hex('#3a3326'),
  brightness: Brightness.dark,
  shadow: const [
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0xB3000000), offset: Offset(0, 12), blurRadius: 30, spreadRadius: -16),
  ],
);

/// 一个主色调在某一主题下的取值。移植自源原型 `ACCENTS`。
class _AccentVariant {
  const _AccentVariant({
    required this.accent,
    required this.ink,
    required this.soft,
    required this.heat,
  });
  final Color accent, ink, soft;
  final List<Color> heat; // 5 级热力图色阶（少 → 多）
}

class _AccentDef {
  const _AccentDef({required this.light, required this.dark});
  final _AccentVariant light, dark;
}

List<Color> _heat(List<String> hs) => hs.map(_hex).toList(growable: false);

final Map<AccentKey, _AccentDef> _accents = {
  AccentKey.green: _AccentDef(
    light: _AccentVariant(
      accent: _hex('#2f7d57'),
      ink: _hex('#ffffff'),
      soft: const Color(0x1A2F7D57), // rgba(47,125,87,0.1)
      heat: _heat(['#e4ddcf', '#bfe3c4', '#7cc593', '#3f9a66', '#27613f']),
    ),
    dark: _AccentVariant(
      accent: _hex('#46b87f'),
      ink: _hex('#0e1b13'),
      soft: const Color(0x2446B87F), // rgba(70,184,127,0.14)
      heat: _heat(['#241f17', '#21492f', '#357f52', '#54b07d', '#82d3a1']),
    ),
  ),
  AccentKey.blue: _AccentDef(
    light: _AccentVariant(
      accent: _hex('#2f6bbd'),
      ink: _hex('#ffffff'),
      soft: const Color(0x1A2F6BBD),
      heat: _heat(['#e4ddcf', '#bcd2f0', '#7ba6e0', '#3f74c0', '#27508c']),
    ),
    dark: _AccentVariant(
      accent: _hex('#5b95e8'),
      ink: _hex('#0b1422'),
      soft: const Color(0x245B95E8),
      heat: _heat(['#241f17', '#23375a', '#36568c', '#5485c8', '#82aee0']),
    ),
  ),
  AccentKey.purple: _AccentDef(
    light: _AccentVariant(
      accent: _hex('#6b4fb0'),
      ink: _hex('#ffffff'),
      soft: const Color(0x1A6B4FB0),
      heat: _heat(['#e4ddcf', '#d0c4ec', '#a98bdb', '#7a5fc0', '#574290']),
    ),
    dark: _AccentVariant(
      accent: _hex('#a98bdb'),
      ink: _hex('#16102a'),
      soft: const Color(0x24A98BDB),
      heat: _heat(['#241f17', '#352a52', '#54447f', '#7d63b0', '#a98bdb']),
    ),
  ),
  AccentKey.amber: _AccentDef(
    light: _AccentVariant(
      accent: _hex('#b06a2a'),
      ink: _hex('#ffffff'),
      soft: const Color(0x1AB06A2A),
      heat: _heat(['#e4ddcf', '#f0d8b8', '#e0b07a', '#c08a3f', '#8c6327']),
    ),
    dark: _AccentVariant(
      accent: _hex('#d99a5a'),
      ink: _hex('#241606'),
      soft: const Color(0x24D99A5A),
      heat: _heat(['#241f17', '#523a21', '#84612f', '#b08a4f', '#d6b07a']),
    ),
  ),
};

/// 解析后的完整调色板：基础主题 + 选中主色调覆盖。
/// 对应源原型 `renderVals()` 里的 `T = {...baseT, accent, accentInk, accentSoft, heat}`。
class AppPalette {
  AppPalette._({
    required this.themeKey,
    required this.accentKey,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.nav,
    required this.swoff,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.heat,
    required this.brightness,
    required this.shadow,
  });

  final ThemeKey themeKey;
  final AccentKey accentKey;
  final Color bg, surface, surface2, ink, ink2, ink3, line, nav, swoff;
  final Color accent, accentInk, accentSoft;
  final List<Color> heat;
  final Brightness brightness;
  final List<BoxShadow> shadow;

  bool get isDark => themeKey == ThemeKey.dark;

  /// 删除/危险操作用的红色（源原型固定 #c0492f）。
  static const Color danger = Color(0xFFC0492F);

  static AppPalette resolve(ThemeKey theme, AccentKey accent) {
    final base = theme == ThemeKey.dark ? _dark : _light;
    final a = _accents[accent]!;
    final v = theme == ThemeKey.dark ? a.dark : a.light;
    return AppPalette._(
      themeKey: theme,
      accentKey: accent,
      bg: base.bg,
      surface: base.surface,
      surface2: base.surface2,
      ink: base.ink,
      ink2: base.ink2,
      ink3: base.ink3,
      line: base.line,
      nav: base.nav,
      swoff: base.swoff,
      accent: v.accent,
      accentInk: v.ink,
      accentSoft: v.soft,
      heat: v.heat,
      brightness: base.brightness,
      shadow: base.shadow,
    );
  }

  /// 任意主色调在当前主题下的 accent 色（用于设置页的色板圆点）。
  Color accentOf(AccentKey key) {
    final a = _accents[key]!;
    return (themeKey == ThemeKey.dark ? a.dark : a.light).accent;
  }
}
