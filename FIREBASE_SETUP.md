# Firebase Setup Guide - Step by Step

This guide will help you set up Firebase for the Wellness Diary App with user-specific data storage.

## Prerequisites

1. A Google account
2. Flutter project already set up
3. Firebase account (free tier is sufficient)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `wellness-diary` (or any name you prefer)
4. Click **Continue**
5. Disable Google Analytics (optional - you can enable it later if needed)
6. Click **Create project**
7. Wait for project creation (takes ~30 seconds)
8. Click **Continue**

## Step 2: Enable Firestore Database

1. In Firebase Console, click on **"Build"** in the left sidebar
2. Click on **"Firestore Database"**
3. Click **"Create database"**
4. Select **"Start in test mode"** (for development)
5. Choose a Cloud Firestore location closest to your users (e.g., `us-central` for US)
6. Click **"Enable"**
7. Wait for database creation

## Step 3: Configure Firestore Security Rules (Important!)

1. In Firestore Database, click on **"Rules"** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public user profiles (read-only for other users)
    match /users/{userId}/profile {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User-specific collections
    match /users/{userId}/moods/{moodId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /users/{userId}/health_vitals/{vitalId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /users/{userId}/medicines/{medicineId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **"Publish"**

## Step 4: Get Firebase Configuration for Web

1. In Firebase Console, click the **gear icon** (⚙️) next to "Project Overview"
2. Click **"Project settings"**
3. Scroll down to **"Your apps"** section
4. Click the **Web icon** (`</>`)
5. Register app with nickname: `Wellness Diary Web`
6. Check **"Also set up Firebase Hosting"** (optional)
7. Click **"Register app"**
8. Copy the `firebaseConfig` object - it looks like:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  databaseURL: "https://your-project-default-rtdb.firebaseio.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

9. **IMPORTANT**: Save this configuration - you'll need it in the next step!

## Step 5: Add Firebase Config to Flutter App

1. In your Flutter project, create a new file: `lib/config/firebase_config.dart`

2. Add your Firebase configuration:

```dart
class FirebaseConfig {
  static const String apiKey = "YOUR_API_KEY";
  static const String authDomain = "YOUR_PROJECT.firebaseapp.com";
  static const String projectId = "YOUR_PROJECT_ID";
  static const String storageBucket = "YOUR_PROJECT.appspot.com";
  static const String messagingSenderId = "YOUR_SENDER_ID";
  static const String appId = "YOUR_APP_ID";
}
```

3. Replace all `YOUR_*` values with your actual Firebase config values from Step 4

## Step 6: Install Firebase CLI (Optional but Recommended)

For easier Firebase management:

1. Install Node.js from [nodejs.org](https://nodejs.org/)
2. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
3. Login to Firebase:
   ```bash
   firebase login
   ```

## Step 7: Initialize Firebase in Flutter

The app code will handle Firebase initialization. Make sure you've:

1. Added Firebase dependencies (already done in `pubspec.yaml`)
2. Created `firebase_config.dart` with your config
3. Run `flutter pub get`

## Step 8: Test Firebase Connection

1. Run your Flutter app:
   ```bash
   flutter run -d chrome
   ```

2. Sign up for a new account
3. Add a mood, health vital, or medicine
4. Check Firebase Console → Firestore Database to see if data appears under:
   - `users/{userId}/moods/`
   - `users/{userId}/health_vitals/`
   - `users/{userId}/medicines/`

## Firebase Data Structure

Your data will be organized as follows:

```
users/
  {userId}/
    moods/
      {moodId}/
        - id
        - mood
        - dateTime
        - note
        - tags
    health_vitals/
      {vitalId}/
        - id
        - type
        - value
        - dateTime
        - unit
        - note
    medicines/
      {medicineId}/
        - id
        - name
        - dosage
        - times
        - startDate
        - endDate
        - daysOfWeek
        - note
        - isActive
        - color
```

## Troubleshooting

### Error: "Firebase App named '[DEFAULT]' already exists"
- Solution: Make sure Firebase is initialized only once in `main.dart`

### Error: "MissingPluginException"
- Solution: Run `flutter clean` and `flutter pub get`, then rebuild

### Data not syncing
- Check Firestore Rules - make sure they allow your user to write
- Check browser console for errors
- Verify Firebase configuration is correct

### Can't see data in Firestore
- Make sure you're looking at the correct project
- Check Firestore Rules allow read access
- Verify user is authenticated

## Security Best Practices

1. **Never commit `firebase_config.dart` with real keys to public repositories**
2. Use environment variables or `.env` files in production
3. Regularly review and update Firestore Security Rules
4. Enable Firebase App Check for production
5. Use Firebase Authentication for better security (optional upgrade)

## Next Steps

After Firebase is set up:
1. Data will sync automatically across devices for the same user
2. Data persists even if app is uninstalled
3. Real-time updates when data changes
4. Each user has completely isolated data

For production:
- Enable Firebase Authentication
- Set up proper security rules
- Enable Firebase App Check
- Configure backup and retention policies

