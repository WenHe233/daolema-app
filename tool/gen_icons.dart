// 一次性图标生成器：把现有 AppLogo 渲染成 PNG，供 flutter_launcher_icons 使用。
// 运行：flutter test tool/gen_icons.dart
// （放在 tool/ 而非 test/，避免被 CI 的 `flutter test` 误跑）
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daolema/theme/palette.dart';
import 'package:daolema/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _bg = Color(0xFFF1ECE3); // 浅色暖纸张底
const _canvas = 1024.0;

void main() {
  final palette = AppPalette.resolve(ThemeKey.light, AccentKey.green);
  // 复用关于页同款 logo 比例，靠 FittedBox 放大到目标尺寸。
  final logo = AppLogo(
    palette: palette,
    cell: 12,
    gap: 5,
    padding: 16,
    radius: 20,
    cellRadius: 3,
  );

  testWidgets('生成 app 图标 PNG', (tester) async {
    // 主图标：不透明纸张底 + logo 约占 78%
    await _capture(
      tester,
      Container(
        width: _canvas,
        height: _canvas,
        color: _bg,
        alignment: Alignment.center,
        child: SizedBox(width: 800, height: 800, child: FittedBox(child: logo)),
      ),
      'assets/icon/app_icon.png',
    );

    // Android 自适应前景：透明底 + logo 约占 58%（留安全边）
    await _capture(
      tester,
      SizedBox(
        width: _canvas,
        height: _canvas,
        child: Center(
          child: SizedBox(width: 600, height: 600, child: FittedBox(child: logo)),
        ),
      ),
      'assets/icon/app_icon_foreground.png',
    );
  });
}

Future<void> _capture(WidgetTester tester, Widget child, String path) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
