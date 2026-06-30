import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/backup_service.dart';
import '../data/file_pick_service.dart';
import '../data/models/app_models.dart';
import '../data/models/record_entry.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/share_service.dart';
import '../theme/palette.dart';
import '../util/dates.dart';
import '../util/stats.dart';

/// 记录弹窗的草稿（对应源原型的 `sheet` 对象，time 用 'HH:MM' 文本）。
class SheetDraft {
  SheetDraft({
    this.id,
    required this.date,
    required this.time,
    this.count = 1,
    List<String>? tags,
    this.mood = 3,
    this.stress = 3,
    this.note = '',
  }) : tags = tags ?? [];

  String? id;
  String date;
  String time;
  int count;
  List<String> tags;
  int mood;
  int stress;
  String note;
}

class Counts {
  const Counts(this.today, this.week, this.month, this.year, this.total);
  final int today, week, month, year, total;
}

class CalCell {
  const CalCell({
    this.day,
    this.dateKey,
    required this.selectable,
    required this.circleBg,
    required this.numColor,
    required this.dotColor,
  });
  final int? day;
  final String? dateKey;
  final bool selectable;
  final Color circleBg;
  final Color numColor;
  final Color dotColor;
}

/// 全局状态 + 行为，移植自源原型 `Component`（state + renderVals + 各 action）。
class AppController extends ChangeNotifier {
  AppController({
    required RecordRepository recordRepo,
    required SettingsRepository settingsRepo,
    required List<RecordEntry> records,
    required AppSettings settings,
    required Goals goals,
    required List<String> tags,
    bool pinIsSet = false,
    ShareService? shareService,
    FilePickService? filePickService,
    AuthService? authService,
    DateTime? now,
  }) : _recordRepo = recordRepo,
       _settingsRepo = settingsRepo,
       _records = records,
       _settings = settings,
       _goals = goals,
       _tags = tags,
       _pinIsSet = pinIsSet,
       _share = shareService ?? ShareService(),
       _filePick = filePickService ?? FilePickService(),
       _auth = authService ?? AuthService() {
    today = midnight(now ?? DateTime.now());
    calY = today.year;
    calM = today.month - 1; // 0-based，对齐源原型
    selectedDate = dateKey(today);
    locked = settings.appLock && pinIsSet; // App 锁开启且已设 PIN 才启动即锁
  }

  final RecordRepository _recordRepo;
  final SettingsRepository _settingsRepo;
  final ShareService _share;
  final FilePickService _filePick;
  final AuthService _auth;

  List<RecordEntry> _records;
  AppSettings _settings;
  Goals _goals;
  List<String> _tags;
  bool _pinIsSet;

  late final DateTime today;

  // ---- UI 瞬时态 ----
  String activeTab = 'home';
  String? overlay; // 'goals' | 'tags' | 'about'
  bool locked = false;
  String lockInput = '';
  bool lockError = false; // 上次 PIN 校验失败（用于抖动反馈）
  late int calY;
  late int calM;
  late String selectedDate;
  String range = '7';
  String? toast;
  bool sheetOpen = false;
  String sheetMode = 'add';
  SheetDraft? sheet;
  String newTag = '';
  Timer? _toastTimer;

  // ---- 暴露的只读数据 ----
  List<RecordEntry> get records => _records;
  AppSettings get settings => _settings;
  Goals get goals => _goals;
  List<String> get tags => _tags;
  AppPalette get palette =>
      AppPalette.resolve(_settings.theme, _settings.accent);

  String get todayKey => dateKey(today);

  // ---- 文案（含伪装模式）----
  bool get disguise => _settings.disguise;
  String get appName => disguise ? '习惯记录' : '导了吗';
  String get homeTitle => disguise ? '今天状态如何？' : '今天记录了吗？';
  String get notifPreview => _settings.blurNotif
      ? '通知显示为「你有一条新提醒」'
      : (disguise ? '通知显示为「记一下今天的状态」' : '通知显示为「记一下今天的记录」');

  String get todayDateText =>
      '${today.month}月${today.day}日 周${kDow[jsDay(today)]}';

