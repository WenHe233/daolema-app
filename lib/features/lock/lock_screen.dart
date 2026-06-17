import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/app_logo.dart';

/// 隐私锁：6 位密码点阵 + 数字键盘 + Face ID（任意 6 位或 Face ID 解锁，同原型）。
class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;

    return Container(
      color: p.bg,
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 40),
          child: Column(
        children: [
          AppLogo(palette: p, cell: 9, gap: 4, padding: 13, radius: 18, cellRadius: 2),
          const SizedBox(height: 18),
          Text(c.appName, style: AppText.serif(size: 22, color: p.ink)),
          const SizedBox(height: 6),
          Text('输入密码以解锁', style: AppText.body(size: 14, color: p.ink3)),
          const SizedBox(height: 32),
          // 点阵
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < c.lockInput.length ? p.accent : Colors.transparent,
                    border: Border.all(color: p.accent, width: 1.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),
          // 数字键盘
          Column(
            children: [
              for (var row = 0; row < 4; row++) ...[
                if (row > 0) const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var col = 0; col < 3; col++) ...[
                      if (col > 0) const SizedBox(width: 18),
                      _Key(palette: p, label: _keys[row * 3 + col], controller: c),
                    ],
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // Face ID
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.unlockWithFaceId,
            child: Column(
              children: [
                _FaceIdIcon(color: p.accent),
                const SizedBox(height: 8),
                Text('使用 Face ID', style: AppText.body(size: 13, color: p.accent)),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.palette, required this.label, required this.controller});
  final AppPalette palette;
  final String label;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    if (label.isEmpty) return const SizedBox(width: 72, height: 72);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          label == '⌫' ? controller.backspaceDigit() : controller.pressDigit(label),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.surface, shape: BoxShape.circle),
        child: Text(label,
            style: AppText.serif(size: 26, weight: FontWeight.w500, color: p.ink)),
      ),
    );
  }
}

/// 简笔 Face ID 图标（圆角方框 + 两眼 + 嘴），还原源原型画法。
class _FaceIdIcon extends StatelessWidget {
  const _FaceIdIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          Positioned(
            top: 9,
            left: 11,
            child: _bar(),
          ),
          Positioned(
            top: 9,
            right: 11,
            child: _bar(),
          ),
          Positioned(
            bottom: 9,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar() => Container(
        width: 3,
        height: 8,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
}
