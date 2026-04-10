import 'package:flutter/material.dart';

import 'logic.dart';
import 'models.dart';
import 'storage.dart';

class TrackerController extends ChangeNotifier {
  TrackerController({TrackerStorage? storage}) : _storage = storage ?? TrackerStorage();

  final TrackerStorage _storage;

  bool loading = true;
  bool editActual = false;
  DateTime selectedDate = DateTime.now();
  final List<TrackerCategory> _categories = [];
  final Map<String, DayRecord> _records = {};

  List<TrackerCategory> get categories => List.unmodifiable(_categories);
  Map<String, DayRecord> get records => Map.unmodifiable(_records);

  Future<void> initialize() async {
    final loaded = await _storage.load();
    _categories
      ..clear()
      ..addAll(loaded.categories.isNotEmpty ? loaded.categories : _defaultCategories());
    _records
      ..clear()
      ..addAll(loaded.records);
    _ensureDayRecord(selectedDate);
    loading = false;
    notifyListeners();
    await _save();
  }

  DayRecord get selectedRecord => _ensureDayRecord(selectedDate);

  Future<void> pickDate(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    _ensureDayRecord(selectedDate);
    notifyListeners();
  }

  Future<void> toggleMode(bool actual) async {
    editActual = actual;
    notifyListeners();
  }

  Future<void> setHourCategory({
    required int hour,
    required String? categoryId,
  }) async {
    final record = selectedRecord;
    final hourRecord = record.hours[hour];
    if (editActual) {
      hourRecord.actualCategoryId = categoryId;
    } else {
      hourRecord.plannedCategoryId = categoryId;
    }
    notifyListeners();
    await _save();
  }

  Future<void> addCategory({
    required String name,
    required Color color,
  }) async {
    _categories.add(
      TrackerCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        colorValue: color.value,
      ),
    );
    notifyListeners();
    await _save();
  }

  Future<void> removeCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    for (final record in _records.values) {
      for (final hour in record.hours) {
        if (hour.plannedCategoryId == id) hour.plannedCategoryId = null;
        if (hour.actualCategoryId == id) hour.actualCategoryId = null;
      }
    }
    notifyListeners();
    await _save();
  }

  Future<void> renameCategory({
    required String id,
    required String name,
  }) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final old = _categories[index];
    _categories[index] = TrackerCategory(id: old.id, name: name.trim(), colorValue: old.colorValue);
    notifyListeners();
    await _save();
  }

  double hoursForCategoryOnDate({
    required String categoryId,
    required DateTime date,
    required bool useActual,
  }) {
    final key = TrackerLogic.dateKey(date);
    final record = _records[key];
    if (record == null) return 0;
    return TrackerLogic.hoursByCategory(record, useActual)[categoryId] ?? 0;
  }

  StreakStats streakForCategory(String categoryId) => TrackerLogic.streakStatsForCategory(
        _records,
        categoryId,
        useActual: true,
      );

  Future<void> _save() => _storage.save(categories: _categories, records: _records);

  DayRecord _ensureDayRecord(DateTime date) {
    final key = TrackerLogic.dateKey(date);
    return _records.putIfAbsent(key, () => DayRecord.empty(key));
  }

  List<TrackerCategory> _defaultCategories() => [
        TrackerCategory(id: 'work', name: 'Work', colorValue: const Color(0xFF00E5FF).value),
        TrackerCategory(id: 'health', name: 'Health', colorValue: const Color(0xFF39FF14).value),
        TrackerCategory(id: 'learn', name: 'Learning', colorValue: const Color(0xFFFF00C8).value),
      ];
}
