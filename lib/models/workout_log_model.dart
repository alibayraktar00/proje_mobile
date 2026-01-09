import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutLogModel {
  final String id;
  final String exerciseName;
  final String sets;
  final String reps;
  final double? weight;
  final bool isCompleted;
  final DateTime timestamp;

  WorkoutLogModel({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
    this.isCompleted = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map) {
    return WorkoutLogModel(
      id: map['id'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: map['sets'] ?? '',
      reps: map['reps'] ?? '',
      weight: map['weight']?.toDouble(),
      isCompleted: map['isCompleted'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