  // ---- 计数 ----
  Counts get counts {
    final tk = todayKey;
    final wkStart = startOfWeek(today, _settings.weekStartMonday);
    final wkEnd = wkStart.add(const Duration(days: 7));
    final ym = '${today.year}-${pad2(today.month)}';
    final yy = '${today.year}';
    var t = 0, w = 0, m = 0, y = 0, tot = 0;
    for (final r in _records) {
      final o = r.occ;
      tot += o;
      if (r.date == tk) t += o;
      final dt = r.when;
      if (!dt.isBefore(wkStart) && dt.isBefore(wkEnd)) w += o;
      if (r.date.startsWith(ym)) m += o;
      if (r.date.startsWith(yy)) y += o;
    }
    return Counts(t, w, m, y, tot);
  }

  RecordEntry? get lastRecord {
    if (_records.isEmpty) return null;
    final sorted = [..._records]..sort((a, b) => b.when.compareTo(a.when));
    return sorted.first;
  }

  String get recentWhen {
    final last = lastRecord;
    if (last == null) return '';
    final ld = last.when;
    final yd = today.subtract(const Duration(days: 1));
    final dayText = last.date == todayKey
        ? '今天'
        : (last.date == dateKey(yd) ? '昨天' : '${ld.month}月${ld.day}日');
    return '$dayText ${last.timeText}';
  }

  // ---- 目标 ----
  String get goalText => '${counts.week} / ${_goals.weekMax}';
  int get goalPct =>
      math.min(100, (counts.week / _goals.weekMax * 100).round());
  String get goalSub {
    if (!_goals.enabled) return '未设目标，仅记录';
    final w = counts.week;
    return w >= _goals.weekMax
        ? '本周已达到设定上限，按自己的节奏来'
        : '距本周上限还有 ${math.max(0, _goals.weekMax - w)} 次';
  }

  String get monthGoalText => '${counts.month} / ${_goals.monthMax}';
  int get monthGoalPct =>
      math.min(100, (counts.month / _goals.monthMax * 100).round());
  String get goalNote => '目标只是给你一个参照，没有失败一说。你可以随时调整或关闭。';
  String get goalSummary => _goals.enabled ? '每周${_goals.weekMax}次' : '未设置';
  String get avoidText => _goals.avoidEnabled ? '00:00 – 06:00 不提醒' : '未开启';

  // ---- 派生数据 ----
  HeatData get heat => buildHeat(
    countMap(_records),
    today,
    _settings.weekStartMonday,
    palette.heat,
  );

  StatsData get statsData =>
      computeStats(_records, today, range, _settings.weekStartMonday);

  IntervalData get intervals => computeIntervals(_records, DateTime.now());

  List<Color> get legendColors => palette.heat;

  // ---- 日历 ----
  String get calTitle => '$calY 年 ${calM + 1} 月';

  List<String> get calHeader {
    final ws = weekStartOffset(_settings.weekStartMonday);
    return [for (var i = 0; i < 7; i++) kDow[(ws + i) % 7]];
  }

  List<CalCell> get calCells {
    final p = palette;
    final ws = weekStartOffset(_settings.weekStartMonday);
    final cm = countMap(_records);
    final first = DateTime(calY, calM + 1, 1);
    final lead = (jsDay(first) - ws + 7) % 7;
    final dim = DateTime(calY, calM + 2, 0).day;
    final cells = <CalCell>[];
    for (var i = 0; i < lead; i++) {
      cells.add(
        const CalCell(
          selectable: false,
          circleBg: Color(0x00000000),
          numColor: Color(0x00000000),
          dotColor: Color(0x00000000),
        ),
      );
    }
    for (var d = 1; d <= dim; d++) {
      final dk = '$calY-${pad2(calM + 1)}-${pad2(d)}';
      final c = cm[dk] ?? 0;
      final isToday = dk == todayKey;
      final isSel = dk == selectedDate;
      cells.add(
        CalCell(
          day: d,
          dateKey: dk,
          selectable: true,
          circleBg: isSel
              ? p.accent
              : (isToday ? p.accentSoft : const Color(0x00000000)),
          numColor: isSel ? p.accentInk : (isToday ? p.accent : p.ink),
          dotColor: c > 0
              ? heatColorFor(c, false, p.heat)
              : const Color(0x00000000),
        ),
      );
    }
    return cells;
  }

