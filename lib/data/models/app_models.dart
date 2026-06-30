import '../../theme/palette.dart';

/// 目标设置（移植自源原型 `goals`）。中性表达，不含"失败/破戒"概念。
class Goals {
  const Goals({
    this.enabled = true,
    this.weekMax = 5,
    this.monthMax = 20,
    this.gapEnabled = true,
    this.minGap = 6,
    this.avoidEnabled = false,
  });

  final bool enabled;
  final int weekMax;
  final int monthMax;
  final bool gapEnabled;
  final int minGap; // 小时
  final bool avoidEnabled;

  Goals copyWith({
    bool? enabled,
    int? weekMax,
    int? monthMax,
    bool? gapEnabled,
    int? minGap,
    bool? avoidEnabled,
  }) =>
      Goals(
        enabled: enabled ?? this.enabled,
        weekMax: weekMax ?? this.weekMax,
        monthMax: monthMax ?? this.monthMax,
        gapEnabled: gapEnabled ?? this.gapEnabled,
        minGap: minGap ?? this.minGap,
        avoidEnabled: avoidEnabled ?? this.avoidEnabled,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'weekMax': weekMax,
        'monthMax': monthMax,
        'gapEnabled': gapEnabled,
        'minGap': minGap,
        'avoidEnabled': avoidEnabled,
      };

  factory Goals.fromJson(Map<String, dynamic> j) => Goals(
        enabled: j['enabled'] as bool? ?? true,
        weekMax: (j['weekMax'] as num?)?.toInt() ?? 5,
        monthMax: (j['monthMax'] as num?)?.toInt() ?? 20,
        gapEnabled: j['gapEnabled'] as bool? ?? true,
        minGap: (j['minGap'] as num?)?.toInt() ?? 6,
        avoidEnabled: j['avoidEnabled'] as bool? ?? false,
      );
}

/// 应用设置（外观、主色调、隐私开关、周起始日）。移植自源原型 `settings` +
/// `theme` / `accent` / `weekStartMonday`。
class AppSettings {
  const AppSettings({
    this.theme = ThemeKey.light,
    this.accent = AccentKey.green,
    this.appLock = false,
    this.biometric = false,
    this.disguise = false,
    this.blurNotif = true,
    this.weekStartMonday = true,
  });

  final ThemeKey theme;
  final AccentKey accent;
  final bool appLock;
  final bool biometric;
  final bool disguise;
  final bool blurNotif;
  final bool weekStartMonday;

  AppSettings copyWith({
    ThemeKey? theme,
    AccentKey? accent,
    bool? appLock,
    bool? biometric,
    bool? disguise,
    bool? blurNotif,
    bool? weekStartMonday,
  }) =>
      AppSettings(
        theme: theme ?? this.theme,
        accent: accent ?? this.accent,
        appLock: appLock ?? this.appLock,
        biometric: biometric ?? this.biometric,
        disguise: disguise ?? this.disguise,
        blurNotif: blurNotif ?? this.blurNotif,
        weekStartMonday: weekStartMonday ?? this.weekStartMonday,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'accent': accent.name,
        'appLock': appLock,
        'biometric': biometric,
        'disguise': disguise,
        'blurNotif': blurNotif,
        'weekStartMonday': weekStartMonday,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        theme: (j['theme'] as String?) == 'dark' ? ThemeKey.dark : ThemeKey.light,
        accent: AccentKeyLabel.fromId(j['accent'] as String?),
        appLock: j['appLock'] as bool? ?? true,
        biometric: j['biometric'] as bool? ?? true,
        disguise: j['disguise'] as bool? ?? false,
        blurNotif: j['blurNotif'] as bool? ?? true,
        weekStartMonday: j['weekStartMonday'] as bool? ?? true,
      );
}

/// 默认标签（源原型 `tags`）。
const List<String> kDefaultTags = [
  '睡前',
  '压力大',
  '无聊',
  '放松',
  '冲动',
  '助眠',
  '熬夜',
];
