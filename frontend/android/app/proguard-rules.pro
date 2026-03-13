# Stripe
-keep class com.stripe.** { *; }
-keep interface com.stripe.** { *; }
-dontwarn com.stripe.**

-keep class com.reactnativestripesdk.** { *; }
-keep interface com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Google Sign-In / Google Play Services Auth
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Google API Client
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# Keep Google Sign-In plugin classes
-keep class io.flutter.plugins.googlesignin.** { *; }
