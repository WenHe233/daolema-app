import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_info.dart';
import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common.dart';
import 'overlay_scaffold.dart';

class AboutOverlay extends StatelessWidget {
  const AboutOverlay({super.key});

  Future<void> _openProject() async {
    final uri = Uri.parse(kProjectUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
            Text(kAppVersion, style: AppText.body(size: 13, color: p.ink3)),
          ],
        ),
        const SizedBox(height: 32),
        GroupedCard(
          palette: p,
          children: [
            SettingsRow(
              palette: p,
              title: '项目地址',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('WenHe233/daolema-app',
                      style: AppText.body(size: 13, color: p.ink3)),
                  const SizedBox(width: 4),
                  Text('›', style: AppText.body(size: 16, color: p.ink3)),
                ],
              ),
              onTap: _openProject,
            ),
          ],
        ),
      ],
    );
  }
}
