#!/bin/bash

# Firebase Setup Script for Wellness Diary App
# This script helps you set up Firebase and Firestore

echo "🔥 Firebase Setup Script for Wellness Diary"
echo "=============================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found."
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
    echo "✅ Firebase CLI installed"
    echo ""
fi

# Check if logged in
echo "🔐 Checking Firebase login status..."
if ! firebase projects:list &> /dev/null; then
    echo "🔑 Please login to Firebase:"
    firebase login
else
    echo "✅ Already logged in to Firebase"
fi

echo ""
echo "📋 Available Firebase projects:"
firebase projects:list

echo ""
echo "🚀 Next steps:"
echo "1. Go to Firebase Console: https://console.firebase.google.com/"
echo "2. Select project: wellness-diary-81a92"
echo "3. Enable Firestore Database (if not already enabled)"
echo "4. Deploy Firestore rules:"
echo "   firebase deploy --only firestore:rules"
echo ""
echo "Or use the Firebase Console to copy/paste rules from firestore.rules"
echo ""

