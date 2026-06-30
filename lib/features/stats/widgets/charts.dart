import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/palette.dart';
import '../../../util/stats.dart';

/// 次数趋势折线：极简纵轴(0/峰值) + 擦选/悬停显示「日期·次数」气泡。
/// 选中状态由外部(StatsPage)管理，松手保留，点图表以外区域清除。
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.palette,
    required this.trend,
    required this.dates,
    required this.maxTrend,
    required this.selected,
    required this.onSelectedChanged,
  });

  final AppPalette palette;
  final List<int> trend;
  final List<DateTime> dates;
  final int maxTrend;
  final int? selected;
  final ValueChanged<int?> onSelectedChanged;

  static const double _gutter = 26; // 左侧纵轴标注宽度
  static const double _height = 104;

  int _indexForX(double localX, double width) {
    final n = trend.length;
    if (n <= 1) return 0;
    final plotW = width - _gutter;
    final rel = ((localX - _gutter) / plotW).clamp(0.0, 1.0);
    return (rel * (n - 1)).round();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void update(Offset local) => onSelectedChanged(_indexForX(local.dx, width));
        return MouseRegion(
          onHover: (e) => update(e.localPosition),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => update(d.localPosition),
            onHorizontalDragStart: (d) => update(d.localPosition),
            onHorizontalDragUpdate: (d) => update(d.localPosition),
            child: SizedBox(
              height: _height,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendPainter(palette, trend, dates, maxTrend, selected, _gutter),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.palette, this.trend, this.dates, this.maxTrend, this.selected, this.gutter);
  final AppPalette palette;
  final List<int> trend;
  final List<DateTime> dates;
  final int maxTrend;
  final int? selected;
  final double gutter;

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;
    final n = trend.length;
    final left = gutter;
    final right = size.width;
    double toPx(double yViewbox) => yViewbox / 90 * size.height;
    double yv(int v) => 83 - (v / maxTrend) * 80; // 源原型：H-(v/max)*(H-6)-3，H=86
    double xPx(int i) => n == 1 ? (left + right) / 2 : left + i / (n - 1) * (right - left);

    final yTop = toPx(yv(maxTrend));
    final yBot = toPx(yv(0));

    // 网格线（0 与峰值两条）
    final grid = Paint()
      ..color = palette.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, yTop), Offset(right, yTop), grid);
    canvas.drawLine(Offset(left, yBot), Offset(right, yBot), grid);

    // 纵轴标注（右对齐到 gutter）
    _axisLabel(canvas, '$maxTrend', gutter - 6, yTop);
    _axisLabel(canvas, '0', gutter - 6, yBot);

    final pts = [for (var i = 0; i < n; i++) Offset(xPx(i), toPx(yv(trend[i])))];

    // 填充区
    final area = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(right, toPx(86))
      ..lineTo(left, toPx(86))
      ..close();
    canvas.drawPath(area, Paint()..color = palette.accentSoft..style = PaintingStyle.fill);

    // 折线
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = palette.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // 选中标记
    final sel = selected;
    if (sel != null && sel >= 0 && sel < n) {
      final sx = xPx(sel);
      final sy = toPx(yv(trend[sel]));
      // 竖向引导线
      canvas.drawLine(
        Offset(sx, yTop),
        Offset(sx, yBot),
        Paint()
          ..color = palette.accent.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      // 数据点（实心 + 描边环）
      canvas.drawCircle(Offset(sx, sy), 4, Paint()..color = palette.accent);
      canvas.drawCircle(
        Offset(sx, sy),
        4,
        Paint()
          ..color = palette.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // 气泡
      final d = dates[sel];
      _bubble(canvas, size, sx, sy, '${d.month}月${d.day}日 · ${trend[sel]} 次');
    }
  }

  void _axisLabel(Canvas canvas, String text, double rightX, double centerY) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppText.body(size: 10, color: palette.ink3)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rightX - tp.width, centerY - tp.height / 2));
  }

  void _bubble(Canvas canvas, Size size, double sx, double sy, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppText.body(size: 11, weight: FontWeight.w600, color: palette.ink),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bw = tp.width + 16;
    final bh = tp.height + 10;
    var bx = sx - bw / 2;
    bx = bx.clamp(gutter, size.width - bw);
    var by = sy - 8 - bh;
    if (by < 0) by = sy + 8; // 顶部放不下则放到点下方
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx, by, bw, bh),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = palette.surface);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(bx + 8, by + 5));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.trend != trend ||
      old.maxTrend != maxTrend ||
      old.selected != selected ||
      old.palette.accent != palette.accent ||
      old.palette.surface != palette.surface;
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
