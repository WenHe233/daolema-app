import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';
import '../home/home_page.dart' show ProgressBar;
import 'widgets/charts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _ranges = [
    ('7', '7 天'),
    ('30', '30 天'),
    ('90', '90 天'),
    ('year', '今年'),
  ];

  int? _trendSel; // 趋势图选中点（点图表以外区域清除）

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final counts = c.counts;
    final stats = c.statsData;
    final iv = c.intervals;

    // 选中索引可能因区间切换而越界，渲染时夹取。
    final sel = (_trendSel != null && _trendSel! < stats.trend.length) ? _trendSel : null;

    final overview = [
      ('今日', '${counts.today}'),
      ('本周', '${counts.week}'),
      ('本月', '${counts.month}'),
      ('今年', '${counts.year}'),
      ('总计', '${counts.total}'),
      ('日均', stats.avgDaily),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_trendSel != null) setState(() => _trendSel = null);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 108),
        children: [
          Text('统计', style: AppText.serif(size: 30, color: p.ink)),
        const SizedBox(height: 20),
        // 区间切换
        SegmentedTabs(
          palette: p,
          items: _ranges,
          activeKey: c.range,
          onTap: c.setRange,
        ),
        const SizedBox(height: 30),
        // 总览网格
        _OverviewGrid(palette: p, items: overview),
        const SizedBox(height: 30),
        _StatHeader('次数趋势', p),
        const SizedBox(height: 16),
        TrendChart(
          palette: p,
          trend: stats.trend,
          dates: stats.trendDates,
          maxTrend: stats.maxTrend,
          selected: sel,
          onSelectedChanged: (i) => setState(() => _trendSel = i),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 26), // 与纵轴 gutter 对齐
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stats.trendStart, style: AppText.body(size: 11, color: p.ink3)),
              Text(stats.trendEnd, style: AppText.body(size: 11, color: p.ink3)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _StatHeader('星期分布', p),
        const SizedBox(height: 18),
        StatBars(palette: p, bars: stats.weekdayBars, barColor: p.accent),
        const SizedBox(height: 30),
        _StatHeader('时间段分布', p),
        const SizedBox(height: 18),
        StatBars(
          palette: p,
          bars: stats.todBars,
          barColor: p.accent,
          barMaxWidth: 26,
        ),
        const SizedBox(height: 30),
        _StatHeader('标签排行', p),
        const SizedBox(height: 16),
        if (stats.tagRank.isEmpty)
          Text('暂无标签数据', style: AppText.body(size: 13, color: p.ink3))
        else
          Column(
            children: [
              for (var i = 0; i < stats.tagRank.length; i++) ...[
                if (i > 0) const SizedBox(height: 13),
                Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(stats.tagRank[i].name,
                          style: AppText.body(size: 13, color: p.ink)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: ProgressBar(palette: p, pct: stats.tagRank[i].pct)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 24,
                      child: Text('${stats.tagRank[i].count}',
                          textAlign: TextAlign.right,
                          style: AppText.body(size: 13, color: p.ink3)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        const SizedBox(height: 30),
        _StatHeader('间隔统计', p),
        _IntervalRows(palette: p, avg: iv.avg, max: iv.max, since: iv.since),
        ],
      ),
    );
  }
}

class _StatHeader extends StatelessWidget {
  const _StatHeader(this.text, this.palette);
  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppText.body(
            size: 12, weight: FontWeight.w600, color: palette.ink2, letterSpacing: 1.5));
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.palette, required this.items});
  final AppPalette palette;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    Widget cell(int i) {
      final col = i % 3;
      final row = i ~/ 3;
      return Container(
        decoration: BoxDecoration(
          border: Border(
            right: col < 2 ? BorderSide(color: p.line) : BorderSide.none,
            bottom: row < 1 ? BorderSide(color: p.line) : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(items[i].$1,
                style: AppText.body(size: 11, color: p.ink2, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(items[i].$2, style: AppText.serif(size: 24, color: p.ink, height: 1)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var row = 0; row < 2; row++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (var col = 0; col < 3; col++) Expanded(child: cell(row * 3 + col))],
              ),
            ),
        ],
      ),
    );
  }
}

class _IntervalRows extends StatelessWidget {
  const _IntervalRows({
    required this.palette,
    required this.avg,
    required this.max,
    required this.since,
  });
  final AppPalette palette;
  final String avg, max, since;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    Widget row(String label, String value, {bool border = true}) => Container(
          decoration: border
              ? BoxDecoration(border: Border(bottom: BorderSide(color: p.line)))
              : null,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.body(size: 14, color: p.ink2)),
              Text(value, style: AppText.serif(size: 16, color: p.ink)),
            ],
          ),
        );
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
      child: Column(
        children: [
          row('平均间隔', avg),
          row('最长未记录', max),
          row('最近一次距今', since, border: false),
        ],
      ),
    );
  }
}
