import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellness_diary/firebase_options.dart';
import 'package:wellness_diary/models/health_vital_model.dart';
import 'package:wellness_diary/models/medicine_model.dart';
import 'package:wellness_diary/models/mood_model.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static bool _hasPermissionError = false;
  
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      // If Firebase is not configured, we'll use local storage only
      print('⚠️ Firebase initialization failed: $e');
      print('📱 App will continue with local storage only.');
    }
  }

  static bool get isInitialized => _firestore != null;
  static bool get hasPermissionError => _hasPermissionError;
  
  // Helper to check if error is permission-denied
  static bool _isPermissionError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'permission-denied';
    }
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission-denied') || 
           errorString.contains('permission denied');
  }
  
  // Helper to handle Firebase errors gracefully
  static void _handleError(dynamic error, String operation) {
    if (_isPermissionError(error)) {
      if (!_hasPermissionError) {
        _hasPermissionError = true;
        print('⚠️ Firebase permission denied. App will use local storage only.');
        print('💡 To enable Firebase sync, configure Firestore security rules or enable Firebase Authentication.');
      }
      // Don't print repeated permission errors
      return;
    }
    // Only print non-permission errors in debug mode
    if (error is FirebaseException) {
      print('Firebase $operation error: ${error.code} - ${error.message}');
    } else {
      print('Firebase $operation error: $error');
    }
  }

  // Moods Collection
  static CollectionReference<Map<String, dynamic>> moodsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('moods');
  }

  // Health Vitals Collection
  static CollectionReference<Map<String, dynamic>> healthVitalsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('health_vitals');
  }

  // Medicines Collection
  static CollectionReference<Map<String, dynamic>> medicinesCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('medicines');
  }

  // Moods Methods
  static Future<void> addMood(String userId, MoodModel mood) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await moodsCollection(userId).doc(mood.id).set(mood.toJson());
    } catch (e) {
      _handleError(e, 'addMood');
    }
  }

  static Future<void> updateMood(String userId, MoodModel mood) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await moodsCollection(userId).doc(mood.id).update(mood.toJson());
    } catch (e) {
      _handleError(e, 'updateMood');
    }
  }

  static Future<void> deleteMood(String userId, String moodId) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await moodsCollection(userId).doc(moodId).delete();
    } catch (e) {
      _handleError(e, 'deleteMood');
    }
  }

  static Stream<List<MoodModel>> getMoodsStream(String userId) {
    if (!isInitialized || _hasPermissionError) {
      return Stream.value([]);
    }
    return moodsCollection(userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodModel.fromJson(doc.data()))
            .toList())
        .handleError((error) {
          _handleError(error, 'getMoodsStream');
          return <MoodModel>[];
        });
  }

  static Future<List<MoodModel>> getMoods(String userId) async {
    if (!isInitialized || _hasPermissionError) return [];
    try {
      final snapshot = await moodsCollection(userId).orderBy('dateTime', descending: true).get();
      return snapshot.docs.map((doc) => MoodModel.fromJson(doc.data())).toList();
    } catch (e) {
      _handleError(e, 'getMoods');
      return [];
    }
  }

  // Health Vitals Methods
  static Future<void> addHealthVital(String userId, HealthVitalModel vital) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await healthVitalsCollection(userId).doc(vital.id).set(vital.toJson());
    } catch (e) {
      _handleError(e, 'addHealthVital');
    }
  }

  static Future<void> updateHealthVital(String userId, HealthVitalModel vital) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await healthVitalsCollection(userId).doc(vital.id).update(vital.toJson());
    } catch (e) {
      _handleError(e, 'updateHealthVital');
    }
  }

  static Future<void> deleteHealthVital(String userId, String vitalId) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await healthVitalsCollection(userId).doc(vitalId).delete();
    } catch (e) {
      _handleError(e, 'deleteHealthVital');
    }
  }

  static Stream<List<HealthVitalModel>> getHealthVitalsStream(String userId) {
    if (!isInitialized || _hasPermissionError) {
      return Stream.value([]);
    }
    return healthVitalsCollection(userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthVitalModel.fromJson(doc.data()))
            .toList())
        .handleError((error) {
          _handleError(error, 'getHealthVitalsStream');
          return <HealthVitalModel>[];
        });
  }

  static Future<List<HealthVitalModel>> getHealthVitals(String userId) async {
    if (!isInitialized || _hasPermissionError) return [];
    try {
      final snapshot = await healthVitalsCollection(userId).orderBy('dateTime', descending: true).get();
      return snapshot.docs.map((doc) => HealthVitalModel.fromJson(doc.data())).toList();
    } catch (e) {
      _handleError(e, 'getHealthVitals');
      return [];
    }
  }

  // Medicines Methods
  static Future<void> addMedicine(String userId, MedicineModel medicine) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await medicinesCollection(userId).doc(medicine.id).set(medicine.toJson());
    } catch (e) {
      _handleError(e, 'addMedicine');
    }
  }

  static Future<void> updateMedicine(String userId, MedicineModel medicine) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await medicinesCollection(userId).doc(medicine.id).update(medicine.toJson());
    } catch (e) {
      _handleError(e, 'updateMedicine');
    }
  }

  static Future<void> deleteMedicine(String userId, String medicineId) async {
    if (!isInitialized || _hasPermissionError) return;
    try {
      await medicinesCollection(userId).doc(medicineId).delete();
    } catch (e) {
      _handleError(e, 'deleteMedicine');
    }
  }

  static Stream<List<MedicineModel>> getMedicinesStream(String userId) {
    if (!isInitialized || _hasPermissionError) {
      return Stream.value([]);
    }
    return medicinesCollection(userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromJson(doc.data()))
            .toList())
        .handleError((error) {
          _handleError(error, 'getMedicinesStream');
          return <MedicineModel>[];
        });
  }

  static Future<List<MedicineModel>> getMedicines(String userId) async {
    if (!isInitialized || _hasPermissionError) return [];
    try {
      final snapshot = await medicinesCollection(userId).orderBy('startDate', descending: true).get();
      return snapshot.docs.map((doc) => MedicineModel.fromJson(doc.data())).toList();
    } catch (e) {
      _handleError(e, 'getMedicines');
      return [];
    }
  }
}

