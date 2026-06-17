import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';
import '../../widgets/ios_switch.dart';
import '../home/home_page.dart' show ProgressBar;
import 'overlay_scaffold.dart';

class GoalsOverlay extends StatelessWidget {
  const GoalsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final g = c.goals;

    return OverlayScaffold(
      palette: p,
      title: '目标设置',
      onBack: c.closeOverlay,
      children: [
        // 设定目标开关
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('设定目标', style: AppText.body(size: 15, color: p.ink)),
                    const SizedBox(height: 2),
                    Text('关闭则只记录、不提示',
                        style: AppText.body(size: 12, color: p.ink3)),
                  ],
                ),
              ),
              AppSwitch(
                  value: g.enabled, onTap: () => c.toggleGoal('enabled'), palette: p),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (g.enabled) ...[
          GroupedCard(
            palette: p,
            children: [
              _StepperRow(
                palette: p,
                label: '每周不超过',
                value: '${g.weekMax} 次',
                onMinus: () => c.setGoalValue('weekMax', (g.weekMax - 1).clamp(1, 999)),
                onPlus: () => c.setGoalValue('weekMax', g.weekMax + 1),
              ),
              _StepperRow(
                palette: p,
                label: '每月不超过',
                value: '${g.monthMax} 次',
                onMinus: () => c.setGoalValue('monthMax', (g.monthMax - 1).clamp(1, 999)),
                onPlus: () => c.setGoalValue('monthMax', g.monthMax + 1),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GroupedCard(
            palette: p,
            children: [
              SettingsRow(
                palette: p,
                title: '两次记录至少间隔',
                trailing: AppSwitch(
                    value: g.gapEnabled, onTap: () => c.toggleGoal('gapEnabled'), palette: p),
              ),
              if (g.gapEnabled)
                _StepperRow(
                  palette: p,
                  label: '间隔时长',
                  labelColor: p.ink2,
                  labelSize: 14,
                  value: '${g.minGap} 小时',
                  onMinus: () => c.setGoalValue('minGap', (g.minGap - 1).clamp(1, 999)),
                  onPlus: () => c.setGoalValue('minGap', g.minGap + 1),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('避免某个时间段', style: AppText.body(size: 15, color: p.ink)),
                      const SizedBox(height: 2),
                      Text(c.avoidText, style: AppText.body(size: 12, color: p.ink3)),
                    ],
                  ),
                ),
                AppSwitch(
                    value: g.avoidEnabled,
                    onTap: () => c.toggleGoal('avoidEnabled'),
                    palette: p),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader('本月进度', palette: p, margin: const EdgeInsets.only(bottom: 14)),
          _ProgressLine(palette: p, label: '本周记录', text: c.goalText, pct: c.goalPct),
          const SizedBox(height: 16),
          _ProgressLine(
              palette: p, label: '本月记录', text: c.monthGoalText, pct: c.monthGoalPct),
          const SizedBox(height: 16),
          Text(c.goalNote, style: AppText.body(size: 12, color: p.ink3, height: 1.7)),
        ] else
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '未设目标\nApp 只为你安静地记录，不做任何提示或评判。',
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: p.ink3, height: 1.8),
            ),
          ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.palette,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.labelColor,
    this.labelSize = 15,
  });
  final AppPalette palette;
  final String label, value;
  final VoidCallback onMinus, onPlus;
  final Color? labelColor;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(size: labelSize, color: labelColor ?? p.ink)),
          Row(
            children: [
              StepperButton(palette: p, icon: '−', onTap: onMinus, size: 30, fontSize: 18),
              const SizedBox(width: 14),
              SizedBox(
                width: 54,
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: AppText.serif(size: 16, color: p.ink)),
              ),
              const SizedBox(width: 14),
              StepperButton(palette: p, icon: '+', onTap: onPlus, size: 30, fontSize: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.palette,
    required this.label,
    required this.text,
    required this.pct,
  });
  final AppPalette palette;
  final String label, text;
  final int pct;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body(size: 14, color: p.ink)),
            Text(text, style: AppText.serif(size: 14, color: p.accent)),
          ],
        ),
        const SizedBox(height: 10),
        ProgressBar(palette: p, pct: pct),
      ],
    );
  }
}
