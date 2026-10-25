# 🌿 Habit Tracker — Flutter Mobile Application

A personal Habit Tracker Android application built with **Flutter 3**, **Dart**, **Riverpod**, **fl_chart**, **shared_preferences**, and **flutter_local_notifications**.

---

## 📱 Features

1. **Animated Loading Screen (SplashScreen)**
   - Logo animation with glowing pulse ring and elastic bounce.
   - App title ("Habit Tracker") with smooth slide-up and fade transition.
   - Inspirational daily motivational quotes.
   - Smooth curved transition into the main navigation screen.

2. **Emerald Green & White Aesthetic**
   - Palette tailored in lush emerald green (`#10B981`, `#059669`) and pure crisp white (`#FFFFFF`, `#F7FAF8`).
   - Deep Obsidian Forest dark theme (`#0B1410`).
   - High-contrast typography and subtle green card shadows.

3. **Floating Capsule Dock Navigation**
   - Pill-shaped bottom navigation bar with rounded corners.
   - Elevated soft shadow.
   - Five destinations: Home, My Habits, Notifications, Statistics, Settings.
   - Animated pill indicator on the active destination.
   - Real-time unread badge indicator on Notifications.

4. **Tactile Haptic Vibrations**
   - Haptic feedback when tapping bottom navigation destinations.
   - Celebratory vibration pulse when checking off habits.
   - Subtle tactile feedback on buttons, filters, chips, and modal operations.

5. **100% Offline-First Architecture**
   - Pre-seeded starter habits and completion logs on first install.
   - Instant response with zero loading timeouts.
   - Transparent background synchronization when the backend API is reachable.

---

## 🛠️ Build Release APK

To compile the Android release APK:
```bash
flutter build apk --release
```

The APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`
