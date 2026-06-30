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

  // 首次启动且数据库为空时，写入约一年的演示记录（本地优先）。
  if (await recordRepo.isEmpty()) {
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
