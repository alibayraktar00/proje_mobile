import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class DailyCalorieNeedsScreen extends StatefulWidget {
  final UserModel? user;

  const DailyCalorieNeedsScreen({super.key, this.user});

  @override
  State<DailyCalorieNeedsScreen> createState() => _DailyCalorieNeedsScreenState();
}

class _DailyCalorieNeedsScreenState extends State<DailyCalorieNeedsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'male';
  double _activityLevel = 1.2;
  String _goal = 'maintain';

  double? _dailyCalories;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _ageController.text = widget.user!.age.toString();
      _heightController.text = widget.user!.height.toString();
      _weightController.text = widget.user!.weight.toString();
      _selectedGender = widget.user!.gender ?? 'male';
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    if (_formKey.currentState!.validate()) {
      final int age = int.tryParse(_ageController.text) ?? 0;
      final double height = double.tryParse(_heightController.text) ?? 0;
      final double weight = double.tryParse(_weightController.text) ?? 0;

      if (age == 0 || height == 0 || weight == 0) return;

      // Mifflin-St Jeor Equation
      double bmr;
      if (_selectedGender == 'male') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }

      double tdee = bmr * _activityLevel;
      double finalCalories = tdee;

      // Goal Adjustment
      if (_goal == 'lose') finalCalories -= 500;
      if (_goal == 'gain') finalCalories += 500;

      setState(() {
        _dailyCalories = finalCalories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Daily Calorie Needs"),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Colors.grey[900]!, Colors.black]
              : [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Result Card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _dailyCalories != null
                      ? Container(
                          key: const ValueKey('result'),
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text("Daily Target", style: TextStyle(color: Colors.white70, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text("${_dailyCalories!.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _goal == 'lose' ? "Loss (approx. 0.5kg/week)" : (_goal == 'gain' ? "Gain (approx. 0.5kg/week)" : "Maintenance"),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(key: ValueKey('empty'), height: 0),
                  ),

                  _buildSectionTitle("Personal Details", isDark: isDark),
                  
                  // Gender Selector
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildGenderOption("Male", "male", Icons.male),
                        _buildGenderOption("Female", "female", Icons.female),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Inputs Row
                  Row(
                    children: [
                      Expanded(child: _buildModernInput("Age", _ageController, isDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernInput("Height (cm)", _heightController, isDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernInput("Weight (kg)", _weightController, isDark)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Activity Level", isDark: isDark),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: _activityLevel,
                        isExpanded: true,
                        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.deepPurple),
                        items: const [
                          DropdownMenuItem(value: 1.2, child: Text("🛋️  Sedentary (No exercise)")),
                          DropdownMenuItem(value: 1.375, child: Text("🚶  Lightly Active (1-3 days)")),
                          DropdownMenuItem(value: 1.55, child: Text("🏃  Moderately Active (3-5 days)")),
                          DropdownMenuItem(value: 1.725, child: Text("🏋️  Very Active (6-7 days)")),
                        ],
                        onChanged: (v) => setState(() => _activityLevel = v!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Goal", isDark: isDark),

                  // Goal Selector
                  Row(
                    children: [
                      _buildGoalCard("Lose Fat", "lose", Icons.trending_down, Colors.redAccent),
                      const SizedBox(width: 12),
                      _buildGoalCard("Maintain", "maintain", Icons.balance, Colors.blueAccent),
                      const SizedBox(width: 12),
                      _buildGoalCard("Build Muscle", "gain", Icons.trending_up, Colors.green),
                    ],
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _calculateCalories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                    ),
                    child: const Text("CALCULATE RESULTS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), 
      child: Text(
        title.toUpperCase(), 
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    bool isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                label, 
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput(String label, TextEditingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: "0",
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          ),
        ),
      ]
    );
  }

  Widget _buildGoalCard(String label, String value, IconData icon, Color color) {
    bool isSelected = _goal == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _goal = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 0 : 2
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(
                label, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey, 
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}