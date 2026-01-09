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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Colors.grey[900]!, Colors.black]
              : [Colors.blue.shade50, Colors.white],
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your BMI',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_bmi != null) ...[
                        Text(
                          _bmi!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _status?.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ] else
                        const Text(
                          '--',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // Height Input
                _buildModernInput(
                  controller: _heightController,
                  label: 'Height',
                  suffix: 'cm',
                  icon: Icons.height,
                  onChanged: (_) => _calculateBMI(),
                ),

                const SizedBox(height: 20),

                // Weight Input
                _buildModernInput(
                  controller: _weightController,
                  label: 'Weight',
                  suffix: 'kg',
                  icon: Icons.monitor_weight_outlined,
                  onChanged: (_) => _calculateBMI(),
                ),

                const SizedBox(height: 40),

                // Info Legend
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMI Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLegendItem('Underweight', '< 18.5', Colors.blue),
                      _buildLegendItem('Normal', '18.5 - 24.9', Colors.green),
                      _buildLegendItem('Overweight', '25 - 29.9', Colors.orange),
                      _buildLegendItem('Obese', '≥ 30', Colors.red),
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

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLegendItem(String label, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            range,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}


