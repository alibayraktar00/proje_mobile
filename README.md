# GYMBUDDY - Fitness Application

A comprehensive fitness application built with Flutter and Dart for Android, designed to guide users toward their fitness goals through workout, nutrition, and supplement management.

## Team Members

- **Ali Bayraktar** - Advanced Calculation Hub
- **Akın Aslanoğlu** - Personalized Nutrition Planning
- **Abdullah Enes Otlu** - Targeted Exercise Guides
- **Ahmet Safa Açıköz** - Secure User Onboarding

## Features

### 🔐 Secure User Onboarding
- User registration and login with Firebase Authentication
- Comprehensive profile setup (height, weight, age, gender)
- Secure data storage in Cloud Firestore

### 📊 Advanced Calculation Hub
- **BMI Calculator**: Calculate Body Mass Index with immediate status feedback (Underweight, Normal, Overweight, Obese)
- **Cardio Stopwatch**: Full-featured stopwatch with Start, Stop, and Reset functionality
- **Calorie Estimation**: Real-time calorie burn estimation based on:
  - Speed (km/h)
  - Incline percentage
  - Activity type (Running, Walking, Cycling)
  - Personal metrics (weight, height, age)
  - Uses MET (Metabolic Equivalent of Task) values for accuracy

### 💪 Targeted Exercise Guides
- Exercise recommendations by body part (Abs, Legs, Arms, Chest, Back)
- Detailed execution instructions with step-by-step guides
- Visual guides and video integration support
- Difficulty levels (Beginner, Intermediate, Advanced)
- Sets and reps recommendations

### 🍎 Personalized Nutrition Planning
- Healthy meal suggestions tailored to user's calorie goals and BMI
- Filterable by meal type (Breakfast, Lunch, Dinner, Snack)
- Macro filtering (Protein, Carbs, Fats, Calories)
- Detailed nutritional information
- Ingredients and cooking instructions

### 💊 Supplementation Recommendations
- Tailored supplement suggestions based on training goals
- Filterable by category (Pre-workout, Post-workout, Daily, During-workout)
- Filterable by goals (Muscle Gain, Weight Loss, Endurance, Recovery, Strength)
- Detailed dosage and timing information
- Benefits and target goals for each supplement

## Technologies

- **Framework**: Flutter / Dart
- **State Management**: Riverpod
- **Backend/Cloud**: Firebase (Authentication & Firestore)
- **Local Database**: Hive (for workout history and offline functionality)

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── exercise_model.dart
│   ├── meal_model.dart
│   ├── supplement_model.dart
│   └── workout_session_model.dart
├── services/            # Business logic services
│   ├── auth_service.dart
│   ├── calculation_service.dart
│   ├── exercise_service.dart
│   ├── nutrition_service.dart
│   ├── supplement_service.dart
│   └── hive_service.dart
├── providers/           # Riverpod state providers
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   └── workout_provider.dart
├── screens/             # UI screens
│   ├── auth/            # Authentication screens
│   ├── home/            # Main navigation
│   ├── calculations/    # BMI, Stopwatch, Calorie Estimation
│   ├── exercises/        # Exercise guides
│   ├── nutrition/        # Meal planning
│   ├── supplements/      # Supplement recommendations
│   └── profile/          # User profile management
└── main.dart            # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase project configured

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gym_buddy_ali_try
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Download `google-services.json` and place it in `android/app/`
   - For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

1. **First Time Setup**
   - Register a new account or login
   - Complete your profile with height, weight, age, and gender

2. **Using Calculations**
   - Navigate to the Calculations tab
   - Use BMI Calculator to check your body mass index
   - Use Cardio Stopwatch to track your workout sessions
   - Use Calorie Estimation to estimate calories burned

3. **Exercise Guides**
   - Browse exercises by body part
   - View detailed instructions and recommendations
   - Follow step-by-step guides

4. **Nutrition Planning**
   - Browse meals by type or filter by macros
   - View detailed nutritional information
   - Get ingredients and cooking instructions

5. **Supplements**
   - Browse supplements by category or goal
   - View detailed information about dosage and timing
   - Understand benefits for your fitness goals

## Development Timeline

- **Phase 1**: Planning & Setup (2 weeks) ✅
- **Phase 2**: Core Functionality (3 weeks) ✅
- **Phase 3**: Content Integration (4 weeks) ✅
- **Phase 4**: Testing & Deployment (3 weeks) - In Progress

## Future Enhancements

- Video integration for exercise guides
- Workout history tracking and analytics
- Social features and sharing
- Integration with fitness wearables
- Meal planning calendar
- Progress photos and measurements tracking

## License

This project is developed for educational purposes.

## Contact

For questions or support, please contact the development team.
