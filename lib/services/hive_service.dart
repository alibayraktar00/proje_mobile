import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/workout_session_model.dart';

class HiveService {
  static const String workoutBoxName = 'workout_sessions';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(workoutBoxName);
  }

  static Box get workoutBox => Hive.box(workoutBoxName);

  static Future<void> saveWorkoutSession(WorkoutSessionModel session) async {
    await workoutBox.put(session.id, jsonEncode(session.toMap()));
  }

  static List<WorkoutSessionModel> getWorkoutSessions() {
    final sessions = <WorkoutSessionModel>[];
    for (var key in workoutBox.keys) {
      final data = workoutBox.get(key);
      if (data != null) {
        try {
          final map = jsonDecode(data as String);
          sessions.add(WorkoutSessionModel.fromMap(map));
        } catch (e) {
          // Handle error
        }
      }
    }
    return sessions;
  }

  static Future<void> deleteWorkoutSession(String id) async {
    await workoutBox.delete(id);
  }

  static Future<void> clearAllWorkouts() async {
    await workoutBox.clear();
  }
}
