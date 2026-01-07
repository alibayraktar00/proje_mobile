import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingState {
  final double currentCalories;
  final double targetCalories;
  final double currentWater;
  final double targetWater;

  TrackingState({
    required this.currentCalories,
    required this.targetCalories,
    required this.currentWater,
    required this.targetWater,
  });

  TrackingState copyWith({
    double? currentCalories,
    double? targetCalories,
    double? currentWater,
    double? targetWater,
  }) {
    return TrackingState(
      currentCalories: currentCalories ?? this.currentCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      currentWater: currentWater ?? this.currentWater,
      targetWater: targetWater ?? this.targetWater,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  // Başlangıç değerlerini burada tanımlıyoruz
  TrackingNotifier() : super(TrackingState(
    currentCalories: 0.0,
    targetCalories: 2500.0,
    currentWater: 0.0,
    targetWater: 3.0,
  ));

  // --- Kalori Fonksiyonları ---
  void addCalories(double amount) => state = state.copyWith(currentCalories: state.currentCalories + amount);
  void resetCalories() => state = state.copyWith(currentCalories: 0.0);
  void setTargetCalories(double target) => state = state.copyWith(targetCalories: target);

  // --- Su Fonksiyonları ---
  void addWater(double amount) => state = state.copyWith(currentWater: state.currentWater + amount);
  void resetWater() => state = state.copyWith(currentWater: 0.0);
  void setTargetWater(double target) => state = state.copyWith(targetWater: target);
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier();
});