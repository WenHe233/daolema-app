import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/palette.dart';

/// 全屏覆盖层脚手架：背景 bg、右滑淡入进入（对应源原型 ovIn 动画）、返回头 + 标题。
class OverlayScaffold extends StatefulWidget {
  const OverlayScaffold({
    super.key,
    required this.palette,
    required this.title,
    required this.onBack,
    required this.children,
  });

  final AppPalette palette;
  final String title;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  State<OverlayScaffold> createState() => _OverlayScaffoldState();
}

class _OverlayScaffoldState extends State<OverlayScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_anim.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(14 * (1 - t), 0), child: child),
        );
      },
      child: Container(
        color: p.bg,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 40),
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onBack,
                  child: Text('‹',
                      style: AppText.body(size: 24, color: p.ink2, height: 1)),
                ),
                const SizedBox(width: 12),
                Text(widget.title, style: AppText.serif(size: 24, color: p.ink)),
              ],
            ),
            const SizedBox(height: 26),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}
