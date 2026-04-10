class TrackerCategory {
  TrackerCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
      };

  factory TrackerCategory.fromJson(Map<String, dynamic> json) => TrackerCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
      );
}

class HourRecord {
  HourRecord({
    this.plannedCategoryId,
    this.actualCategoryId,
  });

  String? plannedCategoryId;
  String? actualCategoryId;

  Map<String, dynamic> toJson() => {
        'plannedCategoryId': plannedCategoryId,
        'actualCategoryId': actualCategoryId,
      };

  factory HourRecord.fromJson(Map<String, dynamic> json) => HourRecord(
        plannedCategoryId: json['plannedCategoryId'] as String?,
        actualCategoryId: json['actualCategoryId'] as String?,
      );
}

class DayRecord {
  DayRecord({
    required this.dateKey,
    required this.hours,
  });

  final String dateKey;
  final List<HourRecord> hours;

  factory DayRecord.empty(String dateKey) => DayRecord(
        dateKey: dateKey,
        hours: List<HourRecord>.generate(24, (_) => HourRecord()),
      );

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'hours': hours.map((h) => h.toJson()).toList(),
      };

  factory DayRecord.fromJson(Map<String, dynamic> json) {
    final rawHours = json['hours'] as List<dynamic>;
    return DayRecord(
      dateKey: json['dateKey'] as String,
      hours: rawHours
          .map((h) => HourRecord.fromJson(Map<String, dynamic>.from(h as Map)))
          .toList(),
    );
  }
}
