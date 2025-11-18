import 'package:hive/hive.dart';

part 'health_vital_model.g.dart';

@HiveType(typeId: 1)
class HealthVitalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final VitalType type;

  @HiveField(2)
  final double value;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final String? unit;

  @HiveField(5)
  final String? note;

  HealthVitalModel({
    required this.id,
    required this.type,
    required this.value,
    required this.dateTime,
    this.unit,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'value': value,
      'dateTime': dateTime.toIso8601String(),
      'unit': unit,
      'note': note,
    };
  }

  factory HealthVitalModel.fromJson(Map<String, dynamic> json) {
    return HealthVitalModel(
      id: json['id'],
      type: VitalType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => VitalType.heartRate,
      ),
      value: (json['value'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      unit: json['unit'],
      note: json['note'],
    );
  }
}

@HiveType(typeId: 2)
enum VitalType {
  @HiveField(0)
  heartRate,
  @HiveField(1)
  bloodPressure,
  @HiveField(2)
  temperature,
  @HiveField(3)
  weight,
  @HiveField(4)
  bloodSugar,
  @HiveField(5)
  oxygen,
  @HiveField(6)
  sleep,
  @HiveField(7)
  steps,
}

extension VitalTypeExtension on VitalType {
  String get displayName {
    switch (this) {
      case VitalType.heartRate:
        return 'Heart Rate';
      case VitalType.bloodPressure:
        return 'Blood Pressure';
      case VitalType.temperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
      case VitalType.bloodSugar:
        return 'Blood Sugar';
      case VitalType.oxygen:
        return 'Oxygen';
      case VitalType.sleep:
        return 'Sleep Hours';
      case VitalType.steps:
        return 'Steps';
    }
  }

  String get defaultUnit {
    switch (this) {
      case VitalType.heartRate:
        return 'bpm';
      case VitalType.bloodPressure:
        return 'mmHg';
      case VitalType.temperature:
        return '°C';
      case VitalType.weight:
        return 'kg';
      case VitalType.bloodSugar:
        return 'mg/dL';
      case VitalType.oxygen:
        return '%';
      case VitalType.sleep:
        return 'hours';
      case VitalType.steps:
        return 'steps';
    }
  }

  String get icon {
    switch (this) {
      case VitalType.heartRate:
        return '❤️';
      case VitalType.bloodPressure:
        return '🩺';
      case VitalType.temperature:
        return '🌡️';
      case VitalType.weight:
        return '⚖️';
      case VitalType.bloodSugar:
        return '🩸';
      case VitalType.oxygen:
        return '💨';
      case VitalType.sleep:
        return '😴';
      case VitalType.steps:
        return '🚶';
    }
  }
}

