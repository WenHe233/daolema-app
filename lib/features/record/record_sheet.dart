import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../util/dates.dart';
import '../../widgets/common.dart';

/// 记录弹窗：底部上滑 sheet（日期/时间/次数/标签/心情/压力/备注，保存或删除）。
class RecordSheet extends StatefulWidget {
  const RecordSheet({super.key});

  @override
  State<RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<RecordSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();
    _note = TextEditingController(
        text: context.read<AppController>().sheet?.note ?? '');
  }

  @override
  void dispose() {
    _anim.dispose();
    _note.dispose();
    super.dispose();
  }

  DateTime _parseDate(String d) {
    final p = d.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  Future<void> _pickDate(AppController c) async {
    final s = c.sheet;
    if (s == null) return;
    var picked = _parseDate(s.date);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => _PickerSheet(
        palette: c.palette,
        onDone: () {
          c.updateSheet((d) => d.date = dateKey(picked));
          Navigator.pop(ctx);
        },
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: picked,
          maximumDate: DateTime.now().add(const Duration(days: 1)),
          onDateTimeChanged: (d) => picked = d,
        ),
      ),
    );
  }

  Future<void> _pickTime(AppController c) async {
    final s = c.sheet;
    if (s == null) return;
    final parts = s.time.split(':').map(int.parse).toList();
    var picked = DateTime(2020, 1, 1, parts[0], parts.length > 1 ? parts[1] : 0);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => _PickerSheet(
        palette: c.palette,
        onDone: () {
          c.updateSheet((d) => d.time = '${pad2(picked.hour)}:${pad2(picked.minute)}');
          Navigator.pop(ctx);
        },
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: picked,
          onDateTimeChanged: (d) => picked = d,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;
    final s = c.sheet;
    if (s == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // 背景遮罩
        Positioned.fill(
          child: GestureDetector(
            onTap: c.closeSheet,
            child: FadeTransition(
              opacity: _anim,
              child: Container(color: const Color(0x66000000)),
            ),
          ),
        ),
        // 面板
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      22, 10, 22, 30 + MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 5,
                          margin: const EdgeInsets.fromLTRB(0, 6, 0, 16),
                          decoration: BoxDecoration(
                            color: p.line,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // 头部
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.closeSheet,
                            child: SizedBox(
                              width: 48,
                              child: Text('取消',
                                  style: AppText.body(size: 15, color: p.ink2)),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(c.sheetTitle,
                                  style: AppText.serif(size: 18, color: p.ink)),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.saveSheet,
                            child: SizedBox(
                              width: 48,
                              child: Text('保存',
                                  textAlign: TextAlign.right,
                                  style: AppText.body(
                                      size: 15, weight: FontWeight.w700, color: p.accent)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 日期/时间/次数
                      Container(
                        decoration: BoxDecoration(
                          color: p.surface2,
                          border: Border.all(color: p.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _FieldRow(
                              palette: p,
                              label: '日期',
                              value: s.date,
                              onTap: () => _pickDate(c),
                            ),
                            Container(height: 1, color: p.line),
                            _FieldRow(
                              palette: p,
                              label: '时间',
                              value: s.time,
                              onTap: () => _pickTime(c),
                            ),
                            Container(height: 1, color: p.line),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('次数', style: AppText.body(size: 15, color: p.ink)),
                                  Row(
                                    children: [
                                      StepperButton(
                                        palette: p,
                                        icon: '−',
                                        onTap: () => c.updateSheet(
                                            (d) => d.count = (d.count - 1).clamp(1, 20)),
                                      ),
                                      const SizedBox(width: 16),
                                      Text('${s.count}',
                                          style: AppText.serif(size: 18, color: p.ink)),
                                      const SizedBox(width: 16),
                                      StepperButton(
                                        palette: p,
                                        icon: '+',
                                        onTap: () => c.updateSheet(
                                            (d) => d.count = (d.count + 1).clamp(1, 20)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 标签
                      _MiniHeader('标签', p),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final name in c.tags)
                            _TagChip(
                              palette: p,
                              name: name,
                              selected: s.tags.contains(name),
                              onTap: () => c.toggleSheetTag(name),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ScoreRow(
                        palette: p,
                        label: '心情',
                        value: s.mood,
                        onPick: (n) => c.updateSheet((d) => d.mood = n),
                      ),
                      const SizedBox(height: 16),
                      _ScoreRow(
                        palette: p,
                        label: '压力',
                        value: s.stress,
                        onPick: (n) => c.updateSheet((d) => d.stress = n),
                      ),
                      const SizedBox(height: 22),
                      _MiniHeader('备注', p),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _note,
                        maxLines: 3,
                        onChanged: (v) => c.sheet?.note = v,
                        style: AppText.body(size: 14, color: p.ink, height: 1.5),
                        cursorColor: p.accent,
                        decoration: InputDecoration(
                          hintText: '可选，仅保存在本机',
                          hintStyle: AppText.body(size: 14, color: p.ink3),
                          filled: true,
                          fillColor: p.surface2,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: p.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: p.line),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: p.accent),
                          ),
                        ),
                      ),
                      if (c.sheetMode == 'edit') ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: c.deleteFromSheet,
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              border: Border.all(color: p.line),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text('删除这条记录',
                                  style: AppText.body(
                                      size: 15,
                                      weight: FontWeight.w600,
                                      color: AppPalette.danger)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.palette, required this.child, required this.onDone});
  final AppPalette palette;
  final Widget child;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: palette.surface,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              onPressed: onDone,
              child: Text('完成',
                  style: AppText.body(size: 15, weight: FontWeight.w600, color: palette.accent)),
            ),
          ),
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: palette.brightness,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: AppText.body(size: 20, color: palette.ink),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.palette,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final AppPalette palette;
  final String label, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body(size: 15, color: palette.ink)),
            Text(value, style: AppText.body(size: 15, color: palette.ink)),
          ],
        ),
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader(this.text, this.palette);
  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppText.body(
            size: 12, weight: FontWeight.w600, color: palette.ink3, letterSpacing: 1.5));
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.palette,
    required this.name,
    required this.selected,
    required this.onTap,
  });
  final AppPalette palette;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : Colors.transparent,
          border: Border.all(color: selected ? p.accent : p.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(name,
            style: AppText.body(size: 14, color: selected ? p.accent : p.ink2)),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.palette,
    required this.label,
    required this.value,
    required this.onPick,
  });
  final AppPalette palette;
  final String label;
  final int value;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.body(size: 15, color: p.ink)),
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              if (n > 1) const SizedBox(width: 9),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPick(n),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: n <= value ? p.accent : Colors.transparent,
                    border: Border.all(color: n <= value ? p.accent : p.line),
                  ),
                  child: Text('$n',
                      style: AppText.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: n <= value ? p.accentInk : p.ink3)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
