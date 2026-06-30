import 'package:daolema/data/share_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('文件交付', () {
    test('Linux 保存成功时返回 saved 并传递内容', () async {
      String? savedName;
      String? savedContent;
      final service = ShareService(
        saveLocally: true,
        saveTextFile: (filename, content) async {
          savedName = filename;
          savedContent = content;
          return true;
        },
      );

      final result = await service.deliverTextFile(
        'backup.json',
        '{"ok":true}',
      );

      expect(result, FileDeliveryResult.saved);
      expect(savedName, 'backup.json');
      expect(savedContent, '{"ok":true}');
    });

    test('取消 Linux 保存时返回 cancelled', () async {
      final service = ShareService(
        saveLocally: true,
        saveTextFile: (_, _) async => false,
      );

      final result = await service.deliverTextFile('records.csv', 'id,date');

      expect(result, FileDeliveryResult.cancelled);
    });

    test('保存异常继续抛给上层处理', () async {
      final service = ShareService(
        saveLocally: true,
        saveTextFile: (_, _) => Future<bool>.error(StateError('write failed')),
      );

      expect(
        () => service.deliverTextFile('backup.json', '{}'),
        throwsStateError,
      );
    });

    test('非 Linux 平台仍使用分享流程', () async {
      String? sharedSubject;
      final service = ShareService(
        saveLocally: false,
        shareTextFile: (filename, content, subject) async {
          expect(filename, 'records.csv');
          expect(content, 'id,date');
          sharedSubject = subject;
        },
      );

      final result = await service.deliverTextFile(
        'records.csv',
        'id,date',
        subject: '记录导出',
      );

      expect(result, FileDeliveryResult.shared);
      expect(sharedSubject, '记录导出');
    });
  });
}
