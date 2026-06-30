import 'package:daolema/data/backup_service.dart';
import 'package:daolema/data/models/app_models.dart';
import 'package:daolema/data/models/record_entry.dart';
import 'package:daolema/theme/palette.dart';
import 'package:daolema/util/pin_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = <RecordEntry>[
    const RecordEntry(
      id: 'a1',
      date: '2026-06-17',
      hour: 23,
      minute: 5,
      count: 2,
      tags: ['睡前', '助眠'],
      mood: 4,
      stress: 2,
      note: '含,逗号与"引号',
    ),
    const RecordEntry(
      id: 'a2',
      date: '2026-06-18',
      hour: 9,
      minute: 30,
      count: 1,
      tags: [],
      mood: 3,
      stress: 3,
      note: '',
    ),
  ];

  group('CSV 往返', () {
    test('导出再导入记录一致', () {
      final csv = BackupService.recordsToCsv(sample);
      final back = BackupService.recordsFromCsv(csv);
      expect(back.length, sample.length);
      expect(back[0].id, 'a1');
      expect(back[0].date, '2026-06-17');
      expect(back[0].hour, 23);
      expect(back[0].minute, 5);
      expect(back[0].count, 2);
      expect(back[0].tags, ['睡前', '助眠']);
      expect(back[0].note, '含,逗号与"引号'); // 逗号/引号转义正确
      expect(back[1].tags, isEmpty);
    });
  });

  group('JSON 备份往返', () {
    test('build 再 parse 保留记录与设置/目标/标签', () {
      final json = BackupService.buildBackupJson(
        records: sample,
        settings: const AppSettings(theme: ThemeKey.dark, accent: AccentKey.blue, disguise: true),
        goals: const Goals(weekMax: 7, monthMax: 25),
        tags: const ['睡前', '熬夜'],
      );
      final r = BackupService.parseBackupJson(json);
      expect(r.records.length, 2);
      expect(r.settings?.theme, ThemeKey.dark);
      expect(r.settings?.accent, AccentKey.blue);
      expect(r.settings?.disguise, isTrue);
      expect(r.goals?.weekMax, 7);
      expect(r.tags, ['睡前', '熬夜']);
    });

    test('裸记录数组也能解析', () {
      const bare = '[{"id":"x","date":"2026-01-01","hour":1,"minute":2,"count":1,'
          '"tags":["放松"],"mood":3,"stress":3,"note":""}]';
      final r = BackupService.parseBackupJson(bare);
      expect(r.records.single.id, 'x');
      expect(r.settings, isNull);
    });
  });

  group('加密备份往返', () {
    test('正确口令可解密还原', () async {
      const plain = '{"hello":"世界"}';
      final env = await BackupService.encryptBackup(plain, 'pass-1234');
      expect(BackupService.isEncryptedEnvelope(env), isTrue);
      final back = await BackupService.decryptBackup(env, 'pass-1234');
      expect(back, plain);
    });

    test('错误口令解密抛异常', () async {
      final env = await BackupService.encryptBackup('{"a":1}', 'right');
      expect(() => BackupService.decryptBackup(env, 'wrong'), throwsA(anything));
    });
  });

  group('PIN 加盐哈希', () {
    test('同盐校验通过、错码不通过', () {
      final h = hashPin('135790');
      expect(verifyPin('135790', h.salt, h.hash), isTrue);
      expect(verifyPin('000000', h.salt, h.hash), isFalse);
    });

    test('随机盐使同 PIN 哈希不同', () {
      final a = hashPin('111111');
      final b = hashPin('111111');
      expect(a.salt == b.salt, isFalse);
      expect(a.hash == b.hash, isFalse);
    });
  });
}
