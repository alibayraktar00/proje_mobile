import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'bmi_calculator_screen.dart';
import 'cardio_stopwatch_screen.dart';
import 'calorie_estimation_screen.dart';
import 'daily_calorie_needs_screen.dart'; // YENİ DOSYAYI İMPORT ETTİK

class CalculationsTab extends StatelessWidget {
  const CalculationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is active to adjust colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Advanced Calculation Hub'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.orange.shade400, Colors.deepOrange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(currentUserProvider);

          if (user == null) {
            return const Center(
              child: Text('Please complete your profile first'),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Colors.black, Colors.grey[900]!]
                    : [Colors.orange.shade50, Colors.white],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 16), // Top padding for transparent AppBar
              children: [
                _buildModernCard(
                  context,
                  title: 'BMI Calculator',
                  description: 'Calculate your Body Mass Index and get status feedback',
                  icon: Icons.monitor_weight_outlined,
                  gradient: [Colors.blue.shade400, Colors.blue.shade700],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BMICalculatorScreen(user: user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildModernCard(
                  context,
                  title: 'Cardio Stopwatch',
                  description: 'Full-featured stopwatch for cardio workouts',
                  icon: Icons.timer_outlined,
                  gradient: [Colors.green.shade400, Colors.green.shade700],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardioStopwatchScreen(user: user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildModernCard(
                  context,
                  title: 'Calorie Estimation',
                  description: 'Real-time calorie burn estimation based on activity',
                  icon: Icons.local_fire_department_outlined,
                  gradient: [Colors.orange.shade400, Colors.orange.shade700],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CalorieEstimationScreen(user: user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildModernCard(
                  context,
                  title: 'Daily Calorie Needs',
                  description: 'Calculate your daily intake for weight loss or muscle gain',
                  icon: Icons.restaurant_menu,
                  gradient: [Colors.purple.shade400, Colors.purple.shade700],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DailyCalorieNeedsScreen(user: user),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required List<Color> gradient,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
