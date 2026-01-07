plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase eklentisini aktif eder
    id("com.google.gms.google-services")
}

android {
    // BURAYI KONTROL ET: Firebase konsolundaki paket adınla aynı olmalı
    namespace = "com.example.gym_buddy_ali_try"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // BURAYI KONTROL ET: Firebase'e kaydettiğin uygulama kimliği
        applicationId = "com.example.gym_buddy_ali_try"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Buraya manuel bir şey eklemene gerek yok, pubspec.yaml yeterlidir.
}