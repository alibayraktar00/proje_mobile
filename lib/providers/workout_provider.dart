import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_log_model.dart';
import '../services/workout_service.dart';

// State to hold both the list and the selected date
class WorkoutState {
  final DateTime selectedDate;
  final List<WorkoutLogModel> logs;
  final bool isLoading;

  WorkoutState({
    required this.selectedDate,
    this.logs = const [],
    this.isLoading = false,
  });

  WorkoutState copyWith({
    DateTime? selectedDate,
    List<WorkoutLogModel>? logs,
    bool? isLoading,
  }) {
    return WorkoutState(
      selectedDate: selectedDate ?? this.selectedDate,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  WorkoutNotifier() : super(WorkoutState(selectedDate: DateTime.now())) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true);
    try {
      final logs = await WorkoutService.getLogsForDate(state.selectedDate);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      // Ensure loading is false on error
      state = state.copyWith(isLoading: false);
      // Optional: Store error in state if needed
      // print("Error loading logs: $e");
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadLogs();
  }

  Future<void> addLog(String exerciseName, String sets, String reps) async {
    final newLog = WorkoutLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: exerciseName,
      sets: sets,
      reps: reps,
      timestamp: state.selectedDate, // Add to the currently selected date (or today?)
      // Ideally usually we add to "Today" even if viewing "Yesterday", but for simplicity let's stick to adding to selected date or force Today.
      // Let's force today for new logs unless valid reason not to.
      // ACTUALLY: User might want to log past workout. Let's use selectedDate. 
    );

    // Optimistic update
    state = state.copyWith(logs: [newLog, ...state.logs]);
    
    await WorkoutService.addLog(newLog);
    // Reload to ensure consistency (e.g. server timestamp if used, though here using client)
  }

  Future<void> addCardioLog(String activityType, Duration duration, double calories, double speed) async {
    final setsDisplay = "${duration.inMinutes} min";
    final repsDisplay = "${calories.toInt()} kcal";
    
    final newLog = WorkoutLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: "Cardio: ${activityType.toUpperCase()}",
      sets: setsDisplay,
      reps: repsDisplay,
      weight: speed, // Storing speed in weight field for now
      isCompleted: true, // Cardio finished when saved
      timestamp: state.selectedDate,
    );

    state = state.copyWith(logs: [newLog, ...state.logs]);
    await WorkoutService.addLog(newLog);
  }

  Future<void> toggleStatus(String id) async {
    final logIndex = state.logs.indexWhere((l) => l.id == id);
    if (logIndex == -1) return;

    final currentLog = state.logs[logIndex];
    final updatedLog = WorkoutLogModel(
      id: currentLog.id,
      exerciseName: currentLog.exerciseName,
      sets: currentLog.sets,
      reps: currentLog.reps,
      weight: currentLog.weight,
      isCompleted: !currentLog.isCompleted,
      timestamp: currentLog.timestamp,
    );

    // Optimistic update
    final updatedList = [...state.logs];
    updatedList[logIndex] = updatedLog;
    state = state.copyWith(logs: updatedList);

    await WorkoutService.toggleStatus(id, currentLog.isCompleted);
  }

  Future<void> removeLog(String id) async {
    state = state.copyWith(logs: state.logs.where((l) => l.id != id).toList());
    await WorkoutService.deleteLog(id);
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier();
});
