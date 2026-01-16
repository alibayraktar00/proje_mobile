import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/calculation_service.dart';

class CalorieEstimationScreen extends StatefulWidget {
  final UserModel user;

  const CalorieEstimationScreen({super.key, required this.user});

  @override
  State<CalorieEstimationScreen> createState() =>
      _CalorieEstimationScreenState();
}

class _CalorieEstimationScreenState extends State<CalorieEstimationScreen> {
  double _speed = 8.0; // km/h
  double _incline = 0.0; // percentage
  int _durationMinutes = 30;
  String _activityType = 'running';
  double? _estimatedCalories;
  double? _bmr;

  @override
  void initState() {
    super.initState();
    _calculateBMR();
    _estimateCalories();
  }

  void _calculateBMR() {
    if (widget.user.gender != null) {
      setState(() {
        _bmr = CalculationService.calculateBMR(
          weightKg: widget.user.weight,
          heightCm: widget.user.height,
          age: widget.user.age,
          gender: widget.user.gender!,
        );
      });
    }
  }



  void _estimateCalories() {
    setState(() {
      _estimatedCalories = CalculationService.estimateCaloriesBurned(
        weightKg: widget.user.weight,
        duration: Duration(minutes: _durationMinutes),
        speedKmh: _speed,
        incline: _incline,
        activityType: _activityType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Calorie Estimation'),
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
              : [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Estimated Burn',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _estimatedCalories?.toStringAsFixed(0) ?? '0',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Controls Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Type Dropdown (Styled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: ValueKey(_activityType),
                            value: _activityType,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                            items: const [
                              DropdownMenuItem(value: 'running', child: Text('Running 🏃')),
                              DropdownMenuItem(value: 'walking', child: Text('Walking 🚶')),
                              DropdownMenuItem(value: 'cycling', child: Text('Cycling 🚴')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _activityType = value ?? 'running';
                                _estimateCalories();
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Duration Slider
                      _buildModernSlider(
                        label: 'Duration',
                        value: _durationMinutes.toDouble(),
                        unit: 'min',
                        min: 5,
                        max: 180,
                        color: Colors.blue,
                        onChanged: (val) {
                          setState(() {
                            _durationMinutes = val.toInt();
                            _estimateCalories();
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Speed Slider
                      _buildModernSlider(
                        label: 'Speed',
                        value: _speed,
                        unit: 'km/h',
                        min: 1,
                        max: 20,
                        color: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _speed = val;
                            _estimateCalories();
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Incline Slider
                      _buildModernSlider(
                        label: 'Incline',
                        value: _incline,
                        unit: '%',
                        min: 0,
                        max: 15,
                        color: Colors.purple,
                        onChanged: (val) {
                          setState(() {
                            _incline = val;
                            _estimateCalories();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (_bmr != null) ...[
                  const SizedBox(height: 24),
                  _buildQuickStat('Basal Metabolic Rate (BMR)', '${_bmr!.toStringAsFixed(0)} kcal/day', Colors.teal),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSlider({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color color,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            Text(
              '${value.toStringAsFixed(1)} $unit', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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

  Widget _buildQuickStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}


