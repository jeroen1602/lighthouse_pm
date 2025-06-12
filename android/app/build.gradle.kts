import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val home: String = System.getProperty("user.home")
val keystoreProperties = Properties()
val keystorePropertiesFile = File("$home/android-keys/key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val storeFile = keystoreProperties["storeFile"] as String?
if (storeFile != null && storeFile.contains("~")) {
    keystoreProperties["storeFile"] = storeFile.replace("~", home)
}

android {
    namespace = "com.jeroen1602.lighthouse_pm"
    compileSdk = 35.coerceAtLeast(flutter.compileSdkVersion)
    ndkVersion = "27.2.12479018" // TODO use this: flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main").java.srcDir("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.jeroen1602.lighthouse_pm"
        minSdk = 21.coerceAtLeast(flutter.minSdkVersion)
        targetSdk = 36.coerceAtLeast(flutter.compileSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            if (keystoreProperties["keyAlias"] == null) {
                println("WARNING: Release keystore has not been found! Building release builds will be impossible!")
                println("Keystore properties should be located at: `${keystorePropertiesFile}`.")
                println("Go to `android/app/build.gradle` to change this if needed!")
            } else {
                val storeFileProperty = keystoreProperties["storeFile"] as String?

                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = if (storeFileProperty != null) {
                    File(storeFileProperty)
                } else {
                    null
                }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            ndk {
                abiFilters.addAll(arrayOf("armeabi-v7a", "arm64-v8a", "x86_64"))
            }
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
    lint {
        //TODO: check to see if this can be removed in future versions, since a lint for release builds is useful
        checkReleaseBuilds = true
        disable.add("InvalidPackage")
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.21")
}
