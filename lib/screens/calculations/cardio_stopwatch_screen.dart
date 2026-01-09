import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';

import '../../providers/workout_provider.dart';
import '../../services/calculation_service.dart';

class CardioStopwatchScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const CardioStopwatchScreen({super.key, required this.user});

  @override
  ConsumerState<CardioStopwatchScreen> createState() =>
      _CardioStopwatchScreenState();
}

class _CardioStopwatchScreenState
    extends ConsumerState<CardioStopwatchScreen> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isRunning = false;

  double _speed = 8.0; // km/h
  double _incline = 0.0; // percentage
  String _activityType = 'running';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
      });
      setState(() => _isRunning = true);
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _duration = Duration.zero;
      _isRunning = false;

    });
  }

  void _saveWorkout() {
    if (_duration.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workout to save')),
      );
      return;
    }

    final caloriesBurned = CalculationService.estimateCaloriesBurned(
      weightKg: widget.user.weight,
      duration: _duration,
      speedKmh: _speed,
      incline: _incline,
      activityType: _activityType,
    );

    /* 
    // Legacy Session Model
    final session = WorkoutSessionModel(
      key: ...
    );
    */

    ref.read(workoutProvider.notifier).addCardioLog(
      _activityType,
      _duration,
      caloriesBurned,
      _speed
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Workout saved! Calories burned: ${caloriesBurned.toStringAsFixed(1)}',
        ),
      ),
    );

    _resetTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  double _getCaloriesBurned() {
    if (_duration.inSeconds == 0) return 0;
    return CalculationService.estimateCaloriesBurned(
      weightKg: widget.user.weight,
      duration: _duration,
      speedKmh: _speed,
      incline: _incline,
      activityType: _activityType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cardio Stopwatch'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Colors.grey[900]!, Colors.black]
              : [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timer Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? Colors.green : Colors.grey).withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [Colors.grey[800]!, Colors.grey[900]!]
                          : [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined, 
                        size: 32, 
                        color: _isRunning ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: _isRunning ? Colors.green : (isDark ? Colors.white : Colors.black87),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isRunning ? 'ACTIVE' : 'PAUSED',
                        style: TextStyle(
                          color: _isRunning ? Colors.green : Colors.grey,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     // Save Button (Mini)
                    _buildCircularControl(
                      icon: Icons.save,
                      color: Colors.blue,
                      size: 50,
                      onTap: _saveWorkout,
                      label: "Save",
                    ),
                    const SizedBox(width: 30),

                    // Play/Pause (Main)
                    _buildCircularControl(
                      icon: _isRunning ? Icons.pause : Icons.play_arrow,
                      color: _isRunning ? Colors.orange : Colors.green,
                      size: 80,
                      onTap: _isRunning ? _stopTimer : _startTimer,
                      isMain: true,
                    ),
                    const SizedBox(width: 30),

                    // Reset Button (Mini)
                    _buildCircularControl(
                      icon: Icons.refresh,
                      color: Colors.red,
                      size: 50,
                      onTap: _resetTimer,
                      label: "Reset",
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Stats & Settings
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Calories', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              Text('Burned', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getCaloriesBurned().toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 32, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.orange
                                ),
                              ),
                              const Text('kcal', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      
                      // Type Selection
                      DropdownButtonFormField<String>(
                        key: ValueKey(_activityType),
                        value: _activityType,
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: Icon(Icons.fitness_center, color: Colors.green),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'running', child: Text('Running 🏃')),
                          DropdownMenuItem(value: 'walking', child: Text('Walking 🚶')),
                          DropdownMenuItem(value: 'cycling', child: Text('Cycling 🚴')),
                        ],
                        onChanged: (value) {
                          setState(() => _activityType = value ?? 'running');
                        },
                      ),

                      const SizedBox(height: 20),

                      // Speed Slider
                      _buildSimpleSlider(
                        label: 'Speed', 
                        value: _speed, 
                        unit: 'km/h', 
                        min: 1, 
                        max: 20, 
                        color: Colors.blue,
                        onChanged: (v) => setState(() => _speed = v),
                      ),

                      const SizedBox(height: 10),

                      // Incline Slider
                      _buildSimpleSlider(
                        label: 'Incline', 
                        value: _incline, 
                        unit: '%', 
                        min: 0, 
                        max: 15, 
                        color: Colors.purple,
                        onChanged: (v) => setState(() => _incline = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularControl({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    bool isMain = false,
    String? label,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMain ? color : color.withValues(alpha: 0.1),
              boxShadow: isMain ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : null,
              border: isMain ? null : Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: isMain ? Colors.white : color,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  Widget _buildSimpleSlider({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color color,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


