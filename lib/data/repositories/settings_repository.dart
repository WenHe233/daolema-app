import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

/// 设置/目标/自定义标签存 shared_preferences；锁屏 PIN 存加密存储。
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _kSettings = 'settings';
  static const _kGoals = 'goals';
  static const _kTags = 'tags';
  static const _kPin = 'lock_pin';

  AppSettings loadSettings() {
    final s = _prefs.getString(_kSettings);
    if (s == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings s) =>
      _prefs.setString(_kSettings, jsonEncode(s.toJson()));

  Goals loadGoals() {
    final s = _prefs.getString(_kGoals);
    if (s == null) return const Goals();
    return Goals.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }

  Future<void> saveGoals(Goals g) =>
      _prefs.setString(_kGoals, jsonEncode(g.toJson()));

  List<String> loadTags() => _prefs.getStringList(_kTags) ?? List.of(kDefaultTags);

  Future<void> saveTags(List<String> tags) => _prefs.setStringList(_kTags, tags);

  Future<String?> getPin() => _secure.read(key: _kPin);

  Future<void> setPin(String pin) => _secure.write(key: _kPin, value: pin);
}
