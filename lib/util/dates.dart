/// 日期工具，移植自源原型的 `pad` / `key` / `startOfWeek` / `ws`。
String pad2(int n) => n < 10 ? '0$n' : '$n';

/// 'YYYY-MM-DD'（源原型 `key`）。
String dateKey(DateTime d) =>
    '${d.year}-${pad2(d.month)}-${pad2(d.day)}';

/// JS 风格星期：0=周日 … 6=周六（源原型用 `getDay`）。
/// Dart 的 `weekday` 是 1=周一 … 7=周日，取模 7 即得。
int jsDay(DateTime d) => d.weekday % 7;

/// 周起始偏移：周一起始返回 1，周日起始返回 0（源原型 `ws`）。
int weekStartOffset(bool weekStartMonday) => weekStartMonday ? 1 : 0;

DateTime midnight(DateTime d) => DateTime(d.year, d.month, d.day);

/// 给定日期所在周的起始零点（源原型 `startOfWeek`）。
DateTime startOfWeek(DateTime d, bool weekStartMonday) {
  final x = midnight(d);
  final diff = (jsDay(x) - weekStartOffset(weekStartMonday) + 7) % 7;
  return x.subtract(Duration(days: diff));
}

/// 熬夜模式下的「逻辑时刻」：0 点到 cutoff 点（不含）之间的时刻归到前一天。
/// cutoff=0 时原样返回（逻辑日≡物理日）。
DateTime logicalWhen(DateTime when, int cutoff) {
  if (cutoff > 0 && when.hour < cutoff) {
    return when.subtract(const Duration(days: 1));
  }
  return when;
}

/// 记录归属的「逻辑日」key（YYYY-MM-DD），用于所有按天分组。
String logicalDayKey(DateTime when, int cutoff) =>
    dateKey(logicalWhen(when, cutoff));
