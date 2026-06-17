import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common.dart';
import 'widgets/heatmap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final counts = c.counts;
    final last = c.lastRecord;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 108),
      children: [
        // 顶部 logo + 应用名
        Row(
          children: [
            AppLogo(palette: p),
            const SizedBox(width: 9),
            Text(
              c.appName,
              style: AppText.body(
                size: 12,
                weight: FontWeight.w600,
                color: p.ink2,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          c.homeTitle,
          style: AppText.serif(size: 34, color: p.ink, height: 1.2, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          '${c.todayDateText} · 距上次 ${last != null ? c.intervals.since : '—'}',
          style: AppText.body(size: 14, color: p.ink2),
        ),
        const SizedBox(height: 26),
        _StatDivider(palette: p, counts: counts),
        const SizedBox(height: 28),
        // 一键记录
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.oneClick,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: p.shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: p.accentInk, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text('记录一次',
                    style: AppText.serif(size: 18, color: p.accentInk)),
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => c.openAdd(c.todayKey),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: Text('详细记录 / 补录 ›',
                textAlign: TextAlign.center,
                style: AppText.body(size: 14, color: p.ink2)),
          ),
        ),
        // 本周目标
        _TopBorderBlock(
          palette: p,
          onTap: () => c.openOverlay('goals'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('本周目标',
                      style: AppText.body(
                          size: 12, weight: FontWeight.w600, color: p.ink2, letterSpacing: 1.5)),
                  Text(c.goalText, style: AppText.serif(size: 15, color: p.accent)),
                ],
              ),
              const SizedBox(height: 14),
              ProgressBar(palette: p, pct: c.goalPct),
              const SizedBox(height: 10),
              Text(c.goalSub, style: AppText.body(size: 12, color: p.ink3)),
            ],
          ),
        ),
        // 年度热力图
        _TopBorderBlock(
          palette: p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('年度热力图',
                      style: AppText.body(
                          size: 12, weight: FontWeight.w600, color: p.ink2, letterSpacing: 1.5)),
                  Text('今年 ${counts.year} 次',
                      style: AppText.body(size: 12, color: p.ink3)),
                ],
              ),
              const SizedBox(height: 16),
              Heatmap(palette: p, data: c.heat),
            ],
          ),
        ),
        // 最近一次记录
        _TopBorderBlock(
          palette: p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('最近一次记录',
                  style: AppText.body(
                      size: 12, weight: FontWeight.w600, color: p.ink2, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              if (last != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.recentWhen, style: AppText.serif(size: 18, color: p.ink)),
                          if (last.tags.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [for (final t in last.tags) PillTag(t, palette: p)],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('心情 ${last.mood}/5',
                            style: AppText.body(size: 12, color: p.ink3, height: 1.8)),
                        Text('压力 ${last.stress}/5',
                            style: AppText.body(size: 12, color: p.ink3, height: 1.8)),
                      ],
                    ),
                  ],
                )
              else
                Text('还没有记录', style: AppText.body(size: 14, color: p.ink3)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 今日/本周/本月 三栏数字（上下发丝线 + 列间发丝线）。
class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.palette, required this.counts});
  final AppPalette palette;
  final Counts counts;

  @override
  Widget build(BuildContext context) {
    Widget col(int n, String label, {bool border = true}) => Expanded(
          child: Container(
            decoration: border
                ? BoxDecoration(border: Border(right: BorderSide(color: palette.line)))
                : null,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text('$n', style: AppText.serif(size: 30, color: palette.ink, height: 1)),
                const SizedBox(height: 8),
                Text(label,
                    style: AppText.body(size: 12, color: palette.ink2, letterSpacing: 0.5)),
              ],
            ),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: palette.line),
          bottom: BorderSide(color: palette.line),
        ),
      ),
      child: Row(
        children: [
          col(counts.today, '今日'),
          col(counts.week, '本周'),
          col(counts.month, '本月', border: false),
        ],
      ),
    );
  }
}

/// 顶部发丝线分隔的内容块（首页里多处复用）。
class _TopBorderBlock extends StatelessWidget {
  const _TopBorderBlock({required this.palette, required this.child, this.onTap});
  final AppPalette palette;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.line)),
        ),
        child: child,
      ),
    );
  }
}

/// 通用进度条（本周/本月目标、标签排行复用）。
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.palette, required this.pct, this.height = 6});
  final AppPalette palette;
  final int pct;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: palette.surface2,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (pct / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
