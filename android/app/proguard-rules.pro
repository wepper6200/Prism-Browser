# R8 rules for Prism release builds.
#
# Plugins built with pigeon/jnigen call Kotlin/Java members by name through
# JNI. R8 cannot see those calls and strips the members, which crashes at
# startup (seen: NoSuchMethodError SharedPreferencesAsyncApiRegistrar.getAll
# -> runApp never ran -> ANR). Keep the plugin packages that are reached
# from Dart via JNI.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.github.dart_lang.jni.** { *; }

# Suspend functions bridged by package:jni resolve Kotlin runtime classes by
# name (seen one after another: kotlin.coroutines.intrinsics.
# CoroutineSingletons, kotlin.Result$Failure). Keep the Kotlin stdlib and
# coroutines whole instead of chasing them one by one (~1.5 MB).
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
