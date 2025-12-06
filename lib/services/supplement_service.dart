import '../models/supplement_model.dart';

class SupplementService {
  static List<SupplementModel> getSupplementsByCategory(String category) {
    return _allSupplements
        .where((supp) => supp.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  static List<SupplementModel> getSupplementsByGoal(String goal) {
    return _allSupplements
        .where((supp) =>
            supp.targetGoals?.any((g) => g.toLowerCase() == goal.toLowerCase()) ??
            false)
        .toList();
  }

  static List<SupplementModel> getAllSupplements() {
    return _allSupplements;
  }

  static final List<SupplementModel> _allSupplements = [
    SupplementModel(
      id: 'supp_1',
      name: 'Whey Protein',
      description: 'Fast-digesting protein powder ideal for post-workout recovery',
      category: 'post-workout',
      benefits: [
        'Promotes muscle recovery',
        'High in essential amino acids',
        'Quick absorption',
        'Supports muscle growth',
      ],
      dosage: '20-30g per serving',
      timing: 'after workout',
      targetGoals: ['muscle gain', 'recovery', 'strength'],
    ),
    SupplementModel(
      id: 'supp_2',
      name: 'Creatine Monohydrate',
      description: 'Most researched supplement for strength and power output',
      category: 'daily',
      benefits: [
        'Increases strength',
        'Improves power output',
        'Enhances muscle mass',
        'Supports high-intensity training',
      ],
      dosage: '3-5g daily',
      timing: 'any time of day',
      targetGoals: ['muscle gain', 'strength', 'power'],
    ),
    SupplementModel(
      id: 'supp_3',
      name: 'Pre-Workout',
      description: 'Energy and performance enhancing supplement',
      category: 'pre-workout',
      benefits: [
        'Increases energy',
        'Improves focus',
        'Enhances endurance',
        'Boosts workout performance',
      ],
      dosage: '1 scoop 30 minutes before workout',
      timing: 'before workout',
      targetGoals: ['endurance', 'performance', 'energy'],
    ),
    SupplementModel(
      id: 'supp_4',
      name: 'BCAA (Branched-Chain Amino Acids)',
      description: 'Essential amino acids for muscle preservation and recovery',
      category: 'during-workout',
      benefits: [
        'Reduces muscle fatigue',
        'Prevents muscle breakdown',
        'Speeds recovery',
        'Improves endurance',
      ],
      dosage: '5-10g during or after workout',
      timing: 'during or after workout',
      targetGoals: ['recovery', 'endurance', 'muscle preservation'],
    ),
    SupplementModel(
      id: 'supp_5',
      name: 'Omega-3 Fish Oil',
      description: 'Essential fatty acids for overall health and inflammation reduction',
      category: 'daily',
      benefits: [
        'Reduces inflammation',
        'Supports heart health',
        'Improves joint health',
        'Enhances brain function',
      ],
      dosage: '1-2g daily',
      timing: 'with meals',
      targetGoals: ['recovery', 'health', 'inflammation'],
    ),
    SupplementModel(
      id: 'supp_6',
      name: 'Vitamin D3',
      description: 'Essential vitamin for bone health and immune function',
      category: 'daily',
      benefits: [
        'Supports bone health',
        'Boosts immune system',
        'Improves mood',
        'Enhances muscle function',
      ],
      dosage: '1000-2000 IU daily',
      timing: 'morning with food',
      targetGoals: ['health', 'immune support', 'bone health'],
    ),
    SupplementModel(
      id: 'supp_7',
      name: 'Casein Protein',
      description: 'Slow-digesting protein ideal for nighttime recovery',
      category: 'daily',
      benefits: [
        'Slow release protein',
        'Prevents muscle breakdown',
        'Supports overnight recovery',
        'Promotes satiety',
      ],
      dosage: '20-40g before bed',
      timing: 'before bed',
      targetGoals: ['muscle gain', 'recovery', 'muscle preservation'],
    ),
    SupplementModel(
      id: 'supp_8',
      name: 'Beta-Alanine',
      description: 'Amino acid that buffers acid in muscles during high-intensity exercise',
      category: 'pre-workout',
      benefits: [
        'Increases endurance',
        'Delays muscle fatigue',
        'Improves high-intensity performance',
        'Enhances workout capacity',
      ],
      dosage: '2-5g daily',
      timing: 'before workout',
      targetGoals: ['endurance', 'performance', 'high-intensity training'],
    ),
  ];
}

