import 'package:day_tracker/logic.dart';
import 'package:day_tracker/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackerLogic.intensityFromHours', () {
    test('returns 0 for 0 hours', () {
      expect(TrackerLogic.intensityFromHours(0), 0);
    });

    test('caps at 1', () {
      expect(TrackerLogic.intensityFromHours(12), 1);
    });
  });

  group('TrackerLogic.streakStatsForCategory', () {
    test('calculates best and current streak', () {
      final now = DateTime.now();
      final day0 = DateTime(now.year, now.month, now.day);
      final day1 = day0.subtract(const Duration(days: 1));
      final day2 = day0.subtract(const Duration(days: 2));
      final day4 = day0.subtract(const Duration(days: 4));
      final categoryId = 'work';

      DayRecord makeRecord(DateTime date, {required bool active}) {
        final record = DayRecord.empty(TrackerLogic.dateKey(date));
        if (active) {
          record.hours[0].actualCategoryId = categoryId;
        }
        return record;
      }

      final data = <String, DayRecord>{
        TrackerLogic.dateKey(day0): makeRecord(day0, active: true),
        TrackerLogic.dateKey(day1): makeRecord(day1, active: true),
        TrackerLogic.dateKey(day2): makeRecord(day2, active: true),
        TrackerLogic.dateKey(day4): makeRecord(day4, active: true),
      };

      final result = TrackerLogic.streakStatsForCategory(
        data,
        categoryId,
        useActual: true,
      );

      expect(result.current, 3);
      expect(result.best, 3);
    });
  });

  group('TrackerLogic.hoursByCategory', () {
    test('aggregates planned and actual hours independently', () {
      final record = DayRecord.empty('2026-01-01');
      record.hours[0].plannedCategoryId = 'work';
      record.hours[1].plannedCategoryId = 'work';
      record.hours[2].plannedCategoryId = 'learn';
      record.hours[3].actualCategoryId = 'work';
      record.hours[4].actualCategoryId = 'health';

      final planned = TrackerLogic.hoursByCategory(record, false);
      final actual = TrackerLogic.hoursByCategory(record, true);

      expect(planned['work'], 2);
      expect(planned['learn'], 1);
      expect(actual['work'], 1);
      expect(actual['health'], 1);
      expect(actual['learn'], isNull);
    });
  });
}
