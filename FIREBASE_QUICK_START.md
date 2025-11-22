# ⚡ Firebase Quick Start (2 Minutes)

## 🎯 Goal
Enable Firestore and deploy security rules so your app can sync data to Firebase.

## 📝 Steps

### 1. Enable Firestore (1 minute)

1. Go to: https://console.firebase.google.com/project/wellness-diary-81a92/firestore
2. Click **"Create database"** (if not already created)
3. Select **"Start in test mode"**
4. Choose location: `us-central1` (or closest to you)
5. Click **"Enable"**

### 2. Deploy Security Rules (1 minute)

**Option A: Using Firebase Console (Easiest)**

1. In Firestore, click **"Rules"** tab
2. Open `firestore.rules` file from this project
3. Copy all contents
4. Paste into Firebase Console rules editor
5. Click **"Publish"**

**Option B: Using Command Line**

```bash
# Windows
setup_firebase.bat

# Mac/Linux
./setup_firebase.sh

# Then deploy rules
firebase deploy --only firestore:rules
```

### 3. Test It! (30 seconds)

1. Run your app: `flutter run -d chrome`
2. Sign up or log in
3. Add a mood entry
4. Check Firebase Console → Firestore → Data
5. You should see: `users/{userId}/moods/{moodId}`

## ✅ Done!

Your app will now sync data to Firebase automatically.

## 🐛 Troubleshooting

**"Missing or insufficient permissions"**
→ Rules not deployed. Go to Step 2.

**"Firebase not initialized"**
→ Check `lib/firebase_options.dart` has correct config.

**Data not appearing**
→ Wait 10 seconds, refresh Firebase Console.

## 📚 Full Guide

See `FIREBASE_COMPLETE_SETUP.md` for detailed instructions.

