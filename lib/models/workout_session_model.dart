class WorkoutSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double? caloriesBurned;
  final String? exerciseType; // "cardio", "strength", etc.
  final Map<String, dynamic>? metadata; // speed, incline, etc.

  WorkoutSessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.caloriesBurned,
    this.exerciseType,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration.inSeconds,
      'caloriesBurned': caloriesBurned,
      'exerciseType': exerciseType,
      'metadata': metadata,
    };
  }

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      duration: Duration(seconds: map['duration'] ?? 0),
      caloriesBurned: map['caloriesBurned']?.toDouble(),
      exerciseType: map['exerciseType'],
      metadata: map['metadata'],
    );
  }
}
