import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../widgets/pin_pad.dart';

/// 弹出「设置/修改密码」面板，返回新设置的 6 位 PIN（取消返回 null）。
Future<String?> showSetPinSheet(BuildContext context, AppPalette palette,
    {bool isChange = false}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SetPinSheet(palette: palette, isChange: isChange),
  );
}

class _SetPinSheet extends StatefulWidget {
  const _SetPinSheet({required this.palette, required this.isChange});
  final AppPalette palette;
  final bool isChange;

  @override
  State<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<_SetPinSheet> {
  String _input = '';
  String _first = '';
  bool _confirmStep = false;
  bool _error = false;

  void _onDigit(String d) {
    if (_input.length >= 6) return;
    setState(() {
      _error = false;
      _input += d;
    });
    if (_input.length == 6) _process();
  }

  void _process() {
    if (!_confirmStep) {
      // 第一步完成 → 进入确认
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        setState(() {
          _first = _input;
          _input = '';
          _confirmStep = true;
        });
      });
    } else {
      if (_input == _first) {
        Navigator.pop(context, _first);
      } else {
        // 不一致 → 从头再来
        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted) return;
          setState(() {
            _input = '';
            _first = '';
            _confirmStep = false;
            _error = true;
          });
        });
      }
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _error = false;
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final title = widget.isChange ? '修改密码' : '设置密码';
    final hint = _error
        ? '两次输入不一致，请重新设置'
        : (_confirmStep ? '请再次输入确认' : '设置一个 6 位数字密码');

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(22, 10, 22, 30 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 5,
            margin: const EdgeInsets.fromLTRB(0, 6, 0, 16),
            decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(3)),
          ),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 48,
                  child: Text('取消', style: AppText.body(size: 15, color: p.ink2)),
                ),
              ),
              Expanded(
                child: Center(child: Text(title, style: AppText.serif(size: 18, color: p.ink))),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          Text(hint,
              style: AppText.body(
                  size: 14, color: _error ? AppPalette.danger : p.ink3)),
          const SizedBox(height: 28),
          PinPad(
            palette: p,
            filled: _input.length,
            error: _error,
            onDigit: _onDigit,
            onBackspace: _onBackspace,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
