import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellness_diary/firebase_options.dart';
import 'package:wellness_diary/models/health_vital_model.dart';
import 'package:wellness_diary/models/medicine_model.dart';
import 'package:wellness_diary/models/mood_model.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  
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
    if (!isInitialized) return;
    await moodsCollection(userId).doc(mood.id).set(mood.toJson());
  }

  static Future<void> updateMood(String userId, MoodModel mood) async {
    if (!isInitialized) return;
    await moodsCollection(userId).doc(mood.id).update(mood.toJson());
  }

  static Future<void> deleteMood(String userId, String moodId) async {
    if (!isInitialized) return;
    await moodsCollection(userId).doc(moodId).delete();
  }

  static Stream<List<MoodModel>> getMoodsStream(String userId) {
    if (!isInitialized) {
      return Stream.value([]);
    }
    return moodsCollection(userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodModel.fromJson(doc.data()))
            .toList());
  }

  static Future<List<MoodModel>> getMoods(String userId) async {
    if (!isInitialized) return [];
    final snapshot = await moodsCollection(userId).orderBy('dateTime', descending: true).get();
    return snapshot.docs.map((doc) => MoodModel.fromJson(doc.data())).toList();
  }

  // Health Vitals Methods
  static Future<void> addHealthVital(String userId, HealthVitalModel vital) async {
    if (!isInitialized) return;
    await healthVitalsCollection(userId).doc(vital.id).set(vital.toJson());
  }

  static Future<void> updateHealthVital(String userId, HealthVitalModel vital) async {
    if (!isInitialized) return;
    await healthVitalsCollection(userId).doc(vital.id).update(vital.toJson());
  }

  static Future<void> deleteHealthVital(String userId, String vitalId) async {
    if (!isInitialized) return;
    await healthVitalsCollection(userId).doc(vitalId).delete();
  }

  static Stream<List<HealthVitalModel>> getHealthVitalsStream(String userId) {
    if (!isInitialized) {
      return Stream.value([]);
    }
    return healthVitalsCollection(userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthVitalModel.fromJson(doc.data()))
            .toList());
  }

  static Future<List<HealthVitalModel>> getHealthVitals(String userId) async {
    if (!isInitialized) return [];
    final snapshot = await healthVitalsCollection(userId).orderBy('dateTime', descending: true).get();
    return snapshot.docs.map((doc) => HealthVitalModel.fromJson(doc.data())).toList();
  }

  // Medicines Methods
  static Future<void> addMedicine(String userId, MedicineModel medicine) async {
    if (!isInitialized) return;
    await medicinesCollection(userId).doc(medicine.id).set(medicine.toJson());
  }

  static Future<void> updateMedicine(String userId, MedicineModel medicine) async {
    if (!isInitialized) return;
    await medicinesCollection(userId).doc(medicine.id).update(medicine.toJson());
  }

  static Future<void> deleteMedicine(String userId, String medicineId) async {
    if (!isInitialized) return;
    await medicinesCollection(userId).doc(medicineId).delete();
  }

  static Stream<List<MedicineModel>> getMedicinesStream(String userId) {
    if (!isInitialized) {
      return Stream.value([]);
    }
    return medicinesCollection(userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromJson(doc.data()))
            .toList());
  }

  static Future<List<MedicineModel>> getMedicines(String userId) async {
    if (!isInitialized) return [];
    final snapshot = await medicinesCollection(userId).orderBy('startDate', descending: true).get();
    return snapshot.docs.map((doc) => MedicineModel.fromJson(doc.data())).toList();
  }
}

