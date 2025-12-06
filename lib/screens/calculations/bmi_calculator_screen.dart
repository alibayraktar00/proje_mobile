import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/calculation_service.dart';

class BMICalculatorScreen extends StatefulWidget {
  final UserModel user;

  const BMICalculatorScreen({super.key, required this.user});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  double? _bmi;
  String? _status;
  final _weightController = TextEditingController(
    text: '', // Will be set from user data
  );
  final _heightController = TextEditingController(
    text: '', // Will be set from user data
  );

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.user.weight.toStringAsFixed(1);
    _heightController.text = widget.user.height.toStringAsFixed(1);
    _calculateBMI();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight != null && height != null && weight > 0 && height > 0) {
      setState(() {
        _bmi = CalculationService.calculateBMI(weight, height);
        _status = CalculationService.getBMIStatus(_bmi!);
      });
    } else {
      setState(() {
        _bmi = null;
        _status = null;
      });
    }
  }

  Color _getStatusColor() {
    if (_status == null) return Colors.grey;
    switch (_status!.toLowerCase()) {
      case 'underweight':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_bmi != null)
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      )
                    else
                      const Text(
                        '--',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _status!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculateBMI(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculateBMI(),
            ),
            const SizedBox(height: 32),
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Categories:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Underweight: BMI < 18.5'),
                    Text('• Normal: BMI 18.5 - 24.9'),
                    Text('• Overweight: BMI 25 - 29.9'),
                    Text('• Obese: BMI ≥ 30'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