  List<RecordEntry> get selRecords =>
      (_records.where((r) => r.date == selectedDate).toList())
        ..sort((a, b) => a.when.compareTo(b.when));

  int get selTotal => selRecords.fold(0, (s, r) => s + r.occ);

  String get selTitle {
    final sd = selectedDate.split('-').map(int.parse).toList();
    final wd = jsDay(DateTime(sd[0], sd[1], sd[2]));
    return '${sd[1]}月${sd[2]}日 周${kDow[wd]}';
  }

  // ===== Actions =====
  void setTab(String tab) {
    activeTab = tab;
    overlay = null;
    notifyListeners();
  }

  void openOverlay(String name) {
    overlay = name;
    notifyListeners();
  }

  void closeOverlay() {
    overlay = null;
    notifyListeners();
  }

  void flash(String text) {
    _toastTimer?.cancel();
    toast = text;
    notifyListeners();
    _toastTimer = Timer(const Duration(milliseconds: 1700), () {
      toast = null;
      notifyListeners();
    });
  }

  String _nowTime() {
    final n = DateTime.now();
    return '${pad2(n.hour)}:${pad2(n.minute)}';
  }

  SheetDraft _blankSheet([String? date]) =>
      SheetDraft(date: date ?? todayKey, time: _nowTime());

  Future<void> oneClick() async {
    final n = DateTime.now();
    final rec = RecordEntry(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      date: todayKey,
      hour: n.hour,
      minute: n.minute,
      count: 1,
      tags: const [],
      mood: 3,
      stress: 3,
      note: '',
    );
    _records = [..._records, rec];
    notifyListeners();
    await _recordRepo.save(rec);
    flash('已记录');
  }

  void openAdd(String date) {
    sheetOpen = true;
    sheetMode = 'add';
    sheet = _blankSheet(date);
    notifyListeners();
  }

  void openEdit(RecordEntry r) {
    sheetOpen = true;
    sheetMode = 'edit';
    sheet = SheetDraft(
      id: r.id,
      date: r.date,
      time: r.timeText,
      count: r.count,
      tags: [...r.tags],
      mood: r.mood,
      stress: r.stress,
      note: r.note,
    );
    notifyListeners();
  }

  void closeSheet() {
    sheetOpen = false;
    notifyListeners();
  }

  void updateSheet(void Function(SheetDraft s) fn) {
    if (sheet == null) return;
    fn(sheet!);
    notifyListeners();
  }

  void toggleSheetTag(String name) {
    final s = sheet;
    if (s == null) return;
    if (s.tags.contains(name)) {
      s.tags = s.tags.where((x) => x != name).toList();
    } else {
      s.tags = [...s.tags, name];
    }
    notifyListeners();
  }

  String get sheetTitle {
    final s = sheet;
    if (sheetMode == 'edit') return '编辑记录';
    return (s?.date == todayKey) ? '新建记录' : '补录记录';
  }

  Future<void> saveSheet() async {
    final s = sheet;
    if (s == null) return;
    final p = s.time.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    final rec = RecordEntry(
      id: s.id ?? 'r${DateTime.now().millisecondsSinceEpoch}',
      date: s.date,
      hour: p.isNotEmpty ? p[0] : 0,
      minute: p.length > 1 ? p[1] : 0,
      count: s.count,
      tags: s.tags,
      mood: s.mood,
      stress: s.stress,
      note: s.note,
    );
    if (sheetMode == 'edit') {
      _records = _records.map((r) => r.id == rec.id ? rec : r).toList();
    } else {
      _records = [..._records, rec];
    }
    sheetOpen = false;
    notifyListeners();
    await _recordRepo.save(rec);
    flash('已记录');
  }

  Future<void> deleteRecord(String? id) async {
    if (id == null) return;
    _records = _records.where((r) => r.id != id).toList();
    notifyListeners();
    await _recordRepo.remove(id);
  }

  Future<void> deleteFromSheet() async {
    final id = sheet?.id;
    sheetOpen = false;
    await deleteRecord(id);
  }

