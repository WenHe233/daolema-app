import 'package:daolema/data/models/record_entry.dart';
import 'package:daolema/util/stats.dart';
import 'package:flutter_test/flutter_test.dart';

RecordEntry _rec(String date, int count, {int hour = 10, int minute = 0}) {
  return RecordEntry(
    id: '$date-$hour-$minute-$count',
    date: date,
    hour: hour,
    minute: minute,
    count: count,
    mood: 3,
    stress: 3,
  );
}

void main() {
  final today = DateTime(2026, 7, 1);

  group('computeStats 日均分母保底', () {
    test('新用户：使用天数短于周期时，分母收紧为实际天数', () {
      final records = [
        _rec('2026-06-29', 1),
        _rec('2026-06-30', 2),
        _rec('2026-07-01', 1),
      ];
      final stats = computeStats(records, today, '7', false);

      expect(stats.avgDaily, '1.3'); // 4 次 / 3 天，而不是 4 / 7
      expect(stats.trend.length, 3);
      expect(stats.trendStart, '3天前');
    });

    test('老用户：使用时间足够长时，行为与固定周期一致', () {
      final records = [
        _rec('2025-01-01', 1), // 很早之前的记录，不应影响起点
        _rec('2026-06-25', 1),
        _rec('2026-06-28', 2),
        _rec('2026-07-01', 1),
      ];
      final stats = computeStats(records, today, '7', false);

      expect(stats.avgDaily, '0.6'); // (1+2+1) / 7
      expect(stats.trend.length, 7);
      expect(stats.trendStart, '7天前');
    });

    test('无记录：日均为 0.0 且不抛异常', () {
      final stats = computeStats(const [], today, '30', false);

      expect(stats.avgDaily, '0.0');
      expect(stats.trend.length, 30);
    });

    test('今年：首条记录在去年，起点仍为 1 月 1 日', () {
      final records = [
        _rec('2025-12-01', 1),
        _rec('2026-03-01', 1),
      ];
      final stats = computeStats(records, today, 'year', false);

      expect(stats.trendStart, '1月');
    });

    test('今年：首条记录在今年年中，起点收紧为该月份', () {
      final records = [
        _rec('2026-06-25', 7),
        _rec('2026-07-01', 7),
      ];
      final stats = computeStats(records, today, 'year', false);

      expect(stats.trendStart, '6月');
      expect(stats.avgDaily, '2.0'); // 14 次 / 7 天（6-25 到 7-01）
    });
  });
}
