import 'package:file_selector/file_selector.dart';

/// 选中的导入文件（名称 + 文本内容）。
class PickedFile {
  const PickedFile(this.name, this.content);
  final String name;
  final String content;
}

/// 选择导入文件并读取为文本（json / csv / 加密备份 envelope）。
class FilePickService {
  Future<PickedFile?> pickImportFile() async {
    const group = XTypeGroup(
      label: '数据 / 备份',
      extensions: ['json', 'csv', 'txt'],
      mimeTypes: ['application/json', 'text/csv', 'text/plain'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null) return null;
    final content = await file.readAsString();
    return PickedFile(file.name, content);
  }
}
