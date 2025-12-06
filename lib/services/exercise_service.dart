import '../models/exercise_model.dart';

class ExerciseService {
  // Sample exercise data - In production, this would come from Firestore
  static List<ExerciseModel> getExercisesByBodyPart(String bodyPart) {
    return _allExercises
        .where((exercise) => exercise.bodyPart.toLowerCase() == bodyPart.toLowerCase())
        .toList();
  }

  static List<String> getAvailableBodyParts() {
    return _allExercises.map((e) => e.bodyPart).toSet().toList();
  }

  static List<ExerciseModel> getAllExercises() {
    return _allExercises;
  }

  static final List<ExerciseModel> _allExercises = [
    // Abs Exercises
    ExerciseModel(
      id: 'abs_1',
      name: 'Crunches',
      bodyPart: 'abs',
      description: 'Classic abdominal exercise targeting the rectus abdominis',
      instructions: [
        'Lie on your back with knees bent and feet flat on the floor',
        'Place hands behind your head or across your chest',
        'Lift your shoulders off the ground, contracting your abs',
        'Lower back down slowly',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 15,
      difficulty: 'beginner',
    ),
    ExerciseModel(
      id: 'abs_2',
      name: 'Plank',
      bodyPart: 'abs',
      description: 'Isometric core exercise that strengthens the entire core',
      instructions: [
        'Start in push-up position',
        'Keep your body in a straight line from head to heels',
        'Hold the position, engaging your core',
        'Breathe normally',
        'Hold for 30-60 seconds',
      ],
      sets: 3,
      reps: 1,
      difficulty: 'beginner',
    ),
    ExerciseModel(
      id: 'abs_3',
      name: 'Russian Twists',
      bodyPart: 'abs',
      description: 'Rotational core exercise targeting obliques',
      instructions: [
        'Sit on the floor with knees bent',
        'Lean back slightly, keeping back straight',
        'Rotate torso side to side',
        'Keep core engaged throughout',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 20,
      difficulty: 'intermediate',
    ),

    // Legs Exercises
    ExerciseModel(
      id: 'legs_1',
      name: 'Squats',
      bodyPart: 'legs',
      description: 'Fundamental lower body exercise targeting quads, glutes, and hamstrings',
      instructions: [
        'Stand with feet shoulder-width apart',
        'Lower your body as if sitting in a chair',
        'Keep knees behind toes',
        'Go down until thighs are parallel to floor',
        'Push back up to starting position',
      ],
      sets: 4,
      reps: 12,
      difficulty: 'beginner',
    ),
    ExerciseModel(
      id: 'legs_2',
      name: 'Lunges',
      bodyPart: 'legs',
      description: 'Unilateral leg exercise for strength and balance',
      instructions: [
        'Step forward with one leg',
        'Lower your body until both knees are at 90 degrees',
        'Push back to starting position',
        'Alternate legs',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 12,
      difficulty: 'beginner',
    ),
    ExerciseModel(
      id: 'legs_3',
      name: 'Leg Press',
      bodyPart: 'legs',
      description: 'Machine-based exercise for quadriceps and glutes',
      instructions: [
        'Sit in leg press machine',
        'Place feet shoulder-width apart on platform',
        'Lower weight by bending knees',
        'Push platform away until legs are extended',
        'Repeat for desired reps',
      ],
      sets: 4,
      reps: 10,
      difficulty: 'intermediate',
    ),

    // Arms Exercises
    ExerciseModel(
      id: 'arms_1',
      name: 'Bicep Curls',
      bodyPart: 'arms',
      description: 'Isolation exercise for biceps',
      instructions: [
        'Stand holding dumbbells at your sides',
        'Keep elbows close to your body',
        'Curl weights up to shoulders',
        'Lower slowly with control',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 12,
      difficulty: 'beginner',
    ),
    ExerciseModel(
      id: 'arms_2',
      name: 'Tricep Dips',
      bodyPart: 'arms',
      description: 'Bodyweight exercise targeting triceps',
      instructions: [
        'Sit on edge of bench or chair',
        'Place hands next to hips',
        'Slide forward and lower body',
        'Push back up using triceps',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 10,
      difficulty: 'intermediate',
    ),
    ExerciseModel(
      id: 'arms_3',
      name: 'Push-ups',
      bodyPart: 'arms',
      description: 'Compound exercise for chest, shoulders, and triceps',
      instructions: [
        'Start in plank position',
        'Lower body until chest nearly touches floor',
        'Push back up to starting position',
        'Keep body straight throughout',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 12,
      difficulty: 'beginner',
    ),

    // Chest Exercises
    ExerciseModel(
      id: 'chest_1',
      name: 'Bench Press',
      bodyPart: 'chest',
      description: 'Classic chest exercise for pectoral muscles',
      instructions: [
        'Lie on bench with feet flat on floor',
        'Grip bar slightly wider than shoulder-width',
        'Lower bar to chest with control',
        'Push bar up explosively',
        'Repeat for desired reps',
      ],
      sets: 4,
      reps: 8,
      difficulty: 'intermediate',
    ),
    ExerciseModel(
      id: 'chest_2',
      name: 'Dumbbell Flyes',
      bodyPart: 'chest',
      description: 'Isolation exercise for chest muscles',
      instructions: [
        'Lie on bench holding dumbbells above chest',
        'Lower weights in arc motion',
        'Feel stretch in chest',
        'Bring weights back together',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 12,
      difficulty: 'intermediate',
    ),

    // Back Exercises
    ExerciseModel(
      id: 'back_1',
      name: 'Pull-ups',
      bodyPart: 'back',
      description: 'Upper body compound exercise for back and biceps',
      instructions: [
        'Hang from pull-up bar with palms facing away',
        'Pull body up until chin clears bar',
        'Lower with control',
        'Keep core engaged',
        'Repeat for desired reps',
      ],
      sets: 3,
      reps: 8,
      difficulty: 'advanced',
    ),
    ExerciseModel(
      id: 'back_2',
      name: 'Bent-Over Rows',
      bodyPart: 'back',
      description: 'Compound exercise for latissimus dorsi and rhomboids',
      instructions: [
        'Bend forward at hips, keeping back straight',
        'Pull weights to lower chest',
        'Squeeze shoulder blades together',
        'Lower with control',
        'Repeat for desired reps',
      ],
      sets: 4,
      reps: 10,
      difficulty: 'intermediate',
    ),
  ];
}

