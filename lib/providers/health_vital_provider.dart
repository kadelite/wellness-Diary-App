import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/health_vital_model.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';

class HealthVitalProvider extends ChangeNotifier {
  final Box<HealthVitalModel> _vitalBox = Hive.box<HealthVitalModel>('health_vitals');
  final Uuid _uuid = const Uuid();
  List<HealthVitalModel> _vitals = [];
  String? _currentUserId;
  StreamSubscription? _firestoreSubscription;

  List<HealthVitalModel> get vitals => _vitals;

  HealthVitalProvider() {
    _loadVitalsFromLocal();
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
      _loadVitalsFromLocal();
    }
  }

  Future<void> _syncFromFirebase(String userId) async {
    if (!FirebaseService.isInitialized) return;
    
    try {
      final firestoreVitals = await FirebaseService.getHealthVitals(userId);
      if (firestoreVitals.isNotEmpty) {
        _vitals = firestoreVitals;
        // Sync to local storage
        await _syncToLocal(firestoreVitals);
        notifyListeners();
      }
    } catch (e) {
      // Only log non-permission errors
      final errorString = e.toString().toLowerCase();
      if (!errorString.contains('permission-denied') && 
          !errorString.contains('permission denied')) {
        print('Error syncing from Firebase: $e');
      }
      _loadVitalsFromLocal();
    }
  }

  void _listenToFirestoreUpdates(String userId) {
    if (!FirebaseService.isInitialized) return;
    
    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseService.getHealthVitalsStream(userId).listen(
      (vitals) {
        _vitals = vitals;
        _syncToLocal(vitals);
        notifyListeners();
      },
      onError: (error) {
        // Only log non-permission errors
        final errorString = error.toString().toLowerCase();
        if (!errorString.contains('permission-denied') && 
            !errorString.contains('permission denied')) {
          print('Firestore stream error: $error');
        }
        _loadVitalsFromLocal();
      },
    );
  }

  Future<void> _loadVitalsFromLocal() async {
    _vitals = _vitalBox.values.toList();
    _vitals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<void> _syncToLocal(List<HealthVitalModel> vitals) async {
    await _vitalBox.clear();
    for (var vital in vitals) {
      await _vitalBox.put(vital.id, vital);
    }
  }

  List<HealthVitalModel> getVitalsByType(VitalType type) {
    return _vitals.where((vital) => vital.type == type).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<HealthVitalModel> getVitalsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _vitals.where((vital) {
      final vitalDate = DateTime(vital.dateTime.year, vital.dateTime.month, vital.dateTime.day);
      return vitalDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  HealthVitalModel? getLatestVital(VitalType type) {
    final typeVitals = getVitalsByType(type);
    return typeVitals.isEmpty ? null : typeVitals.first;
  }

  List<HealthVitalModel> getRecentVitals(VitalType type, {int days = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return getVitalsByType(type)
        .where((vital) => vital.dateTime.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  double? getAverageValue(VitalType type, {int days = 7}) {
    final recentVitals = getRecentVitals(type, days: days);
    if (recentVitals.isEmpty) return null;
    final sum = recentVitals.fold<double>(0, (sum, vital) => sum + vital.value);
    return sum / recentVitals.length;
  }

  double? getMinValue(VitalType type, {int days = 7}) {
    final recentVitals = getRecentVitals(type, days: days);
    if (recentVitals.isEmpty) return null;
    return recentVitals.map((v) => v.value).reduce((a, b) => a < b ? a : b);
  }

  double? getMaxValue(VitalType type, {int days = 7}) {
    final recentVitals = getRecentVitals(type, days: days);
    if (recentVitals.isEmpty) return null;
    return recentVitals.map((v) => v.value).reduce((a, b) => a > b ? a : b);
  }

  Future<void> addVital({
    required VitalType type,
    required double value,
    required DateTime dateTime,
    String? unit,
    String? note,
    String? userId,
  }) async {
    final newVital = HealthVitalModel(
      id: _uuid.v4(),
      type: type,
      value: value,
      dateTime: dateTime,
      unit: unit ?? type.defaultUnit,
      note: note,
    );

    // Save to local storage first (immediate feedback)
    await _vitalBox.put(newVital.id, newVital);
    _vitals.insert(0, newVital);
    _vitals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();

    // Sync to Firebase if available
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.addHealthVital(userId, newVital);
      } catch (e) {
        // Only log non-permission errors
        final errorString = e.toString().toLowerCase();
        if (!errorString.contains('permission-denied') && 
            !errorString.contains('permission denied')) {
          print('Error syncing to Firebase: $e');
        }
      }
    }
  }

  Future<void> updateVital(HealthVitalModel vital, {String? userId}) async {
    // Update local storage first
    await _vitalBox.put(vital.id, vital);
    final index = _vitals.indexWhere((v) => v.id == vital.id);
    if (index != -1) {
      _vitals[index] = vital;
      _vitals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    notifyListeners();

    // Sync to Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.updateHealthVital(userId, vital);
      } catch (e) {
        // Only log non-permission errors
        final errorString = e.toString().toLowerCase();
        if (!errorString.contains('permission-denied') && 
            !errorString.contains('permission denied')) {
          print('Error syncing to Firebase: $e');
        }
      }
    }
  }

  Future<void> deleteVital(String id, {String? userId}) async {
    // Delete from local storage first
    await _vitalBox.delete(id);
    _vitals.removeWhere((v) => v.id == id);
    notifyListeners();

    // Delete from Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.deleteHealthVital(userId, id);
      } catch (e) {
        print('Error deleting from Firebase: $e');
      }
    }
  }

  Future<void> deleteAllVitals({String? userId}) async {
    await _vitalBox.clear();
    _vitals.clear();
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
