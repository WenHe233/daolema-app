import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';

/// 小号大写灰色分组标题（源原型里 letter-spacing 1.5 的 12px 标签）。
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.text, {
    super.key,
    required this.palette,
    this.margin = const EdgeInsets.fromLTRB(4, 0, 4, 10),
  });

  final String text;
  final AppPalette palette;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Text(
        text,
        style: AppText.body(
          size: 12,
          weight: FontWeight.w600,
          color: palette.ink3,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

/// iOS 原生分组列表卡片：surface 底 + 发丝边框 + 圆角，子项间自动加发丝分割线。
class GroupedCard extends StatelessWidget {
  const GroupedCard({
    super.key,
    required this.palette,
    required this.children,
  });

  final AppPalette palette;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(Container(height: 1, color: palette.line));
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}

/// 一行设置项：左标题(可带副标题) + 右侧 trailing（开关/箭头/值）。
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.palette,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.center = false,
  });

  final AppPalette palette;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    final Widget? subWidget = sub == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(sub, style: AppText.body(size: 12, color: palette.ink3)),
          );
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: AppText.body(size: 15, color: titleColor ?? palette.ink)),
        ?subWidget,
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: center
            ? Center(child: titleWidget)
            : Row(
                children: [
                  Expanded(child: titleWidget),
                  ?trailing,
                ],
              ),
      ),
    );
  }
}

/// 带边框的小药丸（标签展示用）。
class PillTag extends StatelessWidget {
  const PillTag(this.text, {super.key, required this.palette});

  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppText.body(size: 12, color: palette.ink2)),
    );
  }
}

/// iOS 风格分段切换（统计区间、外观浅/深复用）。
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.palette,
    required this.items,
    required this.activeKey,
    required this.onTap,
    this.fontSize = 13,
    this.verticalPadding = 10,
  });

  final AppPalette palette;
  final List<(String, String)> items; // (key, label)
  final String activeKey;
  final ValueChanged<String> onTap;
  final double fontSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(items[i].$1),
                child: Container(
                  decoration: BoxDecoration(
                    color: activeKey == items[i].$1 ? p.accent : Colors.transparent,
                    border: i < items.length - 1
                        ? Border(right: BorderSide(color: p.line))
                        : null,
                  ),
                  padding: EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Center(
                    child: Text(
                      items[i].$2,
                      style: AppText.body(
                        size: fontSize,
                        weight: FontWeight.w600,
                        color: activeKey == items[i].$1 ? p.accentInk : p.ink2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 圆形 +/− 步进按钮（记录次数、目标增减复用）。
class StepperButton extends StatelessWidget {
  const StepperButton({
    super.key,
    required this.palette,
    required this.icon,
    required this.onTap,
    this.size = 32,
    this.fontSize = 20,
  });

  final AppPalette palette;
  final String icon; // '+' / '−'
  final VoidCallback onTap;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: palette.line),
        ),
        child: Text(icon,
            style: AppText.body(size: fontSize, color: palette.ink2, height: 1)),
      ),
    );
  }
}
