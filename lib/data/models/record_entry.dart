/// 一条记录的领域模型（与持久化层解耦）。
///
/// 字段对应源原型里 records 的结构：date('YYYY-MM-DD')、hour、minute、count、
/// tags、mood(1-5)、stress(1-5)、note。
class RecordEntry {
  const RecordEntry({
    required this.id,
    required this.date,
    required this.hour,
    required this.minute,
    this.count = 1,
    this.tags = const [],
    required this.mood,
    required this.stress,
    this.note = '',
  });

  final String id;
  final String date; // YYYY-MM-DD
  final int hour;
  final int minute;
  final int count;
  final List<String> tags;
  final int mood;
  final int stress;
  final String note;

  /// 单条记录计入的次数（源原型 `occ`：count 为空时按 1 计）。
  int get occ => count <= 0 ? 1 : count;

  /// 记录发生的精确时间（源原型 `recDate`）。
  DateTime get when {
    final p = date.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2], hour, minute);
  }

  String get timeText =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  RecordEntry copyWith({
    String? id,
    String? date,
    int? hour,
    int? minute,
    int? count,
    List<String>? tags,
    int? mood,
    int? stress,
    String? note,
  }) {
    return RecordEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      count: count ?? this.count,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      stress: stress ?? this.stress,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'hour': hour,
        'minute': minute,
        'count': count,
        'tags': tags,
        'mood': mood,
        'stress': stress,
        'note': note,
      };

  factory RecordEntry.fromJson(Map<String, dynamic> j) => RecordEntry(
        id: j['id'] as String,
        date: j['date'] as String,
        hour: (j['hour'] as num).toInt(),
        minute: (j['minute'] as num).toInt(),
        count: (j['count'] as num?)?.toInt() ?? 1,
        tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        mood: (j['mood'] as num).toInt(),
        stress: (j['stress'] as num).toInt(),
        note: (j['note'] as String?) ?? '',
      );
}
