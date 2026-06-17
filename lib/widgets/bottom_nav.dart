import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../util/svg_icons.dart';

/// 底部导航：首页 / 日历 / 统计 / 设置（毛玻璃背景 + 顶部发丝线）。
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.palette,
    required this.activeTab,
    required this.onTap,
  });

  final AppPalette palette;
  final String activeTab;
  final ValueChanged<String> onTap;

  static const _items = [
    ('home', '首页'),
    ('cal', '日历'),
    ('stats', '统计'),
    ('settings', '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(top: 9, bottom: bottomInset),
          decoration: BoxDecoration(
            color: palette.nav,
            border: Border(top: BorderSide(color: palette.line)),
          ),
          child: Row(
            children: [
              for (final (key, label) in _items)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(key),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          strokeIcon(
                            kNavIconPaths[key]!,
                            activeTab == key ? palette.accent : palette.ink3,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            label,
                            style: AppText.body(
                              size: 10,
                              weight: FontWeight.w500,
                              color: activeTab == key ? palette.accent : palette.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
