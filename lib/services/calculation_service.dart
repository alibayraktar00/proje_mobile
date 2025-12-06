class CalculationService {
  // BMI Calculation
  static double calculateBMI(double weightKg, double heightCm) {
    double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Calorie Estimation based on speed, incline, weight, and duration
  // Uses MET (Metabolic Equivalent of Task) values
  static double estimateCaloriesBurned({
    required double weightKg,
    required Duration duration,
    required double speedKmh, // speed in km/h
    double incline = 0.0, // incline percentage (0-15%)
    String activityType = 'running', // 'running', 'walking', 'cycling'
  }) {
    // Convert speed from km/h to m/s
    double speedMs = speedKmh / 3.6;

    // Base MET values (approximate)
    double baseMET = 0;
    if (activityType == 'running') {
      baseMET = 8.0 + (speedMs - 2.5) * 1.5; // Rough approximation
    } else if (activityType == 'walking') {
      baseMET = 3.0 + (speedMs - 1.0) * 1.0;
    } else if (activityType == 'cycling') {
      baseMET = 6.0 + (speedMs - 2.0) * 1.2;
    }

    // Adjust for incline (add 0.1 MET per 1% incline)
    double adjustedMET = baseMET + (incline * 0.1);

    // Ensure minimum MET value
    if (adjustedMET < 2.0) adjustedMET = 2.0;

    // Calculate calories: MET * weight(kg) * time(hours)
    double timeHours = duration.inMinutes / 60.0;
    double calories = adjustedMET * weightKg * timeHours;

    return calories;
  }

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    return bmr;
  }

  // Calculate daily calorie needs based on activity level
  static double calculateDailyCalorieNeeds({
    required double bmr,
    required String activityLevel, // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  }) {
    double multiplier = 1.2; // sedentary
    switch (activityLevel.toLowerCase()) {
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
    }
    return bmr * multiplier;
  }
}

