import '../models/record_entry.dart';
import '../../util/dates.dart';

int _u32(int x) => x & 0xFFFFFFFF;

/// 32 位整数乘法（等价 JS `Math.imul`，只保留低 32 位）。
int _imul(int a, int b) {
  a = _u32(a);
  b = _u32(b);
  final ah = a >>> 16;
  final al = a & 0xFFFF;
  final bh = b >>> 16;
  final bl = b & 0xFFFF;
  return _u32(al * bl + ((_u32(ah * bl + al * bh) << 16)));
}

/// mulberry32 种子随机数（与源原型逐位等价），返回 [0,1) 的浮点。
double Function() _mulberry32(int seed) {
  var a = _u32(seed);
  return () {
    a = _u32(a + 0x6D2B79F5);
    var t = _imul(_u32(a ^ (a >>> 15)), _u32(1 | a));
    t = _u32(_u32(t + _imul(_u32(t ^ (t >>> 7)), _u32(61 | t))) ^ t);
    return _u32(t ^ (t >>> 14)) / 4294967296.0;
  };
}

/// 生成约一年（366 天）的演示记录，逻辑逐行移植自源原型 `Component.generate`。
/// 同一种子下结果确定，仅在首次启动且数据库为空时写入。
List<RecordEntry> generateSeed(DateTime today) {
  final t0 = midnight(today);
  final rnd = _mulberry32(20240617);
  final recs = <RecordEntry>[];
  var id = 1;
  const hours = [7, 9, 12, 13, 14, 16, 18, 21, 22, 23, 23, 0, 1];

  for (var i = 365; i >= 0; i--) {
    final d = t0.subtract(Duration(days: i));
    final dow = jsDay(d);
    final p = 0.5 + ((dow == 0 || dow == 6) ? 0.18 : 0);
    var count = 0;
    if (rnd() < p) {
      final q = rnd();
      count = q < 0.74 ? 1 : (q < 0.93 ? 2 : 3);
    }
    for (var c = 0; c < count; c++) {
      final hour = hours[(rnd() * hours.length).floor()];
      final minute = (rnd() * 60).floor();
      final tg = <String>[];
      if (hour >= 21 || hour <= 1) {
        if (rnd() < 0.6) tg.add('睡前');
        if (rnd() < 0.3) tg.add('助眠');
        if (rnd() < 0.25) tg.add('熬夜');
      } else {
        const pool = ['压力大', '无聊', '放松', '冲动'];
        if (rnd() < 0.7) tg.add(pool[(rnd() * pool.length).floor()]);
        if (rnd() < 0.2) tg.add(pool[(rnd() * pool.length).floor()]);
      }
      recs.add(RecordEntry(
        id: 'g${id++}',
        date: dateKey(d),
        hour: hour,
        minute: minute,
        count: 1,
        tags: tg.toSet().toList(),
        mood: 1 + (rnd() * 5).floor(),
        stress: 1 + (rnd() * 5).floor(),
        note: '',
      ));
    }
  }
  return recs;
}
