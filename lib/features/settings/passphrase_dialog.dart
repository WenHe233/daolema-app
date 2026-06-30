import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/palette.dart';

/// 口令输入对话框。
/// - [confirm] = true：备份时输入两次并校验一致。
/// - [confirm] = false：恢复时输入一次。
/// 返回口令（取消返回 null）。
Future<String?> showPassphraseDialog(
  BuildContext context,
  AppPalette palette, {
  required bool confirm,
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PassphraseDialog(palette: palette, confirm: confirm, title: title),
  );
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.palette, required this.confirm, required this.title});
  final AppPalette palette;
  final bool confirm;
  final String title;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _pass.text;
    if (v.isEmpty) {
      setState(() => _error = '请输入口令');
      return;
    }
    if (widget.confirm && v != _pass2.text) {
      setState(() => _error = '两次口令不一致');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: AppText.body(size: 14, color: p.ink3),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: p.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: p.accent),
          ),
        );

    return AlertDialog(
      backgroundColor: p.surface,
      title: Text(widget.title, style: AppText.serif(size: 18, color: p.ink)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pass,
            obscureText: true,
            autofocus: true,
            cursorColor: p.accent,
            style: AppText.body(size: 15, color: p.ink),
            decoration: deco('口令'),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _pass2,
              obscureText: true,
              cursorColor: p.accent,
              style: AppText.body(size: 15, color: p.ink),
              decoration: deco('再次输入口令'),
            ),
          ],
          ?(_error == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_error!,
                        style: AppText.body(size: 12, color: AppPalette.danger)),
                  ),
                )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: AppText.body(size: 15, color: p.ink2)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text('确定',
              style: AppText.body(size: 15, weight: FontWeight.w600, color: p.accent)),
        ),
      ],
    );
  }
}
