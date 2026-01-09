import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import '../models/meal_model.dart';
import 'package:gym_buddy_ali_try/models/meal_model.dart';

class NutritionApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<MealModel>> getMeals() async {
    // Default to Chicken for high protein/sports focus
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=chicken'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];
        
        if (meals != null) {
          final allMeals = meals.map((json) => MealModel.fromJson(json)).toList();
          return _filterHealthyMeals(allMeals);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      return [];
    }
  }

  Future<List<MealModel>> getMealsByType(String type) async {
    // Optimizing for Sports Nutrition: Use Search to get full details and high protein items
    String query = 'chicken';
    bool useFilter = false;

    switch (type.toLowerCase()) {
      case 'breakfast': 
        query = 'egg'; // Eggs are essential for sports breakfast
        break;
      case 'lunch': 
        query = 'chicken'; // Lean protein for lunch
        break;
      case 'dinner': 
        query = 'beef'; // Red meat/Steak for dinner
        break;
      case 'snack': 
        query = 'seafood'; // Lighter options or use a category
        useFilter = true; // Use filter for variety if search is too narrow
        break;
      default: 
        query = 'chicken';
    }

    try {
      final String url = useFilter 
          ? '$_baseUrl/filter.php?c=Seafood' 
          : '$_baseUrl/search.php?s=$query';
          
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];
        
        if (meals != null) {
          final allMeals = meals.map((json) => MealModel.fromJson(json)).toList();
          return _filterHealthyMeals(allMeals);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching meals by type: $e');
      return [];
    }
  }
  
  // Helper removed as we are implementing direct mapping above

  List<MealModel> _filterHealthyMeals(List<MealModel> meals) {
    final unhealthyKeywords = [
      'fried', 'burger', 'pie', 'cake', 'sugar', 'choco', 'dessert', 'cream', 
      'pork', 'sausage', 'bacon', 'jam', 'sweet', 'donut', 'tart'
    ];
    
    return meals.where((meal) {
      final nameLower = meal.name.toLowerCase();
      for (final keyword in unhealthyKeywords) {
        if (nameLower.contains(keyword)) return false;
      }
      return true;
    }).toList();
  }

  Future<List<MealModel>> filterMeals({
    double? minProtein,
    double? maxProtein,
    double? minCarbs,
    double? maxCarbs,
    double? minFats,
    double? maxFats,
    double? maxCalories,
  }) async {
    // Since API doesn't support macro filtering, we fetch all (or a subset) and filter locally.
    final allMeals = await getMeals();
    
    return allMeals.where((meal) {
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
}
