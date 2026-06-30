import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/palette.dart';
import '../../../util/stats.dart';

/// 次数趋势折线（对应源原型的 SVG polyline + 填充 area，viewBox 300×90）。
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.palette,
    required this.trend,
    required this.maxTrend,
  });

  final AppPalette palette;
  final List<int> trend;
  final int maxTrend;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(trend, maxTrend, palette.accent, palette.accentSoft),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.trend, this.maxTrend, this.accent, this.soft);
  final List<int> trend;
  final int maxTrend;
  final Color accent;
  final Color soft;

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;
    final n = trend.length;
    double toPx(double yViewbox) => yViewbox / 90 * size.height;
    double yv(int v) => 83 - (v / maxTrend) * 80; // 源原型：H-(v/max)*(H-6)-3，H=86
    double xPx(int i) => n == 1 ? size.width / 2 : i / (n - 1) * size.width;

    final pts = [
      for (var i = 0; i < n; i++) Offset(xPx(i), toPx(yv(trend[i]))),
    ];

    final area = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(size.width, toPx(86))
      ..lineTo(0, toPx(86))
      ..close();
    canvas.drawPath(area, Paint()..color = soft..style = PaintingStyle.fill);

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.trend != trend || old.maxTrend != maxTrend || old.accent != accent;
}

/// 一组柱状图（星期分布 / 时间段分布共用），高度区 90，柱最高 72。
class StatBars extends StatelessWidget {
  const StatBars({
    super.key,
    required this.palette,
    required this.bars,
    required this.barColor,
    this.barMaxWidth = 22,
    this.barOpacity = 1.0,
  });

  final AppPalette palette;
  final List<StatBar> bars;
  final Color barColor;
  final double barMaxWidth;
  final double barOpacity;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    // 列高 = 数字 + 间距 + 柱(≤72) + 间距 + 标签；不写死容器高度，按内容自适应，避免溢出。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < bars.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${bars[i].count}',
                    style: AppText.body(size: 10, color: p.ink3)),
                const SizedBox(height: 7),
                Container(
                  width: barMaxWidth,
                  height: (bars[i].frac * 72).clamp(3, 72),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: barOpacity),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 7),
                Text(bars[i].label, style: AppText.body(size: 10, color: p.ink3)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
