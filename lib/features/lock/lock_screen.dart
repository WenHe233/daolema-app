import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/pin_pad.dart';

/// 隐私锁：6 位密码点阵 + 数字键盘（真实 PIN 校验）+ 生物识别解锁。
class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

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
              Text(c.lockError ? '密码错误，请重试' : '输入密码以解锁',
                  style: AppText.body(
                      size: 14, color: c.lockError ? const Color(0xFFC0492F) : p.ink3)),
              const SizedBox(height: 32),
              PinPad(
                palette: p,
                filled: c.lockInput.length,
                error: c.lockError,
                onDigit: c.pressDigit,
                onBackspace: c.backspaceDigit,
              ),
              const SizedBox(height: 24),
              if (c.settings.biometric)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: c.tryBiometricUnlock,
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
          Positioned(top: 9, left: 11, child: _bar()),
          Positioned(top: 9, right: 11, child: _bar()),
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
