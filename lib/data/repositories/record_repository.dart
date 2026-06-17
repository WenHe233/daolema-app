import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/record_entry.dart';

/// records 的读写入口，负责 drift 行 [Record] 与领域模型 [RecordEntry] 互转。
class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  RecordEntry _toEntry(Record r) => RecordEntry(
        id: r.id,
        date: r.date,
        hour: r.hour,
        minute: r.minute,
        count: r.count,
        tags: r.tags,
        mood: r.mood,
        stress: r.stress,
        note: r.note,
      );

  RecordsCompanion _toCompanion(RecordEntry e) => RecordsCompanion.insert(
        id: e.id,
        date: e.date,
        hour: e.hour,
        minute: e.minute,
        count: Value(e.count),
        tags: e.tags,
        mood: Value(e.mood),
        stress: Value(e.stress),
        note: Value(e.note),
      );

  Future<List<RecordEntry>> getAll() async =>
      (await _db.allRecords()).map(_toEntry).toList();

  Future<bool> isEmpty() async => (await _db.recordCount()) == 0;

  Future<void> save(RecordEntry e) => _db.upsertRecord(_toCompanion(e));

  Future<void> saveAll(List<RecordEntry> entries) =>
      _db.insertAll(entries.map(_toCompanion).toList());

  Future<void> remove(String id) => _db.deleteRecord(id);

  Future<void> clear() => _db.clearRecords();
}
