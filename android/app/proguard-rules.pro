# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter deferred components — Play Core split-install classes are referenced
# by the Flutter engine but not used in this app. Suppress the missing-class errors.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-dontwarn com.google.android.gms.**

# Keep AdMob mediation adapters if you add them later
-keep class com.google.ads.mediation.** { *; }
