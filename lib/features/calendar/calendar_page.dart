import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/record_entry.dart';
import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final cells = c.calCells;
    final selRecords = c.selRecords;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 108),
      children: [
        // 翻月头
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavArrow(palette: p, icon: '‹', onTap: () => c.shiftMonth(-1)),
            Text(c.calTitle, style: AppText.serif(size: 22, color: p.ink)),
            _NavArrow(palette: p, icon: '›', onTap: () => c.shiftMonth(1)),
          ],
        ),
        const SizedBox(height: 26),
        // 星期表头
        Row(
          children: [
            for (final h in c.calHeader)
              Expanded(
                child: Center(
                  child: Text(h, style: AppText.body(size: 12, color: p.ink3)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // 日期网格
        Container(
          padding: const EdgeInsets.only(bottom: 26),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (final cell in cells) _DayCell(palette: p, cell: cell, onTap: c.selectDate),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 选中日详情
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.selTitle, style: AppText.serif(size: 18, color: p.ink)),
                  const SizedBox(height: 3),
                  Text('共 ${c.selTotal} 次',
                      style: AppText.body(size: 12, color: p.ink3)),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => c.openAdd(c.selectedDate),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: p.line),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('＋ 补录',
                    style: AppText.body(size: 13, weight: FontWeight.w600, color: p.accent)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selRecords.isNotEmpty)
          _RecordList(palette: p, records: selRecords, controller: c)
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text('这一天没有记录',
                  style: AppText.body(size: 14, color: p.ink3)),
            ),
          ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.palette, required this.icon, required this.onTap});
  final AppPalette palette;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Center(
          child: Text(icon, style: AppText.body(size: 20, color: palette.ink2)),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.palette, required this.cell, required this.onTap});
  final AppPalette palette;
  final CalCell cell;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cell.selectable && cell.dateKey != null ? () => onTap(cell.dateKey!) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: cell.circleBg, shape: BoxShape.circle),
            child: Text(
              cell.day?.toString() ?? '',
              style: AppText.serif(size: 15, color: cell.numColor),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: cell.dotColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.palette, required this.records, required this.controller});
  final AppPalette palette;
  final List<RecordEntry> records;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) Container(height: 1, color: p.line),
            _RecordTile(palette: p, record: records[i], controller: controller),
          ],
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.palette, required this.record, required this.controller});
  final AppPalette palette;
  final RecordEntry record;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final r = record;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.timeText, style: AppText.serif(size: 17, color: p.ink)),
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.openEdit(r),
                    child: Text('编辑', style: AppText.body(size: 13, color: p.accent)),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.deleteRecord(r.id),
                    child: Text('删除',
                        style: AppText.body(size: 13, color: AppPalette.danger)),
                  ),
                ],
              ),
            ],
          ),
          if (r.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final t in r.tags) PillTag(t, palette: p)],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text('心情 ${r.mood}/5', style: AppText.body(size: 12, color: p.ink3)),
              const SizedBox(width: 16),
              Text('压力 ${r.stress}/5', style: AppText.body(size: 12, color: p.ink3)),
            ],
          ),
          if (r.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(r.note, style: AppText.body(size: 13, color: p.ink2, height: 1.6)),
          ],
        ],
      ),
    );
  }
}
