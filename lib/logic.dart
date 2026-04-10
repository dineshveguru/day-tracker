import 'models.dart';

class StreakStats {
  StreakStats({
    required this.current,
    required this.best,
  });

  final int current;
  final int best;
}

class TrackerLogic {
  static String dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  static double intensityFromHours(double hours) {
    if (hours <= 0) return 0;
    return (hours / 8).clamp(0, 1);
  }

  static Map<String, double> hoursByCategory(
    DayRecord record,
    bool useActual,
  ) {
    final map = <String, double>{};
    for (final h in record.hours) {
      final id = useActual ? h.actualCategoryId : h.plannedCategoryId;
      if (id == null) continue;
      map[id] = (map[id] ?? 0) + 1;
    }
    return map;
  }

  static StreakStats streakStatsForCategory(
    Map<String, DayRecord> records,
    String categoryId, {
    required bool useActual,
  }) {
    if (records.isEmpty) return StreakStats(current: 0, best: 0);
    final activeDates = <DateTime>[];
    for (final entry in records.entries) {
      final hourly = hoursByCategory(entry.value, useActual);
      if ((hourly[categoryId] ?? 0) > 0) {
        final d = DateTime.parse(entry.key);
        activeDates.add(DateTime(d.year, d.month, d.day));
      }
    }
    activeDates.sort();

    int best = 0;
    int running = 0;
    DateTime? previousActive;
    for (final date in activeDates) {
      if (previousActive == null || date.difference(previousActive).inDays == 1) {
        running += 1;
      } else {
        running = 1;
      }
      if (running > best) best = running;
      previousActive = date;
    }

    int current = 0;
    final activeSet = activeDates.map(dateKey).toSet();
    DateTime cursor = DateTime.now();
    while (true) {
      final key = dateKey(cursor);
      if (!activeSet.contains(key)) break;
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return StreakStats(current: current, best: best);
  }
}
