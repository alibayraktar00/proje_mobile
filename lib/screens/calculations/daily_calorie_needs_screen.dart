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
      final int age = int.parse(_ageController.text);
      final double height = double.parse(_heightController.text);
      final double weight = double.parse(_weightController.text);

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Daily Calorie Needs"),
        backgroundColor: Colors.deepPurple, // Different color to distinguish
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Card
              if (_dailyCalories != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("Daily Target", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("${_dailyCalories!.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _goal == 'lose' ? "To Lose Weight" : (_goal == 'gain' ? "To Gain Muscle" : "To Maintain Weight"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              _buildSectionTitle("Personal Details"),
              Row(
                children: [
                  Expanded(child: _buildGenderSelector("Male", "male", Icons.male)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderSelector("Female", "female", Icons.female)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField("Age", _ageController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputField("Height (cm)", _heightController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputField("Weight (kg)", _weightController)),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Activity Level"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: _activityLevel,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1.2, child: Text("Sedentary (No exercise)")),
                      DropdownMenuItem(value: 1.375, child: Text("Lightly Active (1-3 days/week)")),
                      DropdownMenuItem(value: 1.55, child: Text("Moderately Active (3-5 days/week)")),
                      DropdownMenuItem(value: 1.725, child: Text("Very Active (6-7 days/week)")),
                    ],
                    onChanged: (v) => setState(() => _activityLevel = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Goal"),
              Row(
                children: [
                  _buildGoalOption("Lose Fat", "lose"),
                  _buildGoalOption("Maintain", "maintain"),
                  _buildGoalOption("Build Muscle", "gain"),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _calculateCalories,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("CALCULATE", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  }

  Widget _buildGenderSelector(String label, String value, IconData icon) {
    bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
        ),
        child: Column(children: [Icon(icon, color: isSelected ? Colors.white : Colors.grey), Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      TextFormField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
    ]);
  }

  Widget _buildGoalOption(String label, String value) {
    bool isSelected = _goal == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _goal = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? Colors.deepPurple : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}