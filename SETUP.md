# Wellness Diary App - Setup Guide

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

## Installation Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Hive Adapters

The app uses Hive for local storage. You need to generate the adapter files:

**On Windows:**
```bash
build_runner.bat
```

**On macOS/Linux:**
```bash
chmod +x build_runner.sh
./build_runner.sh
```

**Or manually:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the following files:
- `lib/models/mood_model.g.dart`
- `lib/models/health_vital_model.g.dart`
- `lib/models/medicine_model.g.dart`

### 3. Run the App

```bash
flutter run
```

## Features Overview

### 🎭 Mood Tracking
- Log daily moods (Excellent, Good, Okay, Bad, Terrible)
- Add notes to mood entries
- Calendar view with mood patterns
- Weekly statistics

### ❤️ Health Vitals
- Track 8 different vital types
- Interactive charts showing 7-day trends
- Statistics (Average, Min, Max)
- Quick vital logging

### 💊 Medicine Schedule
- Schedule medicines with multiple times per day
- Set specific days of week
- Automatic reminder notifications
- Track active/inactive medicines

### 🏠 Dashboard
- Personalized greeting
- Quick stats overview
- Today's summary cards
- Weekly insights

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Hive)
├── providers/                # State management (Provider)
├── screens/                  # App screens
├── widgets/                  # Reusable widgets
└── utils/                    # Utilities (theme, notifications)
```

## Important Notes

### Permissions

**Android:**
- Internet (for app functionality)
- Notifications (for medicine reminders)
- Exact alarm (for precise scheduling)

**iOS:**
- Notifications (requires user permission)

### Data Storage

- All data is stored locally using Hive
- No internet connection required
- Data persists across app restarts

### Notifications

- Medicine reminders are scheduled using Flutter Local Notifications
- Notifications will work after app restart if permissions are granted

## Troubleshooting

### Hive Adapter Generation Errors

If you encounter errors when generating Hive adapters:

1. Make sure all dependencies are installed: `flutter pub get`
2. Clean build: `flutter clean`
3. Delete generated files manually (if any): Remove all `.g.dart` files
4. Run build runner again: `flutter pub run build_runner build --delete-conflicting-outputs`

### Notification Issues

If notifications don't work:

1. Check app permissions in device settings
2. Make sure notification service is initialized in `main.dart`
3. For Android, ensure exact alarm permission is granted (Android 12+)

### Build Errors

If you encounter build errors:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Try building again: `flutter run`

## Next Steps

1. Customize the color scheme in `lib/utils/app_theme.dart`
2. Add more vital types in `lib/models/health_vital_model.dart`
3. Extend notification features in `lib/utils/notification_service.dart`
4. Add more features as needed!

## License

This project is created for hackathon purposes.

