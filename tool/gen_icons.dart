// 一次性图标生成器：把 AppLogo 的 3×3 网格（无边框）渲染成方形 PNG，
// 供 flutter_launcher_icons 使用。外层圆角交给系统，源图不烘焙圆角框。
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
  // 只要网格，无外层边框/圆角；靠 FittedBox 放大到目标尺寸。
  final grid = AppLogo(
    palette: palette,
    cell: 12,
    gap: 5,
    cellRadius: 3,
    showFrame: false,
  );

  testWidgets('生成 app 图标 PNG（方形、无边框）', (tester) async {
    // 关键：把测试画布设为 1024×1024 正方形，否则默认 800×600 会把图标压成长方形。
    await tester.binding.setSurfaceSize(const Size(_canvas, _canvas));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // 主图标：纸张底满铺 + 居中网格(约 62%)
    await _capture(
      tester,
      Container(
        color: _bg,
        alignment: Alignment.center,
        child: SizedBox(width: 640, height: 640, child: FittedBox(child: grid)),
      ),
      'assets/icon/app_icon.png',
    );

    // Android 自适应前景：透明底 + 居中网格(约 58%，留安全边)
    await _capture(
      tester,
      Center(
        child: SizedBox(width: 600, height: 600, child: FittedBox(child: grid)),
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
