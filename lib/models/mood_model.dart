import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 0)
class MoodModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String mood;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final List<String> tags;

  MoodModel({
    required this.id,
    required this.mood,
    required this.dateTime,
    this.note,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'tags': tags,
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      mood: json['mood'],
      dateTime: DateTime.parse(json['dateTime']),
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

