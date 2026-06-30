import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// 抽象 logo：3×3 彩色方块网格，配色取自当前主色调的热力图色阶。
/// 对应源原型里 home / about / lock 三处复用的同一图形（仅尺寸不同）。
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.palette,
    this.cell = 5,
    this.gap = 2.5,
    this.padding = 5,
    this.radius = 8,
    this.cellRadius = 1.5,
    this.showFrame = true,
  });

  final AppPalette palette;
  final double cell;
  final double gap;
  final double padding;
  final double radius;
  final double cellRadius;

  /// 是否显示外层圆角边框（App 图标场景设为 false——只要网格，外圆角交给系统）。
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    final h = palette.heat;
    // 源原型映射：--he=heat[0] --hl=heat[1] --hm=heat[2] --hd=heat[3]
    final he = h[0], hl = h[1], hm = h[2], hd = h[3];
    final pattern = <Color>[
      hl, hd, he, //
      hd, hm, hl, //
      he, hl, hm, //
    ];
    Widget square(Color c) => Container(
          width: cell,
          height: cell,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(cellRadius),
          ),
        );
    final rows = <Widget>[];
    for (var r = 0; r < 3; r++) {
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var c = 0; c < 3; c++) ...[
            if (c > 0) SizedBox(width: gap),
            square(pattern[r * 3 + c]),
          ],
        ],
      ));
      if (r < 2) rows.add(SizedBox(height: gap));
    }
    final grid = Column(mainAxisSize: MainAxisSize.min, children: rows);
    if (!showFrame) return grid;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: grid,
    );
  }
}
