import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 把文本写到临时文件并调系统分享面板（导出 CSV/JSON、加密备份共用）。
class ShareService {
  Future<void> shareTextFile(String filename, String content, {String? subject}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }
}
