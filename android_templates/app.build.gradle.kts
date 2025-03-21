plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "{{ApplicationId}}"
    compileSdk = {{AndroidApiVersion.b}}

    defaultConfig {
        applicationId = "{{ApplicationId}}"
        minSdk = {{AndroidApiVersion.a}}
        targetSdk = {{AndroidApiVersion.b}}
        versionCode = {{AppVersionCode}}
        versionName = "{{AppVersionName}}"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildFeatures {
        prefab = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.google.android.gms:play-services-ads:23.6.0")
}