  void shiftMonth(int d) {
    var m = calM + d;
    var y = calY;
    if (m < 0) {
      m = 11;
      y--;
    }
    if (m > 11) {
      m = 0;
      y++;
    }
    calM = m;
    calY = y;
    notifyListeners();
  }

  void selectDate(String dk) {
    selectedDate = dk;
    notifyListeners();
  }

  void setRange(String r) {
    range = r;
    notifyListeners();
  }

  // ---- 设置 ----
  void _persistSettings() => _settingsRepo.saveSettings(_settings);

  void setTheme(ThemeKey t) {
    _settings = _settings.copyWith(theme: t);
    _persistSettings();
    notifyListeners();
  }

  void setAccent(AccentKey a) {
    _settings = _settings.copyWith(accent: a);
    _persistSettings();
    notifyListeners();
  }

  void toggleSetting(String key) {
    _settings = switch (key) {
      'appLock' => _settings.copyWith(appLock: !_settings.appLock),
      'biometric' => _settings.copyWith(biometric: !_settings.biometric),
      'disguise' => _settings.copyWith(disguise: !_settings.disguise),
      'blurNotif' => _settings.copyWith(blurNotif: !_settings.blurNotif),
      _ => _settings,
    };
    _persistSettings();
    notifyListeners();
  }

  // ---- 目标 ----
  void _persistGoals() => _settingsRepo.saveGoals(_goals);

  void toggleGoal(String key) {
    _goals = switch (key) {
      'enabled' => _goals.copyWith(enabled: !_goals.enabled),
      'gapEnabled' => _goals.copyWith(gapEnabled: !_goals.gapEnabled),
      'avoidEnabled' => _goals.copyWith(avoidEnabled: !_goals.avoidEnabled),
      _ => _goals,
    };
    _persistGoals();
    notifyListeners();
  }

  void setGoalValue(String key, int value) {
    _goals = switch (key) {
      'weekMax' => _goals.copyWith(weekMax: value),
      'monthMax' => _goals.copyWith(monthMax: value),
      'minGap' => _goals.copyWith(minGap: value),
      _ => _goals,
    };
    _persistGoals();
    notifyListeners();
  }

  // ---- 标签 ----
  void setNewTag(String v) {
    newTag = v;
  }

  void addTag() {
    final v = newTag.trim();
    if (v.isEmpty || _tags.contains(v)) {
      newTag = '';
      notifyListeners();
      return;
    }
    _tags = [..._tags, v];
    newTag = '';
    _settingsRepo.saveTags(_tags);
    notifyListeners();
  }

  void delTag(String name) {
    _tags = _tags.where((t) => t != name).toList();
    _settingsRepo.saveTags(_tags);
    notifyListeners();
  }

  // ---- 锁屏 ----
  bool get hasPin => _pinIsSet;

  void lockNow() {
    if (!_pinIsSet) {
      flash('请先在设置里开启 App 锁并设置密码');
      return;
    }
    locked = true;
    lockInput = '';
    lockError = false;
    notifyListeners();
  }

  /// 设置/修改 PIN（成功后标记已设并持久化）。
  Future<void> setPin(String pin) async {
    await _settingsRepo.setPin(pin);
    _pinIsSet = true;
    notifyListeners();
  }

  /// 生物识别解锁：仅当开启且设备支持且系统校验通过才解锁。
  Future<void> tryBiometricUnlock() async {
    if (!_settings.biometric) return;
    final ok = await _auth.authenticate('解锁 $appName');
    if (ok) {
      locked = false;
      lockInput = '';
      lockError = false;
      notifyListeners();
    }
  }

  Future<void> pressDigit(String n) async {
    if (lockError) lockError = false;
    final v = lockInput + n;
    if (v.length < 6) {
      lockInput = v;
      notifyListeners();
      return;
    }
    // 满 6 位 → 校验
    final ok = await _settingsRepo.verifyPin(v);
    if (ok) {
      locked = false;
      lockInput = '';
      lockError = false;
    } else {
      lockInput = '';
      lockError = true;
    }
    notifyListeners();
  }

  void backspaceDigit() {
    if (lockInput.isNotEmpty) {
      lockInput = lockInput.substring(0, lockInput.length - 1);
      lockError = false;
      notifyListeners();
    }
  }

