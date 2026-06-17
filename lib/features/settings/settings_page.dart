import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';
import '../../widgets/ios_switch.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final s = c.settings;

    Widget chevron() => Text('›', style: AppText.body(size: 16, color: p.ink3));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 108),
      children: [
        Text('设置', style: AppText.serif(size: 30, color: p.ink)),
        const SizedBox(height: 26),

        // 外观（评论1：加上主色调选择）
        SectionHeader('外观', palette: p),
        SegmentedTabs(
          palette: p,
          items: const [('light', '浅色'), ('dark', '深色')],
          activeKey: s.theme == ThemeKey.dark ? 'dark' : 'light',
          onTap: (k) => c.setTheme(k == 'dark' ? ThemeKey.dark : ThemeKey.light),
          fontSize: 14,
          verticalPadding: 11,
        ),
        const SizedBox(height: 24),

        // 主色调
        SectionHeader('主色调', palette: p),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
          child: Row(
            children: [
              for (final key in AccentKey.values) ...[
                _AccentSwatch(
                  palette: p,
                  color: p.accentOf(key),
                  selected: s.accent == key,
                  onTap: () => c.setAccent(key),
                ),
                if (key != AccentKey.values.last) const SizedBox(width: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 隐私与安全
        SectionHeader('隐私与安全', palette: p),
        GroupedCard(
          palette: p,
          children: [
            SettingsRow(
              palette: p,
              title: 'App 锁',
              subtitle: '打开后启动需要验证',
              trailing: AppSwitch(
                value: s.appLock,
                onTap: () => c.toggleSetting('appLock'),
                palette: p,
              ),
            ),
            SettingsRow(
              palette: p,
              title: '指纹 / Face ID 解锁',
              trailing: AppSwitch(
                value: s.biometric,
                onTap: () => c.toggleSetting('biometric'),
                palette: p,
              ),
            ),
            SettingsRow(
              palette: p,
              title: '伪装模式',
              subtitle: '显示为「习惯记录」',
              trailing: AppSwitch(
                value: s.disguise,
                onTap: () => c.toggleSetting('disguise'),
                palette: p,
              ),
            ),
            SettingsRow(
              palette: p,
              title: '模糊通知',
              subtitle: c.notifPreview,
              trailing: AppSwitch(
                value: s.blurNotif,
                onTap: () => c.toggleSetting('blurNotif'),
                palette: p,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 立即锁定
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.lockNow,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 17, color: p.ink),
                const SizedBox(width: 9),
                Text('立即锁定',
                    style: AppText.body(size: 15, weight: FontWeight.w600, color: p.ink)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 数据（评论3：导入按钮）
        SectionHeader('数据', palette: p),
        GroupedCard(
          palette: p,
          children: [
            SettingsRow(
              palette: p,
              title: '标签管理',
              trailing: chevron(),
              onTap: () => c.openOverlay('tags'),
            ),
            SettingsRow(palette: p, title: '导出 CSV', trailing: chevron(), onTap: c.exportCsv),
            SettingsRow(palette: p, title: '导出 JSON', trailing: chevron(), onTap: c.exportJson),
            SettingsRow(palette: p, title: '导入数据', trailing: chevron(), onTap: c.importData),
            SettingsRow(
              palette: p,
              title: '加密备份',
              subtitle: '本地优先 · 端到端加密',
              trailing: chevron(),
              onTap: c.backup,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 目标与关于
        SectionHeader('目标与关于', palette: p),
        GroupedCard(
          palette: p,
          children: [
            SettingsRow(
              palette: p,
              title: '目标设置',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.goalSummary, style: AppText.body(size: 13, color: p.ink3)),
                  const SizedBox(width: 4),
                  chevron(),
                ],
              ),
              onTap: () => c.openOverlay('goals'),
            ),
            SettingsRow(
              palette: p,
              title: '关于 ${c.appName}',
              trailing: chevron(),
              onTap: () => c.openOverlay('about'),
            ),
            SettingsRow(
              palette: p,
              title: '清空全部数据',
              titleColor: AppPalette.danger,
              center: true,
              onTap: () => _confirmClear(context, c),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('${c.appName} v1.0 · 数据仅保存在本机',
              style: AppText.body(size: 12, color: p.ink3)),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context, AppController c) {
    final p = c.palette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('清空全部数据？', style: AppText.serif(size: 18, color: p.ink)),
        content: Text('此操作不可撤销，所有记录将从本机删除。',
            style: AppText.body(size: 14, color: p.ink2, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: AppText.body(size: 15, color: p.ink2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              c.clearData();
            },
            child: Text('清空',
                style: AppText.body(size: 15, weight: FontWeight.w600, color: AppPalette.danger)),
          ),
        ],
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.palette,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final AppPalette palette;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? palette.ink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
