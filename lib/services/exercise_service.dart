import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseService {
  // Free Exercise DB (Open Source)
  static const String _dataUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';
  
  static List<ExerciseModel>? _cachedExercises;

  /// Fetches all exercises from the open source DB.
  /// Caches the result in memory to avoid repeated large downloads.
  static Future<List<ExerciseModel>> _getAllExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      final response = await http.get(Uri.parse(_dataUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load exercises (${response.statusCode})');
      }

      final List<dynamic> data = json.decode(response.body);
      _cachedExercises = data.map((e) => ExerciseModel.fromFreeDB(e)).toList();
      return _cachedExercises!;
    } catch (e) {
      throw Exception('Error fetching exercises: $e');
    }
  }

  /// Filters exercises based on body part (primary muscle) and/or equipment.
  static Future<List<ExerciseModel>> fetchExercises({
    List<String>? bodyParts, // Now supports multiple possibilities for a category
    String? equipment,
    int limit = 50,
  }) async {
    // Ensure we have the data
    var allExercises = await _getAllExercises();

    // Filter by Body Part (Muscle)
    // The "bodyPart" argument here might be a list of muscles relevant to a category (e.g. Back -> lats, middle back)
    if (bodyParts != null && bodyParts.isNotEmpty) {
      allExercises = allExercises.where((ex) {
        // ex.bodyPart comes from primaryMuscles[0]. 
        // We check if it is in our allowed list.
        return bodyParts.contains(ex.bodyPart.toLowerCase());
      }).toList();
    }

    // Filter by Equipment
    if (equipment != null && equipment.isNotEmpty) {
      allExercises = allExercises.where((ex) {
        return ex.equipment?.toLowerCase() == equipment.toLowerCase();
      }).toList();
    }

    // Shuffle for variety if no search query? (Optional, but good for "discovery")
    // For now we just take the first N
    if (limit > 0 && allExercises.length > limit) {
      return allExercises.take(limit).toList();
    }

    return allExercises;
  }
}


