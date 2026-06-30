import 'dart:convert';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:cryptography/cryptography.dart';

import 'models/app_models.dart';
import 'models/record_entry.dart';

/// 导出/导入/加密 的纯逻辑（不依赖平台插件，可单测）。
class BackupService {
  BackupService._();

  static const _csvHeader = ['id', 'date', 'time', 'count', 'tags', 'mood', 'stress', 'note'];

  // ---------- CSV（仅记录）----------
  static String recordsToCsv(List<RecordEntry> records) {
    final rows = <List<dynamic>>[
      _csvHeader,
      for (final r in records)
        [r.id, r.date, r.timeText, r.count, r.tags.join('|'), r.mood, r.stress, r.note],
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static List<RecordEntry> recordsFromCsv(String csv) {
    final normalized = csv.replaceAll('\r\n', '\n');
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(normalized)
        .where((r) => r.isNotEmpty && r.any((c) => '$c'.trim().isNotEmpty))
        .toList();
    if (rows.isEmpty) return [];

    // 定位列（容忍缺表头：默认按固定顺序）。
    final header = rows.first.map((e) => '$e'.trim().toLowerCase()).toList();
    final hasHeader = header.contains('date') && header.contains('time');
    int idx(String name, int fallback) {
      final i = header.indexOf(name);
      return hasHeader && i >= 0 ? i : fallback;
    }

    final ii = idx('id', 0),
        di = idx('date', 1),
        ti = idx('time', 2),
        ci = idx('count', 3),
        gi = idx('tags', 4),
        mi = idx('mood', 5),
        si = idx('stress', 6),
        ni = idx('note', 7);

    String cell(List<dynamic> row, int i) => i < row.length ? '${row[i]}' : '';
    int asInt(String s, int dflt) => int.tryParse(s.trim()) ?? dflt;

    final out = <RecordEntry>[];
    for (final row in rows.skip(hasHeader ? 1 : 0)) {
      final date = cell(row, di).trim();
      if (date.isEmpty) continue;
      final time = cell(row, ti).trim();
      final tp = time.split(':');
      final tags = cell(row, gi)
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final id = cell(row, ii).trim();
      out.add(RecordEntry(
        id: id.isEmpty ? 'r${DateTime.now().microsecondsSinceEpoch}_${out.length}' : id,
        date: date,
        hour: tp.isNotEmpty ? asInt(tp[0], 0) : 0,
        minute: tp.length > 1 ? asInt(tp[1], 0) : 0,
        count: asInt(cell(row, ci), 1),
        tags: tags,
        mood: asInt(cell(row, mi), 3),
        stress: asInt(cell(row, si), 3),
        note: cell(row, ni),
      ));
    }
    return out;
  }

  // ---------- JSON 完整备份（记录 + 设置 + 目标 + 标签）----------
  static String buildBackupJson({
    required List<RecordEntry> records,
    required AppSettings settings,
    required Goals goals,
    required List<String> tags,
  }) {
    final map = {
      'version': 1,
      'app': 'daolema',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'goals': goals.toJson(),
      'tags': tags,
      'records': records.map((r) => r.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static BackupParseResult parseBackupJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    // 兼容裸记录数组与完整备份对象两种。
    final recsRaw = decoded is Map ? decoded['records'] : decoded;
    if (recsRaw is! List) {
      throw const FormatException('JSON 中未找到记录数组');
    }
    final records = recsRaw
        .map((e) => RecordEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    AppSettings? settings;
    Goals? goals;
    List<String>? tags;
    if (decoded is Map) {
      if (decoded['settings'] is Map) {
        settings = AppSettings.fromJson(Map<String, dynamic>.from(decoded['settings'] as Map));
      }
      if (decoded['goals'] is Map) {
        goals = Goals.fromJson(Map<String, dynamic>.from(decoded['goals'] as Map));
      }
      if (decoded['tags'] is List) {
        tags = (decoded['tags'] as List).map((e) => '$e').toList();
      }
    }
    return BackupParseResult(records: records, settings: settings, goals: goals, tags: tags);
  }

  // ---------- 加密备份（AES-GCM + PBKDF2-HMAC-SHA256）----------
  static const int _kdfIterations = 100000;

  static List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  static Future<SecretKey> _deriveKey(String passphrase, List<int> salt, int iterations) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  /// 用口令加密明文（通常是 [buildBackupJson] 的结果），返回信封 JSON 文本。
  static Future<String> encryptBackup(String plaintext, String passphrase) async {
    final salt = _randomBytes(16);
    final key = await _deriveKey(passphrase, salt, _kdfIterations);
    final algo = AesGcm.with256bits();
    final nonce = algo.newNonce();
    final box = await algo.encrypt(utf8.encode(plaintext), secretKey: key, nonce: nonce);
    final envelope = {
      'v': 1,
      'app': 'daolema',
      'kdf': 'pbkdf2-sha256',
      'iter': _kdfIterations,
      'salt': base64.encode(salt),
      'nonce': base64.encode(nonce),
      'ct': base64.encode(box.cipherText),
      'mac': base64.encode(box.mac.bytes),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// 是否为加密备份信封。
  static bool isEncryptedEnvelope(String text) {
    try {
      final m = jsonDecode(text);
      return m is Map && m['kdf'] == 'pbkdf2-sha256' && m['ct'] != null;
    } catch (_) {
      return false;
    }
  }

  /// 用口令解密信封，返回明文（口令错或数据损坏将抛异常）。
  static Future<String> decryptBackup(String envelopeJson, String passphrase) async {
    final m = jsonDecode(envelopeJson) as Map;
    final salt = base64.decode(m['salt'] as String);
    final iterations = (m['iter'] as num?)?.toInt() ?? _kdfIterations;
    final key = await _deriveKey(passphrase, salt, iterations);
    final algo = AesGcm.with256bits();
    final box = SecretBox(
      base64.decode(m['ct'] as String),
      nonce: base64.decode(m['nonce'] as String),
      mac: Mac(base64.decode(m['mac'] as String)),
    );
    final clear = await algo.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }
}

/// JSON 备份解析结果（records 必有，其余可选）。
class BackupParseResult {
  const BackupParseResult({
    required this.records,
    this.settings,
    this.goals,
    this.tags,
  });
  final List<RecordEntry> records;
  final AppSettings? settings;
  final Goals? goals;
  final List<String>? tags;
}
