import 'dart:math' as math;
import 'dart:ui';

import '../data/models/record_entry.dart';
import 'dates.dart';

/// 星期（JS getDay 顺序：0=日 … 6=六）。
const List<String> kDow = ['日', '一', '二', '三', '四', '五', '六'];

/// 时间段标签（源原型 TOD）。
const List<String> kTod = ['凌晨', '清晨', '上午', '下午', '傍晚', '夜晚'];

/// 次数 → 热力图色阶索引（源原型 `heatColor`，heat 长度 5，单元格用 0..3）。
Color heatColorFor(int count, bool future, List<Color> heat) {
  if (future) return const Color(0x00000000); // transparent
  if (count <= 0) return heat[0];
  if (count == 1) return heat[1];
  if (count <= 3) return heat[2];
  return heat[3];
}

/// 每个日期的次数合计（源原型 `countMap`）。
Map<String, int> countMap(List<RecordEntry> records) {
  final m = <String, int>{};
  for (final r in records) {
    m[r.date] = (m[r.date] ?? 0) + r.occ;
  }
  return m;
}

class HeatData {
  HeatData(this.weeks, this.width, this.monthLabels);
  final List<List<Color>> weeks; // 53 列，每列 7 个单元格颜色
  final double width;
  final List<MonthLabel> monthLabels;
}

class MonthLabel {
  MonthLabel(this.left, this.text);
  final double left;
  final String text;
}

/// 53 周年度热力图（源原型 `buildHeat`）。
HeatData buildHeat(
  Map<String, int> cm,
  DateTime today,
  bool weekStartMonday,
  List<Color> heat,
) {
  const cols = 53;
  final lastStart = startOfWeek(today, weekStartMonday);
  final start = lastStart.subtract(const Duration(days: 7 * (cols - 1)));
  final weeks = <List<Color>>[];
  final monthLabels = <MonthLabel>[];
  var lastMonth = -1;
  for (var w = 0; w < cols; w++) {
    final days = <Color>[];
    var monthOfCol = -1;
    for (var dd = 0; dd < 7; dd++) {
      final d = start.add(Duration(days: w * 7 + dd));
      if (dd == 0) monthOfCol = d.month - 1; // 0-based，对齐 getMonth
      final k = dateKey(d);
      final future = midnight(d).isAfter(midnight(today));
      final cnt = future ? -1 : (cm[k] ?? 0);
      days.add(heatColorFor(cnt, future, heat));
    }
    weeks.add(days);
    if (monthOfCol != lastMonth && w < cols - 1) {
      monthLabels.add(MonthLabel(w * 14.0, '${monthOfCol + 1}月'));
      lastMonth = monthOfCol;
    }
  }
  return HeatData(weeks, cols * 14 - 3, monthLabels);
}

class StatBar {
  StatBar(this.label, this.count, this.frac);
  final String label;
  final int count;
  final double frac; // 0..1，相对该组最大值
}

class TagRankItem {
  TagRankItem(this.name, this.count, this.pct);
  final String name;
  final int count;
  final int pct; // 0..100
}

class StatsData {
  StatsData({
    required this.trend,
    required this.maxTrend,
    required this.weekdayBars,
    required this.todBars,
    required this.tagRank,
    required this.avgDaily,
    required this.trendStart,
    required this.trendEnd,
  });
  final List<int> trend;
  final int maxTrend;
  final List<StatBar> weekdayBars;
  final List<StatBar> todBars;
  final List<TagRankItem> tagRank;
  final String avgDaily;
  final String trendStart;
  final String trendEnd;
}

int _timeBucket(int h) =>
    h < 6 ? 0 : h < 9 ? 1 : h < 12 ? 2 : h < 17 ? 3 : h < 20 ? 4 : 5;

/// 区间统计（源原型 `computeStats`）。range ∈ {'7','30','90','year'}。
StatsData computeStats(
  List<RecordEntry> records,
  DateTime today,
  String range,
  bool weekStartMonday,
) {
  final int days;
  if (range == 'year') {
    final jan = DateTime(today.year, 1, 1);
    days = midnight(today).difference(jan).inDays + 1;
  } else {
    days = int.parse(range);
  }
  final startDay = midnight(today).subtract(Duration(days: days - 1));
  final inR = records.where((r) => !r.when.isBefore(startDay)).toList();

  final perDay = <String, int>{};
  for (final r in inR) {
    perDay[r.date] = (perDay[r.date] ?? 0) + r.occ;
  }
  final trend = <int>[];
  for (var i = 0; i < days; i++) {
    final d = startDay.add(Duration(days: i));
    trend.add(perDay[dateKey(d)] ?? 0);
  }
  final maxTrend = math.max(1, trend.fold(0, math.max));

  final wd = List.filled(7, 0);
  for (final r in inR) {
    wd[jsDay(r.when)] += r.occ;
  }
  final ws = weekStartOffset(weekStartMonday);
  final maxWd = math.max(1, wd.fold(0, math.max));
  final weekdayBars = [
    for (var i = 0; i < 7; i++)
      () {
        final dw = (ws + i) % 7;
        return StatBar(kDow[dw], wd[dw], wd[dw] / maxWd);
      }()
  ];

  final tb = List.filled(6, 0);
  for (final r in inR) {
    tb[_timeBucket(r.hour)] += r.occ;
  }
  final maxTb = math.max(1, tb.fold(0, math.max));
  final todBars = [
    for (var i = 0; i < 6; i++) StatBar(kTod[i], tb[i], tb[i] / maxTb),
  ];

  final tc = <String, int>{};
  for (final r in inR) {
    for (final t in r.tags) {
      tc[t] = (tc[t] ?? 0) + 1;
    }
  }
  final maxTc = math.max(1, tc.values.fold(0, math.max));
  final tagRank = tc.entries
      .map((e) => TagRankItem(e.key, e.value, (e.value / maxTc * 100).round()))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));
  final topTags = tagRank.take(7).toList();

  final rangeTotal = inR.fold(0, (s, r) => s + r.occ);

  return StatsData(
    trend: trend,
    maxTrend: maxTrend,
    weekdayBars: weekdayBars,
    todBars: todBars,
    tagRank: topTags,
    avgDaily: (rangeTotal / days).toStringAsFixed(1),
    trendStart: range == 'year' ? '1月' : '$days天前',
    trendEnd: '今天',
  );
}

class IntervalData {
  IntervalData(this.avg, this.max, this.since);
  final String avg;
  final String max;
  final String since;
}

String _humanHours(double h) {
  if (h < 0) return '刚刚';
  if (h < 1) return '${(h * 60).round()} 分钟';
  if (h < 48) return '${h.toStringAsFixed(1)} 小时';
  return '${(h / 24).toStringAsFixed(1)} 天';
}

/// 间隔统计（源原型 `intervals`）。
IntervalData computeIntervals(List<RecordEntry> records, DateTime now) {
  final ds = records.map((r) => r.when).toList()..sort();
  if (ds.length < 2) return IntervalData('—', '—', '—');
  var sum = 0.0;
  var mx = 0.0;
  for (var i = 1; i < ds.length; i++) {
    final g = ds[i].difference(ds[i - 1]).inMilliseconds / 3600000.0;
    sum += g;
    if (g > mx) mx = g;
  }
  final since = now.difference(ds.last).inMilliseconds / 3600000.0;
  return IntervalData(
    _humanHours(sum / (ds.length - 1)),
    _humanHours(mx),
    _humanHours(since),
  );
}
