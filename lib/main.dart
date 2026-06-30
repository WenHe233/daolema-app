import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/db/database.dart';
import 'data/repositories/record_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/seed/seed_data.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);

  final db = AppDatabase();
  final recordRepo = RecordRepository(db);

  // 仅调试构建：首次启动且数据库为空时写入约一年的演示数据（方便预览图表）。
  // 正式（release）构建不写入，真实用户从空开始。
  if (kDebugMode && await recordRepo.isEmpty()) {
    await recordRepo.saveAll(generateSeed(DateTime.now()));
  }

  final controller = AppController(
    recordRepo: recordRepo,
    settingsRepo: settingsRepo,
    records: await recordRepo.getAll(),
    settings: settingsRepo.loadSettings(),
    goals: settingsRepo.loadGoals(),
    tags: settingsRepo.loadTags(),
    pinIsSet: await settingsRepo.hasPin(),
  );

  runApp(
    ChangeNotifierProvider<AppController>.value(
      value: controller,
      child: const DaolemaApp(),
    ),
  );
}
