import 'dart:ui';

import 'package:daolema/data/seed/seed_data.dart';
import 'package:daolema/theme/palette.dart';
import 'package:daolema/util/dates.dart';
import 'package:daolema/util/stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedToday = DateTime(2026, 6, 17);

  group('mulberry32 演示数据', () {
    test('同一日期生成结果确定（可复现）', () {
      final a = generateSeed(fixedToday);
      final b = generateSeed(fixedToday);
      expect(a.length, b.length);
      expect(a.first.id, b.first.id);
      expect(a.first.date, b.first.date);
      expect(a.length, greaterThan(100)); // 约一年的记录
    });

    test('所有记录都不晚于今天', () {
      final recs = generateSeed(fixedToday);
      for (final r in recs) {
        expect(midnight(r.when).isAfter(fixedToday), isFalse);
      }
    });
  });

  group('日期工具', () {
    test('dateKey 格式 YYYY-MM-DD', () {
      expect(dateKey(DateTime(2026, 6, 7)), '2026-06-07');
    });

    test('startOfWeek 周一起始', () {
      // 2026-06-17 是周三，周一起始应回到 2026-06-15
      final mon = startOfWeek(fixedToday, true);
      expect(dateKey(mon), '2026-06-15');
    });

    test('startOfWeek 周日起始', () {
      final sun = startOfWeek(fixedToday, false);
      expect(dateKey(sun), '2026-06-14');
    });
  });

  group('统计', () {
    test('趋势长度等于区间天数', () {
      final recs = generateSeed(fixedToday);
      final s7 = computeStats(recs, fixedToday, '7', true);
      expect(s7.trend.length, 7);
      final s30 = computeStats(recs, fixedToday, '30', true);
      expect(s30.trend.length, 30);
    });

    test('趋势日期与趋势一一对应，末项为今天', () {
      final recs = generateSeed(fixedToday);
      final s = computeStats(recs, fixedToday, '30', true);
      expect(s.trendDates.length, s.trend.length);
      expect(dateKey(s.trendDates.last), dateKey(fixedToday));
    });

    test('星期分布 7 条、时间段分布 6 条', () {
      final recs = generateSeed(fixedToday);
      final s = computeStats(recs, fixedToday, '30', true);
      expect(s.weekdayBars.length, 7);
      expect(s.todBars.length, 6);
    });

    test('标签排行最多 7 条', () {
      final recs = generateSeed(fixedToday);
      final s = computeStats(recs, fixedToday, 'year', true);
      expect(s.tagRank.length, lessThanOrEqualTo(7));
    });
  });

  group('热力图', () {
    test('53 列，每列 7 格', () {
      final recs = generateSeed(fixedToday);
      final h = buildHeat(countMap(recs), fixedToday, true,
          AppPalette.resolve(ThemeKey.light, AccentKey.green).heat);
      expect(h.weeks.length, 53);
      expect(h.weeks.every((w) => w.length == 7), isTrue);
    });
  });

  group('调色板', () {
    test('森绿深色 accent', () {
      final p = AppPalette.resolve(ThemeKey.dark, AccentKey.green);
      expect(p.accent, const Color(0xFF46B87F));
      expect(p.isDark, isTrue);
    });

    test('墨蓝浅色 accent 与主题底色组合', () {
      final p = AppPalette.resolve(ThemeKey.light, AccentKey.blue);
      expect(p.accent, const Color(0xFF2F6BBD));
      expect(p.bg, const Color(0xFFF1ECE3));
    });
  });
}
