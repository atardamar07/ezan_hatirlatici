import java.io.FileInputStream
import java.util.Properties


plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 'com.android.library' bu dosyada uygulanmaz, bu yüzden 'apply false' doğru.
    // Ancak bu eklenti burada tanımlı olmak zorunda değil. Yine de zararı yok.
    id("com.android.library") apply false
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

    android {
        namespace = "com.example.ezan_hatirlatici"
        compileSdk = 36
        ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // ✅ Java versiyonunu 11 olarak ayarlıyoruz.
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // ✅ Kotlin için JVM hedef versiyonunu 11 olarak ayarlıyoruz.
    kotlinOptions {
        jvmTarget = "11"
    }

    // ✅ Tüm Java derleme görevlerine bu ayarları uygulayarak uyarıları bastırıyoruz.
    tasks.withType<JavaCompile> {
        sourceCompatibility = "11"
        targetCompatibility = "11"
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }

    // ✅ Tüm Kotlin derleme görevlerine bu ayarları uyguluyoruz.
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions.jvmTarget = "11"
    }

        defaultConfig {
            applicationId = "com.example.ezan_hatirlatici"
            minSdk = flutter.minSdkVersion
            targetSdk = 36
            versionCode = flutter.versionCode
            versionName = flutter.versionName

            // Google Mobile Ads SDK'nin MobileAdsInitProvider'ı uygulama açılışında
            // doğru çalışabilmesi için AdMob uygulama kimliğini manifest placeholder
            // olarak sağlıyoruz. (AdMob uygulama kimliği olmadan sağlayıcı çöküyor.)
            manifestPlaceholders["ADMOB_APP_ID"] = "ca-app-pub-1498129057551982~3865121210"
        }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Bu satır artık gerekli olmayabilir, Gradle bunu otomatik yönetir.
    // İsterseniz silebilirsiniz, sorun çıkarırsa geri eklersiniz.
    buildToolsVersion = "36.1.0"

}

flutter {
    source = "../.."
}

dependencies {
    // En güncel desugaring kütüphanesi
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
