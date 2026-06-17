import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// 把 tags（`List<String>`）以 JSON 文本存进 SQLite。
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
    return const [];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// 记录表。`date` 用 'YYYY-MM-DD' 文本，便于按月/年前缀匹配（同源原型）。
class Records extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get tags => text().map(const TagsConverter())();
  IntColumn get mood => integer().withDefault(const Constant(3))();
  IntColumn get stress => integer().withDefault(const Constant(3))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Records])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(name: 'daolema');

  Future<List<Record>> allRecords() => select(records).get();

  Stream<List<Record>> watchRecords() => select(records).watch();

  Future<int> recordCount() async {
    final c = countAll();
    final q = selectOnly(records)..addColumns([c]);
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> upsertRecord(RecordsCompanion entry) =>
      into(records).insertOnConflictUpdate(entry);

  Future<void> insertAll(List<RecordsCompanion> entries) async {
    await batch((b) => b.insertAll(records, entries));
  }

  Future<void> deleteRecord(String id) =>
      (delete(records)..where((t) => t.id.equals(id))).go();

  Future<void> clearRecords() => delete(records).go();
}
