# Wellness Diary App

A modern, feature-rich Flutter application for tracking moods, health vitals, and medicine schedules. Built with a sleek UI/UX design perfect for modern hackathons.

## Features

### 🎭 Mood Tracking
- Log daily moods with 5 emotion levels (Excellent, Good, Okay, Bad, Terrible)
- Add notes and tags to mood entries
- Calendar view to visualize mood patterns
- Weekly mood statistics and insights
- Color-coded mood indicators

### ❤️ Health Vitals Tracking
- Track multiple vital types:
  - Heart Rate
  - Blood Pressure
  - Temperature
  - Weight
  - Blood Sugar
  - Oxygen Levels
  - Sleep Hours
  - Steps
- Interactive charts showing 7-day trends
- Statistics (Average, Min, Max) for each vital type
- Quick access to recent vital logs

### 💊 Medicine Schedule
- Schedule medicines with multiple times per day
- Set days of week for medication
- Medicine reminders with local notifications
- Track active/inactive medicines
- View upcoming medicines for the day
- Start and end date management

### 🏠 Dashboard
- Personalized greeting based on time of day
- Quick stats overview
- Today's summary cards
- Weekly insights and trends
- Dark mode support

## Design

- **Modern UI/UX**: Clean, minimalist design with smooth animations
- **Color Palette**: Mature, calming colors (soft blues, greens, purple accents)
- **Material Design 3**: Using latest Material Design principles
- **Responsive**: Works seamlessly across different screen sizes
- **Dark Mode**: Full dark mode support with system theme detection

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: Hive
- **Charts**: FL Chart
- **Notifications**: Flutter Local Notifications
- **Calendar**: Table Calendar
- **Fonts**: Google Fonts (Poppins)
- **Architecture**: MVVM pattern

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd wellness_diary
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── mood_model.dart
│   ├── health_vital_model.dart
│   └── medicine_model.dart
├── providers/                # State management
│   ├── mood_provider.dart
│   ├── health_vital_provider.dart
│   ├── medicine_provider.dart
│   └── theme_provider.dart
├── screens/                  # App screens
│   ├── home_screen.dart
│   ├── mood_tracking_screen.dart
│   ├── health_vitals_screen.dart
│   └── medicine_schedule_screen.dart
├── widgets/                  # Reusable widgets
│   ├── mood_selector.dart
│   ├── mood_summary_card.dart
│   ├── vitals_summary_card.dart
│   ├── medicine_summary_card.dart
│   ├── statistics_card.dart
│   ├── vital_type_selector.dart
│   └── vitals_chart.dart
└── utils/                    # Utilities
    ├── app_theme.dart
    └── notification_service.dart
```

## Key Features Implementation

### Data Persistence
- Uses Hive for local database storage
- All data is stored locally on the device
- No internet connection required

### Notifications
- Medicine reminders are scheduled using Flutter Local Notifications
- Recurring notifications based on medicine schedule
- Customizable notification times

### Charts & Visualization
- Interactive line charts for vital trends
- Color-coded mood indicators
- Weekly statistics visualization

## Future Enhancements

- Cloud sync and backup
- Export data to CSV/PDF
- Widget support for home screen
- Health data integration (HealthKit, Google Fit)
- Medication adherence tracking
- Advanced analytics and insights
- Multi-language support

## License

This project is created for hackathon purposes.

## Contributing

Contributions are welcome! Feel free to submit issues and enhancement requests.