  /// 开启生物识别前先检查设备是否支持；不支持则提示且不开启。
  Future<void> toggleBiometric() async {
    if (!_settings.biometric) {
      final available = await _auth.isBiometricAvailable();
      if (!available) {
        flash('此设备不支持生物识别');
        return;
      }
    }
    _settings = _settings.copyWith(biometric: !_settings.biometric);
    _persistSettings();
    notifyListeners();
  }

  /// 关闭 App 锁：清除已存 PIN。
  Future<void> disableAppLock() async {
    _settings = _settings.copyWith(appLock: false);
    _persistSettings();
    await _settingsRepo.clearPin();
    _pinIsSet = false;
    notifyListeners();
  }

  /// 开启 App 锁（在 UI 完成设密码后调用）。
  void enableAppLock() {
    _settings = _settings.copyWith(appLock: true);
    _persistSettings();
    notifyListeners();
  }

  // ---- 数据 ----
  Future<void> clearData() async {
    _records = [];
    notifyListeners();
    await _recordRepo.clear();
    flash('已清空全部数据');
  }

  String _fileStamp() {
    final n = DateTime.now();
    return '${n.year}${pad2(n.month)}${pad2(n.day)}-${pad2(n.hour)}${pad2(n.minute)}';
  }

  String currentBackupJson() => BackupService.buildBackupJson(
    records: _records,
    settings: _settings,
    goals: _goals,
    tags: _tags,
  );

  Future<void> exportCsv() async {
    try {
      final csv = BackupService.recordsToCsv(_records);
      final result = await _share.deliverTextFile(
        'daolema-records-${_fileStamp()}.csv',
        csv,
        subject: '导了吗 · 记录导出',
      );
      if (result == FileDeliveryResult.cancelled) return;
      flash(result == FileDeliveryResult.saved ? '已保存 CSV' : '已导出 CSV');
    } catch (_) {
      flash('导出失败');
    }
  }

  Future<void> exportJson() async {
    try {
      final result = await _share.deliverTextFile(
        'daolema-backup-${_fileStamp()}.json',
        currentBackupJson(),
        subject: '导了吗 · 数据备份',
      );
      if (result == FileDeliveryResult.cancelled) return;
      flash(result == FileDeliveryResult.saved ? '已保存 JSON' : '已导出 JSON');
    } catch (_) {
      flash('导出失败');
    }
  }

  /// 用口令创建加密备份并分享。
  Future<void> createEncryptedBackup(String passphrase) async {
    try {
      final enc = await BackupService.encryptBackup(
        currentBackupJson(),
        passphrase,
      );
      final result = await _share.deliverTextFile(
        'daolema-encrypted-${_fileStamp()}.json',
        enc,
        subject: '导了吗 · 加密备份',
      );
      if (result == FileDeliveryResult.cancelled) return;
      flash(result == FileDeliveryResult.saved ? '已保存加密备份' : '已创建加密备份');
    } catch (_) {
      flash('备份失败');
    }
  }

  /// 选择导入文件（供设置页编排使用）。
  Future<PickedFile?> pickImportFile() => _filePick.pickImportFile();

  /// 应用导入的记录：overwrite=覆盖（清空后写入），否则按 id 合并。
  Future<void> applyImportedRecords(
    List<RecordEntry> recs, {
    required bool overwrite,
  }) async {
    if (overwrite) {
      _records = recs;
      notifyListeners();
      await _recordRepo.clear();
      await _recordRepo.saveAll(recs);
    } else {
      final map = {for (final r in _records) r.id: r};
      for (final r in recs) {
        map[r.id] = r;
      }
      _records = map.values.toList();
      notifyListeners();
      await _recordRepo.saveAll(recs);
    }
    flash(overwrite ? '已覆盖导入 ${recs.length} 条' : '已合并导入 ${recs.length} 条');
  }

  void restoreSettings(AppSettings s) {
    _settings = s;
    _persistSettings();
    notifyListeners();
  }

  void restoreGoals(Goals g) {
    _goals = g;
    _persistGoals();
    notifyListeners();
  }

  void restoreTags(List<String> t) {
    _tags = t;
    _settingsRepo.saveTags(t);
    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
