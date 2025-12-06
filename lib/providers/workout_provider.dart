import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_session_model.dart';
import '../services/hive_service.dart';

final workoutSessionsProvider =
    StateNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSessionModel>>((ref) {
  return WorkoutSessionsNotifier();
});

class WorkoutSessionsNotifier extends StateNotifier<List<WorkoutSessionModel>> {
  WorkoutSessionsNotifier() : super([]) {
    loadWorkouts();
  }

  void loadWorkouts() {
    state = HiveService.getWorkoutSessions();
  }

  Future<void> addWorkoutSession(WorkoutSessionModel session) async {
    await HiveService.saveWorkoutSession(session);
    loadWorkouts();
  }

  Future<void> deleteWorkoutSession(String id) async {
    await HiveService.deleteWorkoutSession(id);
    loadWorkouts();
  }

  Future<void> clearAllWorkouts() async {
    await HiveService.clearAllWorkouts();
    loadWorkouts();
  }
}

