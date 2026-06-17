import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// iOS 风格开关，51×31，与源原型尺寸/动效一致（开=主色，关=swoff，旋钮位移 20）。
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onTap,
    required this.palette,
  });

  final bool value;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 51,
        height: 31,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? palette.accent : palette.swoff,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
