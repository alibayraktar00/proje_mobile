import '../models/meal_model.dart';

class NutritionService {
  // Sample meal data - In production, this would come from Firestore
  static List<MealModel> getMealsByType(String mealType) {
    return _allMeals
        .where((meal) => meal.mealType.toLowerCase() == mealType.toLowerCase())
        .toList();
  }

  static List<MealModel> filterMealsByMacros({
    double? minProtein,
    double? maxProtein,
    double? minCarbs,
    double? maxCarbs,
    double? minFats,
    double? maxFats,
    double? maxCalories,
  }) {
    return _allMeals.where((meal) {
      if (minProtein != null && meal.protein < minProtein) return false;
      if (maxProtein != null && meal.protein > maxProtein) return false;
      if (minCarbs != null && meal.carbs < minCarbs) return false;
      if (maxCarbs != null && meal.carbs > maxCarbs) return false;
      if (minFats != null && meal.fats < minFats) return false;
      if (maxFats != null && meal.fats > maxFats) return false;
      if (maxCalories != null && meal.calories > maxCalories) return false;
      return true;
    }).toList();
  }

  static List<MealModel> getMealsByCalorieRange(double minCal, double maxCal) {
    return _allMeals
        .where((meal) => meal.calories >= minCal && meal.calories <= maxCal)
        .toList();
  }

  static List<MealModel> getAllMeals() {
    return _allMeals;
  }

  static final List<MealModel> _allMeals = [
    // Breakfast Meals
    MealModel(
      id: 'breakfast_1',
      name: 'Greek Yogurt with Berries',
      description: 'High-protein breakfast with antioxidants',
      calories: 250,
      protein: 20,
      carbs: 30,
      fats: 5,
      ingredients: [
        '1 cup Greek yogurt',
        '1/2 cup mixed berries',
        '1 tbsp honey',
        '1/4 cup granola',
      ],
      instructions: [
        'Scoop Greek yogurt into bowl',
        'Top with fresh berries',
        'Drizzle with honey',
        'Add granola for crunch',
      ],
      mealType: 'breakfast',
      difficulty: 'easy',
    ),
    MealModel(
      id: 'breakfast_2',
      name: 'Protein Oatmeal',
      description: 'Fiber-rich breakfast with added protein',
      calories: 350,
      protein: 25,
      carbs: 45,
      fats: 8,
      ingredients: [
        '1 cup rolled oats',
        '1 scoop protein powder',
        '1 banana',
        '1 tbsp almond butter',
      ],
      instructions: [
        'Cook oats according to package',
        'Stir in protein powder',
        'Top with sliced banana',
        'Add almond butter',
      ],
      mealType: 'breakfast',
      difficulty: 'easy',
    ),
    MealModel(
      id: 'breakfast_3',
      name: 'Avocado Toast with Eggs',
      description: 'Balanced breakfast with healthy fats and protein',
      calories: 400,
      protein: 18,
      carbs: 35,
      fats: 20,
      ingredients: [
        '2 slices whole grain bread',
        '1 avocado',
        '2 eggs',
        'Salt and pepper',
      ],
      instructions: [
        'Toast bread slices',
        'Mash avocado and spread on toast',
        'Fry or poach eggs',
        'Place eggs on toast',
        'Season with salt and pepper',
      ],
      mealType: 'breakfast',
      difficulty: 'easy',
    ),

    // Lunch Meals
    MealModel(
      id: 'lunch_1',
      name: 'Grilled Chicken Salad',
      description: 'Lean protein with fresh vegetables',
      calories: 450,
      protein: 40,
      carbs: 25,
      fats: 20,
      ingredients: [
        '200g grilled chicken breast',
        'Mixed greens',
        'Cherry tomatoes',
        'Cucumber',
        'Olive oil dressing',
      ],
      instructions: [
        'Grill chicken breast and slice',
        'Prepare mixed greens',
        'Add vegetables',
        'Top with chicken',
        'Drizzle with dressing',
      ],
      mealType: 'lunch',
      difficulty: 'medium',
    ),
    MealModel(
      id: 'lunch_2',
      name: 'Quinoa Bowl with Salmon',
      description: 'Complete protein source with omega-3s',
      calories: 550,
      protein: 35,
      carbs: 50,
      fats: 22,
      ingredients: [
        '150g salmon fillet',
        '1 cup cooked quinoa',
        'Steamed broccoli',
        'Lemon',
        'Herbs',
      ],
      instructions: [
        'Cook quinoa according to package',
        'Bake or pan-sear salmon',
        'Steam broccoli',
        'Assemble bowl',
        'Squeeze lemon and add herbs',
      ],
      mealType: 'lunch',
      difficulty: 'medium',
    ),
    MealModel(
      id: 'lunch_3',
      name: 'Turkey Wrap',
      description: 'High-protein, portable lunch option',
      calories: 380,
      protein: 30,
      carbs: 40,
      fats: 12,
      ingredients: [
        'Whole wheat tortilla',
        '150g turkey slices',
        'Lettuce',
        'Tomato',
        'Hummus',
      ],
      instructions: [
        'Spread hummus on tortilla',
        'Add turkey slices',
        'Add vegetables',
        'Roll tightly',
        'Cut in half',
      ],
      mealType: 'lunch',
      difficulty: 'easy',
    ),

    // Dinner Meals
    MealModel(
      id: 'dinner_1',
      name: 'Lean Beef with Sweet Potato',
      description: 'Post-workout meal with complex carbs',
      calories: 600,
      protein: 45,
      carbs: 55,
      fats: 18,
      ingredients: [
        '200g lean beef',
        '1 large sweet potato',
        'Green beans',
        'Garlic',
        'Herbs',
      ],
      instructions: [
        'Roast sweet potato',
        'Cook beef to preference',
        'Steam green beans',
        'Season with garlic and herbs',
        'Plate and serve',
      ],
      mealType: 'dinner',
      difficulty: 'medium',
    ),
    MealModel(
      id: 'dinner_2',
      name: 'Baked Cod with Vegetables',
      description: 'Light, high-protein dinner',
      calories: 400,
      protein: 35,
      carbs: 30,
      fats: 15,
      ingredients: [
        '200g cod fillet',
        'Asparagus',
        'Bell peppers',
        'Olive oil',
        'Lemon',
      ],
      instructions: [
        'Preheat oven to 400°F',
        'Place cod on baking sheet',
        'Arrange vegetables around fish',
        'Drizzle with olive oil',
        'Bake for 15-20 minutes',
      ],
      mealType: 'dinner',
      difficulty: 'easy',
    ),

    // Snacks
    MealModel(
      id: 'snack_1',
      name: 'Protein Smoothie',
      description: 'Quick post-workout recovery drink',
      calories: 300,
      protein: 30,
      carbs: 35,
      fats: 5,
      ingredients: [
        '1 scoop protein powder',
        '1 banana',
        '1 cup almond milk',
        '1 tbsp peanut butter',
      ],
      instructions: [
        'Add all ingredients to blender',
        'Blend until smooth',
        'Serve immediately',
      ],
      mealType: 'snack',
      difficulty: 'easy',
    ),
    MealModel(
      id: 'snack_2',
      name: 'Apple with Almond Butter',
      description: 'Balanced snack with fiber and healthy fats',
      calories: 200,
      protein: 5,
      carbs: 25,
      fats: 10,
      ingredients: [
        '1 medium apple',
        '2 tbsp almond butter',
      ],
      instructions: [
        'Slice apple',
        'Serve with almond butter for dipping',
      ],
      mealType: 'snack',
      difficulty: 'easy',
    ),
  ];
}

