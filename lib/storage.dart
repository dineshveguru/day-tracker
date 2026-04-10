import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class TrackerStorageData {
  TrackerStorageData({
    required this.categories,
    required this.records,
  });

  final List<TrackerCategory> categories;
  final Map<String, DayRecord> records;
}

class TrackerStorage {
  static const _storageKey = 'day_tracker_v1';

  Future<TrackerStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return TrackerStorageData(categories: [], records: {});
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final categoriesJson = (decoded['categories'] as List<dynamic>? ?? []);
    final recordsJson = (decoded['records'] as Map<String, dynamic>? ?? {});
    return TrackerStorageData(
      categories: categoriesJson
          .map((c) => TrackerCategory.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
      records: recordsJson.map(
        (key, value) => MapEntry(
          key,
          DayRecord.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
    );
  }

  Future<void> save({
    required List<TrackerCategory> categories,
    required Map<String, DayRecord> records,
  }) async {
    final payload = {
      'categories': categories.map((c) => c.toJson()).toList(),
      'records': records.map((k, v) => MapEntry(k, v.toJson())),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(payload));
  }
}
