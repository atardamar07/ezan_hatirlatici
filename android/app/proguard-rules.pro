# flutter_local_notifications zamanlanmış bildirimleri Gson ile saklar; R8 modelleri/generic
# bilgisini silerse bildirimler okunamaz ("Missing type parameter"). Kurallar: eklentinin README'si
# ve Gson'un android-proguard-example dosyası.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
