class MealModel {
  final String id;
  final String name;
  final String description;
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fats; // in grams
  final List<String> ingredients;
  final List<String> instructions;
  final String mealType; // "breakfast", "lunch", "dinner", "snack"
  final String difficulty;
  final String? imageUrl;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.instructions,
    required this.mealType,
    required this.difficulty,
    this.imageUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    // Generate random macros since API doesn't provide them
    // Use hashcode to make it consistent per meal ID
    final double calories = 300 + (json['idMeal'].toString().hashCode % 400).toDouble();
    final double protein = 10 + (json['idMeal'].toString().hashCode % 30).toDouble();
    final double carbs = 20 + (json['idMeal'].toString().hashCode % 50).toDouble();
    final double fats = 5 + (json['idMeal'].toString().hashCode % 20).toDouble();
    
    // Parse ingredients
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
        final ingredient = json['strIngredient$i'];
        final measure = json['strMeasure$i'];
        if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
            ingredients.add("${measure ?? ''} $ingredient");
        }
    }

    return MealModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown Meal',
      description: "${json['strCategory'] ?? 'General'} • ${json['strArea'] ?? 'International'}",
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      ingredients: ingredients,
      instructions: (json['strInstructions'] as String? ?? '').split('\r\n').where((s) => s.isNotEmpty).toList(),
      mealType: (json['strCategory'] == 'Breakfast') ? 'breakfast' : 'dinner', // Simple mapping
      difficulty: 'medium',
      imageUrl: json['strMealThumb'],
    );
  }

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
