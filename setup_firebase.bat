@echo off
REM Firebase Setup Script for Wellness Diary App (Windows)
REM This script helps you set up Firebase and Firestore

echo 🔥 Firebase Setup Script for Wellness Diary
echo ==============================================
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  Firebase CLI not found.
    echo 📦 Installing Firebase CLI...
    call npm install -g firebase-tools
    echo ✅ Firebase CLI installed
    echo.
)

REM Check if logged in
echo 🔐 Checking Firebase login status...
firebase projects:list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 🔑 Please login to Firebase:
    call firebase login
) else (
    echo ✅ Already logged in to Firebase
)

echo.
echo 📋 Available Firebase projects:
call firebase projects:list

echo.
echo 🚀 Next steps:
echo 1. Go to Firebase Console: https://console.firebase.google.com/
echo 2. Select project: wellness-diary-81a92
echo 3. Enable Firestore Database (if not already enabled)
echo 4. Deploy Firestore rules:
echo    firebase deploy --only firestore:rules
echo.
echo Or use the Firebase Console to copy/paste rules from firestore.rules
echo.

pause

