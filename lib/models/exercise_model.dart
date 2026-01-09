class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart; // Primary muscle
  final String description;
  final String? equipment;
  final String? target;
  final List<String>? secondaryMuscles;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final int? sets;
  final int? reps;
  final String? difficulty; // "beginner", "intermediate", "expert"

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.description,
    this.equipment,
    this.target,
    this.secondaryMuscles,
    this.videoUrl,
    this.imageUrl,
    required this.instructions,
    this.sets,
    this.reps,
    this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'description': description,
      'equipment': equipment,
      'target': target,
      'secondaryMuscles': secondaryMuscles,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'sets': sets,
      'reps': reps,
      'difficulty': difficulty,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      bodyPart: map['bodyPart'] ?? '',
      description: map['description'] ?? '',
      equipment: map['equipment'],
      target: map['target'],
      secondaryMuscles: map['secondaryMuscles'] != null ? List<String>.from(map['secondaryMuscles']) : null,
      videoUrl: map['videoUrl'],
      imageUrl: map['imageUrl'],
      instructions: List<String>.from(map['instructions'] ?? []),
      sets: map['sets'],
      reps: map['reps'],
      difficulty: map['difficulty'],
    );
  }

  // Old API (RapidAPI ExerciseDB) - kept for backward compatibility if needed, but not used now
  factory ExerciseModel.fromApi(Map<String, dynamic> map) {
    final descriptionFromApi = map['description'] as String?;
    final target = map['target'] as String?;
    final equipment = map['equipment'] as String?;
    var imageUrl = map['gifUrl'] as String?;
    if (imageUrl != null && imageUrl.startsWith('http://')) {
      imageUrl = imageUrl.replaceFirst('http://', 'https://');
    }
    final difficulty = map['difficulty'] as String? ?? 'Intermediate';
    
    return ExerciseModel(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? '',
      bodyPart: map['bodyPart'] ?? '',
      description: descriptionFromApi ?? '',
      equipment: equipment,
      target: target,
      secondaryMuscles: map['secondaryMuscles'] != null ? List<String>.from(map['secondaryMuscles']) : null,
      imageUrl: imageUrl,
      videoUrl: null,
      instructions: List<String>.from(map['instructions'] ?? []),
      sets: null,
      reps: null,
      difficulty: difficulty,
    );
  }

  // New Open Source DB (free-exercise-db)
  factory ExerciseModel.fromFreeDB(Map<String, dynamic> map) {
    // Map 'level' to 'difficulty'
    final difficulty = map['level'] as String? ?? 'intermediate';
    
    // Map 'primaryMuscles' (List) to 'bodyPart' (String) - take the first one
    final primaryMuscles = map['primaryMuscles'] as List<dynamic>?;
    final bodyPart = (primaryMuscles != null && primaryMuscles.isNotEmpty) 
        ? primaryMuscles.first.toString() 
        : 'General';

    // Construct Image URL
    // Base URL: https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/
    // Path in JSON: "Alternate_Incline_Dumbbell_Curl/0.jpg"
    final images = map['images'] as List<dynamic>?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      final imagePath = images.first.toString();
      imageUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$imagePath';
    }

    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      bodyPart: bodyPart, // Mapped from primaryMuscles[0]
      description: "Primary: ${primaryMuscles?.join(', ') ?? 'N/A'}",
      equipment: map['equipment'],
      target: primaryMuscles?.firstOrNull?.toString(), // Use primary muscle as target
      secondaryMuscles: map['secondaryMuscles'] != null ? List<String>.from(map['secondaryMuscles']) : null,
      imageUrl: imageUrl,
      videoUrl: null,
      instructions: List<String>.from(map['instructions'] ?? []),
      sets: null,
      reps: null,
      difficulty: difficulty,
    );
  }
}


