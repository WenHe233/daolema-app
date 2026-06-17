import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import 'overlay_scaffold.dart';

class TagsOverlay extends StatefulWidget {
  const TagsOverlay({super.key});

  @override
  State<TagsOverlay> createState() => _TagsOverlayState();
}

class _TagsOverlayState extends State<TagsOverlay> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.palette;

    return OverlayScaffold(
      palette: p,
      title: '标签管理',
      onBack: c.closeOverlay,
      children: [
        // 标签列表 + 删除
        Container(
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.line),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < c.tags.length; i++) ...[
                if (i > 0) Container(height: 1, color: p.line),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.tags[i], style: AppText.body(size: 15, color: p.ink)),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => c.delTag(c.tags[i]),
                        child: Text('删除',
                            style: AppText.body(size: 13, color: AppPalette.danger)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 添加标签输入（评论4）
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: c.setNewTag,
                onSubmitted: (_) => _add(c),
                style: AppText.body(size: 15, color: p.ink),
                cursorColor: p.accent,
                decoration: InputDecoration(
                  hintText: '新标签名称',
                  hintStyle: AppText.body(size: 15, color: p.ink3),
                  filled: true,
                  fillColor: p.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.accent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _add(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('添加',
                    style: AppText.body(
                        size: 15, weight: FontWeight.w600, color: p.accentInk)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('标签帮助你回顾每次记录的情境，全部仅保存在本机。',
              style: AppText.body(size: 12, color: p.ink3, height: 1.7)),
        ),
      ],
    );
  }

  void _add(AppController c) {
    c.setNewTag(_ctrl.text);
    c.addTag();
    _ctrl.clear();
  }
}
