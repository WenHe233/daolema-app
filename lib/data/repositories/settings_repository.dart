import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/pin_crypto.dart' as pinc;
import '../models/app_models.dart';

/// 设置/目标/自定义标签存 shared_preferences；锁屏 PIN 存加密存储。
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _kSettings = 'settings';
  static const _kGoals = 'goals';
  static const _kTags = 'tags';
  static const _kPinHash = 'lock_pin_hash';
  static const _kPinSalt = 'lock_pin_salt';

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

  /// 是否已设置锁屏 PIN。
  Future<bool> hasPin() async => (await _secure.read(key: _kPinHash)) != null;

  /// 设置/修改 PIN（只存盐 + sha256 哈希，PIN 本身不落盘）。
  Future<void> setPin(String pin) async {
    final h = pinc.hashPin(pin);
    await _secure.write(key: _kPinSalt, value: h.salt);
    await _secure.write(key: _kPinHash, value: h.hash);
  }

  /// 校验 PIN。未设置时返回 false。
  Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(key: _kPinSalt);
    final hash = await _secure.read(key: _kPinHash);
    if (salt == null || hash == null) return false;
    return pinc.verifyPin(pin, salt, hash);
  }

  Future<void> clearPin() async {
    await _secure.delete(key: _kPinSalt);
    await _secure.delete(key: _kPinHash);
  }
}
