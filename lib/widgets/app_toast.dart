import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';

/// 底部居中的 Toast 药丸（深色底 + 主色勾选圆点），对应源原型的 toast。
class AppToast extends StatelessWidget {
  const AppToast(this.text, {super.key, required this.palette});

  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final check =
        '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" '
        'viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="3.5" '
        'stroke-linecap="round" stroke-linejoin="round">'
        '<polyline points="20 6 9 17 4 12"/></svg>';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: palette.ink,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, 12), blurRadius: 30),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
            child: SvgPicture.string(check, width: 12, height: 12),
          ),
          const SizedBox(width: 9),
          Text(
            text,
            style: AppText.body(size: 15, weight: FontWeight.w600, color: palette.bg),
          ),
        ],
      ),
    );
  }
}
