import 'package:flutter/material.dart';
import '../../models/supplement_model.dart';

class SupplementDetailScreen extends StatelessWidget {
  final SupplementModel supplement;

  const SupplementDetailScreen({super.key, required this.supplement});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                supplement.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.purple, Colors.deepPurple[900]!],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.science_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagRow(context),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, "Description"),
                  Text(
                    supplement.description, 
                    style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.grey[300] : Colors.grey[800])
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(context, "Benefits"),
                  ...supplement.benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(benefit, style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  if (supplement.dosage != null) ...[
                     _buildInfoCard(
                      context, 
                      "Recommended Dosage", 
                      supplement.dosage!, 
                      Icons.medication_outlined, 
                      Colors.blue
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (supplement.timing != null) ...[
                    _buildInfoCard(
                      context, 
                      "Timing", 
                      supplement.timing!, 
                      Icons.access_time, 
                      Colors.orange
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          label: Text(supplement.category.toUpperCase()),
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        if (supplement.targetGoals != null)
          ...supplement.targetGoals!.map((goal) => Chip(
            label: Text(goal),
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
          )),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


