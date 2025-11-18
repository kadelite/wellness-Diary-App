@echo off
REM Build runner script to generate Hive adapters for Windows
flutter pub run build_runner build --delete-conflicting-outputs

