# 🔥 Complete Firebase & Firestore Setup Guide

This guide will help you set up Firebase and Firestore completely for your Wellness Diary app.

## 📋 Prerequisites

- ✅ Google account
- ✅ Firebase project already created: `wellness-diary-81a92`
- ✅ Flutter project configured with Firebase

## 🚀 Quick Start (5 Minutes)

### Step 1: Enable Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **wellness-diary-81a92**
3. Click **"Build"** → **"Firestore Database"** in the left sidebar
4. If not already enabled, click **"Create database"**
5. Choose **"Start in test mode"** (we'll update rules next)
6. Select a location closest to your users (e.g., `us-central1`)
7. Click **"Enable"** and wait for database creation

### Step 2: Deploy Firestore Security Rules

**Option A: Using Firebase Console (Easiest)**

1. In Firestore Database, click on **"Rules"** tab
2. Copy the contents of `firestore.rules` file from this project
3. Paste into the rules editor
4. Click **"Publish"**

**Option B: Using Firebase CLI (Recommended for Production)**

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### Step 3: Verify Setup

1. Run your Flutter app:
   ```bash
   flutter run -d chrome
   ```

2. Sign up or log in to your app
3. Add a mood, health vital, or medicine
4. Check Firebase Console → Firestore Database
5. You should see data under: `users/{userId}/moods/`, `users/{userId}/health_vitals/`, etc.

## 🔒 Security Rules Explained

### Current Rules (Development Mode)

The current rules in `firestore.rules` allow access based on `userId` in the path. This works with your local authentication system:

```javascript
match /users/{userId}/{document=**} {
  allow read, write: if userId != null && userId != '';
}
```

**Pros:**
- ✅ Works immediately with your current local auth
- ✅ No additional setup required
- ✅ Good for development/testing

**Cons:**
- ⚠️ Less secure (relies on client-provided userId)
- ⚠️ Not suitable for production without additional validation

### Production Rules (Firebase Authentication)

For production, you should use Firebase Authentication. See the **Firebase Authentication Setup** section below.

## 🔐 Firebase Authentication Setup (Optional but Recommended)

### Why Use Firebase Authentication?

- ✅ More secure (server-side validation)
- ✅ Better user management
- ✅ Password reset functionality
- ✅ Email verification
- ✅ OAuth providers (Google, Apple, etc.)

### Step 1: Enable Authentication

1. In Firebase Console, go to **"Build"** → **"Authentication"**
2. Click **"Get started"**
3. Click on **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

### Step 2: Update Flutter Dependencies

Add Firebase Auth to `pubspec.yaml`:

```yaml
dependencies:
  firebase_auth: ^5.0.0  # Add this line
```

Run:
```bash
flutter pub get
```

### Step 3: Update Auth Provider

You'll need to update `lib/providers/auth_provider.dart` to use Firebase Auth instead of local auth. This is a larger change that requires:

1. Import Firebase Auth
2. Replace local signup/login with Firebase Auth methods
3. Use `FirebaseAuth.instance.currentUser?.uid` as userId

**Note:** This is optional. Your app works fine with local auth for now.

## 📁 Project Structure

Your Firebase project is already configured:

```
wellness-diary-81a92/
├── Firestore Database
│   └── users/
│       └── {userId}/
│           ├── moods/
│           ├── health_vitals/
│           └── medicines/
├── Authentication (optional)
└── Storage (not used yet)
```

## 🧪 Testing Your Setup

### Test 1: Check Firebase Initialization

1. Run the app
2. Check console for: `✅ Firebase initialized successfully`
3. If you see this, Firebase is working!

### Test 2: Test Data Sync

1. Add a mood entry
2. Check Firestore Console → Data tab
3. Navigate to: `users/{yourUserId}/moods/{moodId}`
4. You should see the mood data

### Test 3: Test Real-time Sync

1. Open app on two devices/browsers
2. Add data on one device
3. Data should appear on the other device (if using same userId)

## 🐛 Troubleshooting

### Error: "Missing or insufficient permissions"

**Solution:**
1. Check Firestore Rules are deployed
2. Verify rules allow your userId format
3. Check Firebase Console → Firestore → Rules tab

### Error: "Firebase not initialized"

**Solution:**
1. Check `lib/firebase_options.dart` has correct config
2. Verify Firebase project exists
3. Run `flutter clean && flutter pub get`

### Data Not Syncing

**Check:**
1. Firebase Console → Firestore → Data tab (is data there?)
2. Browser console for errors
3. Network tab for failed requests
4. Verify userId is being passed correctly

### Rules Not Updating

**Solution:**
1. Wait 1-2 minutes after publishing rules
2. Clear browser cache
3. Try incognito mode
4. Verify rules syntax is correct

## 📊 Monitoring & Analytics

### View Data in Firebase Console

1. Go to Firebase Console → Firestore Database
2. Click "Data" tab
3. Browse your collections: `users/{userId}/moods`, etc.

### View Usage Statistics

1. Firebase Console → Firestore Database
2. Click "Usage" tab
3. See read/write operations, storage used

## 🚀 Production Checklist

Before going to production:

- [ ] Switch to Production Firestore Rules (with Firebase Auth)
- [ ] Enable Firebase Authentication
- [ ] Set up proper error handling
- [ ] Enable Firebase App Check (prevents abuse)
- [ ] Set up backup and retention policies
- [ ] Monitor usage and costs
- [ ] Set up alerts for unusual activity
- [ ] Review security rules regularly

## 💰 Firebase Pricing

Firebase has a generous free tier:
- **Firestore**: 50K reads/day, 20K writes/day (free)
- **Authentication**: Unlimited (free)
- **Storage**: 5GB (free)

For most apps, the free tier is sufficient. Monitor usage in Firebase Console.

## 📚 Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## 🎯 Next Steps

1. ✅ Enable Firestore (if not done)
2. ✅ Deploy security rules
3. ✅ Test data sync
4. ⏭️ (Optional) Set up Firebase Authentication
5. ⏭️ (Optional) Enable Firebase App Check
6. ⏭️ (Optional) Set up monitoring and alerts

## ✅ Current Status

Your Firebase setup:
- ✅ Firebase project: `wellness-diary-81a92`
- ✅ Configuration files: All platforms configured
- ✅ Firestore service: Implemented with error handling
- ✅ Security rules: Ready to deploy
- ⏳ Firestore Database: Needs to be enabled
- ⏳ Security Rules: Need to be deployed

**You're almost there! Just enable Firestore and deploy the rules.**

