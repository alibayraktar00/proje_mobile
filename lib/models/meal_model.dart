class MealModel {
  final String id;
  final String name;
  final String description;
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fats; // in grams
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final String mealType; // "breakfast", "lunch", "dinner", "snack"
  final String? difficulty;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.mealType,
    this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'mealType': mealType,
      'difficulty': difficulty,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fats: (map['fats'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      mealType: map['mealType'] ?? '',
      difficulty: map['difficulty'],
    );
  }
}

