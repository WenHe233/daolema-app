import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/palette.dart';
import '../../../util/stats.dart';

/// GitHub 风格年度热力图：53 周横向滚动，默认滚到最右（今天），含月份标注与图例。
class Heatmap extends StatefulWidget {
  const Heatmap({super.key, required this.palette, required this.data});

  final AppPalette palette;
  final HeatData data;

  @override
  State<Heatmap> createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  final _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始滚到最右（对应源原型 heatRef 的 scrollLeft = scrollWidth）。
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToEnd());
  }

  void _jumpToEnd() {
    if (_ctrl.hasClients) {
      _ctrl.jumpTo(_ctrl.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final d = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          controller: _ctrl,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 4),
          child: SizedBox(
            width: d.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 14,
                  child: Stack(
                    children: [
                      for (final ml in d.monthLabels)
                        Positioned(
                          left: ml.left,
                          top: 0,
                          child: Text(ml.text,
                              style: AppText.body(size: 10, color: p.ink3)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var w = 0; w < d.weeks.length; w++) ...[
                      if (w > 0) const SizedBox(width: 3),
                      Column(
                        children: [
                          for (var i = 0; i < d.weeks[w].length; i++) ...[
                            if (i > 0) const SizedBox(height: 3),
                            Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: d.weeks[w][i],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('少', style: AppText.body(size: 11, color: p.ink3)),
            const SizedBox(width: 5),
            for (final c in p.heat) ...[
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text('多', style: AppText.body(size: 11, color: p.ink3)),
          ],
        ),
      ],
    );
  }
}
