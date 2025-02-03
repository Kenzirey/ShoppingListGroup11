# English & Norwegian uses the same latin text.
-keep class com.google.mlkit.vision.text.latin.LatinTextRecognizerOptions { *; }

# Remove other language models (Chinese, Japanese, Korean, Devanagari)
-keep class com.google.mlkit.vision.text.** { *; }
-assumenosideeffects class com.google.mlkit.vision.text.** { *; }

# Ignore the warnings
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-ignorewarnings
