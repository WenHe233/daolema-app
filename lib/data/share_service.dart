import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum FileDeliveryResult { shared, saved, cancelled }

typedef SaveTextFile = Future<bool> Function(String filename, String content);
typedef ShareTextFile =
    Future<void> Function(String filename, String content, String? subject);

/// 把导出文本交给用户：Linux 使用保存对话框，其余平台使用系统分享面板。
class ShareService {
  ShareService({
    bool? saveLocally,
    SaveTextFile? saveTextFile,
    ShareTextFile? shareTextFile,
  }) : _saveLocally = saveLocally ?? Platform.isLinux,
       _saveTextFile = saveTextFile,
       _shareTextFile = shareTextFile;

  final bool _saveLocally;
  final SaveTextFile? _saveTextFile;
  final ShareTextFile? _shareTextFile;

  Future<FileDeliveryResult> deliverTextFile(
    String filename,
    String content, {
    String? subject,
  }) async {
    if (_saveLocally) {
      final saved = await (_saveTextFile ?? _saveWithDialog)(filename, content);
      return saved ? FileDeliveryResult.saved : FileDeliveryResult.cancelled;
    }
    await (_shareTextFile ?? _shareWithSystem)(filename, content, subject);
    return FileDeliveryResult.shared;
  }

  Future<bool> _saveWithDialog(String filename, String content) async {
    final extension = filename.contains('.') ? filename.split('.').last : '';
    final location = await getSaveLocation(
      suggestedName: filename,
      acceptedTypeGroups: [
        if (extension.isNotEmpty)
          XTypeGroup(label: '数据文件', extensions: [extension]),
      ],
    );
    if (location == null) return false;
    await File(location.path).writeAsString(content);
    return true;
  }

  Future<void> _shareWithSystem(
    String filename,
    String content,
    String? subject,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }
}
