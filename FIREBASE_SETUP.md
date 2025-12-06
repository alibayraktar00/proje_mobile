# Firebase Setup Instructions

To enable authentication and cloud storage features in GYMBUDDY, you need to set up Firebase.

## Quick Setup (Recommended)

1. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```
   This will automatically:
   - Detect your Firebase projects
   - Generate `firebase_options.dart`
   - Configure your app

3. **Enable Authentication**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

4. **Create Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (for development)

## Manual Setup

If you prefer manual setup:

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Follow the setup wizard

2. **Add Android App**:
   - In Firebase Console, click "Add app" > Android
   - Enter package name: `com.example.gym_buddy_ali_try`
   - Download `google-services.json`
   - Place it in `android/app/`

3. **Update Android Build Files**:
   - Ensure `android/build.gradle` has:
     ```gradle
     dependencies {
         classpath 'com.google.gms:google-services:4.4.0'
     }
     ```
   - Ensure `android/app/build.gradle` has:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```

4. **Enable Authentication**:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

5. **Create Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode

## Testing

After setup, restart your app. You should be able to:
- Register new users
- Login with email/password
- Save user profiles to Firestore

## Troubleshooting

If you see "No Firebase App '[DEFAULT]' has been created":
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean` and `flutter pub get`
- Restart the app

If authentication doesn't work:
- Check that Email/Password is enabled in Firebase Console
- Verify your package name matches Firebase project settings
