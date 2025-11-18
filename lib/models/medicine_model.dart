import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 3)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final List<TimeOfDayModel> times;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime? endDate;

  @HiveField(6)
  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)

  @HiveField(7)
  final String? note;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final String? color;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.note,
    this.isActive = true,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times.map((t) => t.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek,
      'note': note,
      'isActive': isActive,
      'color': color,
    };
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: (json['times'] as List)
          .map((t) => TimeOfDayModel.fromJson(t))
          .toList(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      note: json['note'],
      isActive: json['isActive'] ?? true,
      color: json['color'],
    );
  }
}

@HiveType(typeId: 4)
class TimeOfDayModel {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  TimeOfDayModel({required this.hour, required this.minute});

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) {
    return TimeOfDayModel(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

