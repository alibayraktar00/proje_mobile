import 'package:flutter/material.dart';
import '../../models/supplement_model.dart';

class SupplementDetailScreen extends StatelessWidget {
  final SupplementModel supplement;

  const SupplementDetailScreen({super.key, required this.supplement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(supplement.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medication,
                size: 64,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              supplement.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(supplement.category.toUpperCase()),
                  backgroundColor: Colors.purple.withOpacity(0.2),
                ),
                if (supplement.timing != null)
                  Chip(
                    label: Text(supplement.timing!),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              supplement.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (supplement.dosage != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.science, color: Colors.purple),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recommended Dosage',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              supplement.dosage!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Benefits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...supplement.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
            if (supplement.targetGoals != null && supplement.targetGoals!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Target Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supplement.targetGoals!.map((goal) => Chip(
                      label: Text(goal),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                    )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

