import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import 'overlay_scaffold.dart';

class AboutOverlay extends StatelessWidget {
  const AboutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;

    return OverlayScaffold(
      palette: p,
      title: '关于',
      onBack: c.closeOverlay,
      children: [
        const SizedBox(height: 6),
        Column(
          children: [
            AppLogo(
              palette: p,
              cell: 12,
              gap: 5,
              padding: 16,
              radius: 20,
              cellRadius: 3,
            ),
            const SizedBox(height: 18),
            Text(c.appName, style: AppText.serif(size: 24, color: p.ink)),
            const SizedBox(height: 4),
            Text('版本 1.0.0', style: AppText.body(size: 13, color: p.ink3)),
          ],
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '一个安静、克制的个人状态记录工具。它只是帮你看见自己的节奏与习惯，不评判、不说教。\n\n'
            '所有数据本地优先存储，支持 App 锁、伪装模式与加密备份。你的记录，只属于你自己。',
            style: AppText.body(size: 15, color: p.ink2, height: 1.9),
          ),
        ),
      ],
    );
  }
}
