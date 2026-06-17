import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'features/calendar/calendar_page.dart';
import 'features/home/home_page.dart';
import 'features/lock/lock_screen.dart';
import 'features/overlays/about_overlay.dart';
import 'features/overlays/goals_overlay.dart';
import 'features/overlays/tags_overlay.dart';
import 'features/record/record_sheet.dart';
import 'features/settings/settings_page.dart';
import 'features/stats/stats_page.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/app_toast.dart';
import 'widgets/bottom_nav.dart';

class DaolemaApp extends StatelessWidget {
  const DaolemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppController>().palette;
    return MaterialApp(
      title: '导了吗',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette),
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootShell(),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static const _tabs = ['home', 'cal', 'stats', 'settings'];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final tabIndex = _tabs.indexOf(c.activeTab).clamp(0, _tabs.length - 1);

    return Material(
      color: p.bg,
      child: Stack(
        children: [
          // 四个主页面（保活，保留各自滚动位置）
          Positioned.fill(
            child: IndexedStack(
              index: tabIndex,
              children: const [
                HomePage(),
                CalendarPage(),
                StatsPage(),
                SettingsPage(),
              ],
            ),
          ),
          // 底部导航
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              palette: p,
              activeTab: c.activeTab,
              onTap: c.setTab,
            ),
          ),
          // 全屏覆盖层
          if (c.overlay == 'goals') const Positioned.fill(child: GoalsOverlay()),
          if (c.overlay == 'tags') const Positioned.fill(child: TagsOverlay()),
          if (c.overlay == 'about') const Positioned.fill(child: AboutOverlay()),
          // 记录弹窗
          if (c.sheetOpen) const Positioned.fill(child: RecordSheet()),
          // Toast
          if (c.toast != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 120 + MediaQuery.of(context).padding.bottom,
              child: Center(child: AppToast(c.toast!, palette: p)),
            ),
          // 隐私锁（最顶层）
          if (c.locked) const Positioned.fill(child: LockScreen()),
        ],
      ),
    );
  }
}
