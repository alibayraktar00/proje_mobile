
import '../models/supplement_model.dart';

class SupplementService {
  static List<SupplementModel> getSupplementsByCategory(String category) {
    return _allSupplements
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  static List<SupplementModel> getSupplementsByGoal(String goal) {
    return _allSupplements
        .where((s) =>
            s.targetGoals?.any((g) => g.toLowerCase() == goal.toLowerCase()) ??
            false)
        .toList();
  }

  static List<SupplementModel> getAllSupplements() {
    return _allSupplements;
  }



  // --- Static Data ---

  static final List<SupplementModel> _allSupplements = [
    SupplementModel(
      id: '1',
      name: 'Whey Protein',
      description: 'Fast-absorbing protein derived from milk. Essential for muscle repair and growth.',
      category: 'Protein',
      benefits: [
        'Increases muscle mass and strength',
        'Improves recovery after workouts',
        'Reduces appetite and hunger levels'
      ],
      dosage: '20-25g post-workout',
      timing: 'Immediately after training or between meals',
      assetPath: 'assets/images/supp_whey.png',
      targetGoals: ['Build Muscle', 'Recovery', 'Lose Fat'],
    ),
    SupplementModel(
      id: '2',
      name: 'Creatine Monohydrate',
      description: 'Most researched supplement for strength and power output. Increases phosphocreatine stores in muscles.',
      category: 'Performance',
      benefits: [
        'Increases strength and power output',
        'Improves high-intensity exercise performance',
        'Enhances recovery and muscle volume'
      ],
      dosage: '3-5g daily',
      timing: 'Any time of day, consistently',
      assetPath: 'assets/images/supp_creatine.png',
      targetGoals: ['Build Muscle', 'Strength', 'Performance'],
    ),
    SupplementModel(
      id: '3',
      name: 'Pre-Workout (Caffeine)',
      description: 'Energy and performance enhancing supplement usually containing caffeine, beta-alanine, and citrulline.',
      category: 'Energy',
      benefits: [
        'Increases energy and focus',
        'Improves endurance and performance',
        'Reduces perceived exertion'
      ],
      dosage: '1 serving (check label for specific ingredients)',
      timing: '20-30 minutes before workout',
      assetPath: 'assets/images/supp_preworkout.png',
      targetGoals: ['Energy', 'Focus', 'Performance'],
    ),
    SupplementModel(
      id: '4',
      name: 'BCAAs',
      description: 'Branched-Chain Amino Acids (Leucine, Isoleucine, Valine).',
      category: 'Recovery',
      benefits: [
        'Reduces muscle soreness',
        'Prevents muscle breakdown',
        'Reduces fatigue during exercise'
      ],
      dosage: '5-10g during or after workout',
      timing: 'Intra-workout or Post-workout',
      assetPath: 'assets/images/supp_bcaa.png',
      targetGoals: ['Recovery', 'Endurance'],
    ),
    SupplementModel(
      id: '5',
      name: 'Casein Protein',
      description: 'Slow-digesting protein derived from milk.',
      category: 'Protein',
      benefits: [
        'Provides sustained release of amino acids',
        'Prevents muscle breakdown during sleep',
        'Promotes satiety'
      ],
      dosage: '20-30g before bed',
      timing: 'Before sleep',
      assetPath: 'assets/images/supp_casein.png',
      targetGoals: ['Build Muscle', 'Recovery'],
    ),
    SupplementModel(
      id: '6',
      name: 'Multivitamin',
      description: 'Blend of essential vitamins and minerals.',
      category: 'General Health',
      benefits: [
        'Fills nutritional gaps',
        'Supports overall health and immunity',
        'Improves natural energy levels'
      ],
      dosage: '1 serving daily',
      timing: 'With breakfast',
      assetPath: 'assets/images/supp_multivitamin.png',
      targetGoals: ['Health', 'Wellness'],
    ),
    SupplementModel(
      id: '7',
      name: 'Omega-3 Fish Oil',
      description: 'Essential fatty acids EPA and DHA.',
      category: 'General Health',
      benefits: [
        'Supports heart and brain health',
        'Reduces inflammation',
        'Supports joint health'
      ],
      dosage: '1-2g EPA/DHA daily',
      timing: 'With meals',
      assetPath: 'assets/images/supp_omega3.png',
      targetGoals: ['Health', 'Joints', 'Recovery'],
    ),
    SupplementModel(
      id: '8',
      name: 'Beta-Alanine',
      description: 'Amino acid that buffers acid in muscles.',
      category: 'Performance',
      benefits: [
        'Delays muscle fatigue',
        'Improves endurance in 1-4 min range',
        'Increases training volume'
      ],
      dosage: '2-5g daily',
      timing: 'Pre-workout',
      assetPath: 'assets/images/supp_betaalanine.png',
      targetGoals: ['Endurance', 'Performance'],
    ),
  ];
}
