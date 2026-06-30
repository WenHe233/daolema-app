import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';

/// 6 位密码点阵 + 数字键盘（锁屏与「设置密码」共用）。错误时点阵左右抖动。
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.palette,
    required this.filled,
    required this.onDigit,
    required this.onBackspace,
    this.length = 6,
    this.error = false,
  });

  final AppPalette palette;
  final int filled;
  final int length;
  final bool error;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void didUpdateWidget(covariant PinPad old) {
    super.didUpdateWidget(old);
    if (widget.error && !old.error) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final dotColor = widget.error ? AppPalette.danger : p.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            // 衰减正弦抖动（约 3 个来回）
            final t = _shake.value;
            final dx = t == 0 ? 0.0 : (1 - t) * 10 * math.sin(t * 2 * math.pi * 3);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < widget.filled ? dotColor : Colors.transparent,
                    border: Border.all(color: dotColor, width: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < 4; row++) ...[
              if (row > 0) const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var col = 0; col < 3; col++) ...[
                    if (col > 0) const SizedBox(width: 18),
                    _Key(
                      palette: p,
                      label: _keys[row * 3 + col],
                      onDigit: widget.onDigit,
                      onBackspace: widget.onBackspace,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

}

class _Key extends StatelessWidget {
  const _Key({
    required this.palette,
    required this.label,
    required this.onDigit,
    required this.onBackspace,
  });
  final AppPalette palette;
  final String label;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    if (label.isEmpty) return const SizedBox(width: 72, height: 72);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => label == '⌫' ? onBackspace() : onDigit(label),
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
