class SupplementModel {
  final String id;
  final String name;
  final String description;
  final String category; // "pre-workout", "post-workout", "daily", "protein", etc.
  final List<String> benefits;
  final String? dosage;
  final String? timing; // "morning", "before workout", "after workout", etc.
  final String? assetPath; // Path to local asset image
  final List<String>? targetGoals; // ["muscle gain", "weight loss", "endurance", etc.]

  SupplementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.benefits,
    this.dosage,
    this.timing,
    this.assetPath,
    this.targetGoals,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'benefits': benefits,
      'dosage': dosage,
      'timing': timing,
      'assetPath': assetPath,
      'targetGoals': targetGoals,
    };
  }

  factory SupplementModel.fromMap(Map<String, dynamic> map) {
    return SupplementModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      benefits: List<String>.from(map['benefits'] ?? []),
      dosage: map['dosage'],
      timing: map['timing'],
      assetPath: map['assetPath'],
      targetGoals: map['targetGoals'] != null
          ? List<String>.from(map['targetGoals'])
          : null,
    );
  }
}


