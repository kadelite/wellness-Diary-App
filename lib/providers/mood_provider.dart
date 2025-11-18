import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_model.dart';
import '../services/firebase_service.dart';

class MoodProvider extends ChangeNotifier {
  final Box<MoodModel> _moodBox = Hive.box<MoodModel>('moods');
  final Uuid _uuid = const Uuid();
  List<MoodModel> _moods = [];
  String? _currentUserId;
  StreamSubscription? _firestoreSubscription;

  List<MoodModel> get moods => _moods;

  MoodProvider() {
    _loadMoodsFromLocal();
  }

  void setUserId(String userId, BuildContext? context) {
    if (_currentUserId == userId) return;
    
    // Cancel previous subscription
    _firestoreSubscription?.cancel();
    _currentUserId = userId;
    
    // Load from Firebase if available
    if (FirebaseService.isInitialized && userId.isNotEmpty) {
      _listenToFirestoreUpdates(userId);
      _syncFromFirebase(userId);
    } else {
      _loadMoodsFromLocal();
    }
  }

  Future<void> _syncFromFirebase(String userId) async {
    if (!FirebaseService.isInitialized) return;
    
    try {
      final firestoreMoods = await FirebaseService.getMoods(userId);
      if (firestoreMoods.isNotEmpty) {
        _moods = firestoreMoods;
        // Sync to local storage
        await _syncToLocal(firestoreMoods);
        notifyListeners();
      }
    } catch (e) {
      print('Error syncing from Firebase: $e');
      _loadMoodsFromLocal();
    }
  }

  void _listenToFirestoreUpdates(String userId) {
    if (!FirebaseService.isInitialized) return;
    
    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseService.getMoodsStream(userId).listen(
      (moods) {
        _moods = moods;
        _syncToLocal(moods);
        notifyListeners();
      },
      onError: (error) {
        print('Firestore stream error: $error');
        _loadMoodsFromLocal();
      },
    );
  }

  Future<void> _loadMoodsFromLocal() async {
    _moods = _moodBox.values.toList();
    _moods.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<void> _syncToLocal(List<MoodModel> moods) async {
    await _moodBox.clear();
    for (var mood in moods) {
      await _moodBox.put(mood.id, mood);
    }
  }

  List<MoodModel> getTodayMoods() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _moods.where((mood) {
      final moodDate = DateTime(mood.dateTime.year, mood.dateTime.month, mood.dateTime.day);
      return moodDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<MoodModel> getMoodsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _moods.where((mood) {
      final moodDate = DateTime(mood.dateTime.year, mood.dateTime.month, mood.dateTime.day);
      return moodDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  MoodModel? getLatestMood() {
    if (_moods.isEmpty) return null;
    _moods.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return _moods.first;
  }

  Map<String, int> getMoodStats({int days = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final recentMoods = _moods.where((mood) => mood.dateTime.isAfter(startDate)).toList();

    final stats = <String, int>{};
    for (var mood in recentMoods) {
      stats[mood.mood] = (stats[mood.mood] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> addMood({
    required String mood,
    required DateTime dateTime,
    String? note,
    List<String> tags = const [],
    String? userId,
  }) async {
    final newMood = MoodModel(
      id: _uuid.v4(),
      mood: mood,
      dateTime: dateTime,
      note: note,
      tags: tags,
    );

    // Save to local storage first (immediate feedback)
    await _moodBox.put(newMood.id, newMood);
    _moods.insert(0, newMood);
    _moods.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();

    // Sync to Firebase if available
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.addMood(userId, newMood);
      } catch (e) {
        print('Error syncing to Firebase: $e');
      }
    }
  }

  Future<void> updateMood(MoodModel mood, {String? userId}) async {
    // Update local storage first
    await _moodBox.put(mood.id, mood);
    final index = _moods.indexWhere((m) => m.id == mood.id);
    if (index != -1) {
      _moods[index] = mood;
      _moods.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    notifyListeners();

    // Sync to Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.updateMood(userId, mood);
      } catch (e) {
        print('Error syncing to Firebase: $e');
      }
    }
  }

  Future<void> deleteMood(String id, {String? userId}) async {
    // Delete from local storage first
    await _moodBox.delete(id);
    _moods.removeWhere((m) => m.id == id);
    notifyListeners();

    // Delete from Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.deleteMood(userId, id);
      } catch (e) {
        print('Error deleting from Firebase: $e');
      }
    }
  }

  Future<void> deleteAllMoods({String? userId}) async {
    await _moodBox.clear();
    _moods.clear();
    notifyListeners();

    // Firebase doesn't have a delete all, would need to delete individually
    // For now, we'll skip this
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
