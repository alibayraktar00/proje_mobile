import 'package:flutter/material.dart';

class MacroFilterScreen extends StatefulWidget {
  const MacroFilterScreen({super.key});

  @override
  State<MacroFilterScreen> createState() => _MacroFilterScreenState();
}

class _MacroFilterScreenState extends State<MacroFilterScreen> {
  final _minProteinController = TextEditingController();
  final _maxProteinController = TextEditingController();
  final _minCarbsController = TextEditingController();
  final _maxCarbsController = TextEditingController();
  final _minFatsController = TextEditingController();
  final _maxFatsController = TextEditingController();
  final _maxCaloriesController = TextEditingController();

  @override
  void dispose() {
    _minProteinController.dispose();
    _maxProteinController.dispose();
    _minCarbsController.dispose();
    _maxCarbsController.dispose();
    _minFatsController.dispose();
    _maxFatsController.dispose();
    _maxCaloriesController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final result = <String, double?>{
      'minProtein': double.tryParse(_minProteinController.text),
      'maxProtein': double.tryParse(_maxProteinController.text),
      'minCarbs': double.tryParse(_minCarbsController.text),
      'maxCarbs': double.tryParse(_maxCarbsController.text),
      'minFats': double.tryParse(_minFatsController.text),
      'maxFats': double.tryParse(_maxFatsController.text),
      'maxCalories': double.tryParse(_maxCaloriesController.text),
    };
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter by Macros'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Set your macro targets (leave empty for no limit)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minProteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Protein (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxProteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Protein (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCarbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Carbs (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxCarbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Carbs (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minFatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Fats (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxFatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Fats (g)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxCaloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Calories',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

