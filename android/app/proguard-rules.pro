# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase and other common plugins
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keep class com.yalantis.ucrop.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.**
