import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../utils/notification_service.dart';
import '../services/firebase_service.dart';

class MedicineProvider extends ChangeNotifier {
  final Box<MedicineModel> _medicineBox = Hive.box<MedicineModel>('medicines');
  final Uuid _uuid = const Uuid();
  List<MedicineModel> _medicines = [];
  String? _currentUserId;
  StreamSubscription? _firestoreSubscription;

  List<MedicineModel> get medicines => _medicines;

  MedicineProvider() {
    _loadMedicinesFromLocal();
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
      _loadMedicinesFromLocal();
    }
  }

  Future<void> _syncFromFirebase(String userId) async {
    if (!FirebaseService.isInitialized) return;
    
    try {
      final firestoreMedicines = await FirebaseService.getMedicines(userId);
      if (firestoreMedicines.isNotEmpty) {
        _medicines = firestoreMedicines;
        // Sync to local storage
        await _syncToLocal(firestoreMedicines);
        notifyListeners();
      }
    } catch (e) {
      print('Error syncing from Firebase: $e');
      _loadMedicinesFromLocal();
    }
  }

  void _listenToFirestoreUpdates(String userId) {
    if (!FirebaseService.isInitialized) return;
    
    _firestoreSubscription?.cancel();
    _firestoreSubscription = FirebaseService.getMedicinesStream(userId).listen(
      (medicines) {
        _medicines = medicines;
        _syncToLocal(medicines);
        notifyListeners();
      },
      onError: (error) {
        print('Firestore stream error: $error');
        _loadMedicinesFromLocal();
      },
    );
  }

  Future<void> _loadMedicinesFromLocal() async {
    _medicines = _medicineBox.values.toList();
    notifyListeners();
  }

  Future<void> _syncToLocal(List<MedicineModel> medicines) async {
    await _medicineBox.clear();
    for (var medicine in medicines) {
      await _medicineBox.put(medicine.id, medicine);
    }
  }

  List<MedicineModel> get activeMedicines =>
      _medicines.where((m) => m.isActive).toList();

  List<MedicineModel> getTodayMedicines() {
    final today = DateTime.now().weekday;
    return activeMedicines.where((medicine) {
      return medicine.daysOfWeek.contains(today);
    }).toList();
  }

  List<MedicineModel> getUpcomingMedicines({int hours = 24}) {
    final now = DateTime.now();
    final upcoming = <MedicineModel>[];

    for (var medicine in getTodayMedicines()) {
      for (var time in medicine.times) {
        final medicineTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        if (medicineTime.isAfter(now) &&
            medicineTime.isBefore(now.add(Duration(hours: hours)))) {
          upcoming.add(medicine);
          break;
        }
      }
    }

    return upcoming;
  }

  Future<void> addMedicine({
    required String name,
    required String dosage,
    required List<TimeOfDayModel> times,
    required DateTime startDate,
    DateTime? endDate,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    String? note,
    String? color,
    String? userId,
  }) async {
    final newMedicine = MedicineModel(
      id: _uuid.v4(),
      name: name,
      dosage: dosage,
      times: times,
      startDate: startDate,
      endDate: endDate,
      daysOfWeek: daysOfWeek,
      note: note,
      color: color,
      isActive: true,
    );

    // Save to local storage first
    await _medicineBox.put(newMedicine.id, newMedicine);
    _medicines.insert(0, newMedicine);
    notifyListeners();

    // Schedule notifications
    await _scheduleNotifications(newMedicine);

    // Sync to Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.addMedicine(userId, newMedicine);
      } catch (e) {
        print('Error syncing to Firebase: $e');
      }
    }
  }

  Future<void> updateMedicine(MedicineModel medicine, {String? userId}) async {
    // Update local storage first
    await _medicineBox.put(medicine.id, medicine);
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
    }
    
    if (medicine.isActive) {
      await _scheduleNotifications(medicine);
    } else {
      await _cancelNotifications(medicine);
    }
    notifyListeners();

    // Sync to Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.updateMedicine(userId, medicine);
      } catch (e) {
        print('Error syncing to Firebase: $e');
      }
    }
  }

  Future<void> deleteMedicine(String id, {String? userId}) async {
    final medicine = _medicines.firstWhere(
      (m) => m.id == id,
      orElse: () => _medicineBox.get(id)!,
    );
    
    // Delete from local storage first
    await _cancelNotifications(medicine);
    await _medicineBox.delete(id);
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();

    // Delete from Firebase
    if (FirebaseService.isInitialized && userId != null && userId.isNotEmpty) {
      try {
        await FirebaseService.deleteMedicine(userId, id);
      } catch (e) {
        print('Error deleting from Firebase: $e');
      }
    }
  }

  Future<void> toggleMedicineActive(String id, {String? userId}) async {
    final medicine = _medicines.firstWhere(
      (m) => m.id == id,
      orElse: () => _medicineBox.get(id)!,
    );

    final updated = MedicineModel(
      id: medicine.id,
      name: medicine.name,
      dosage: medicine.dosage,
      times: medicine.times,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      daysOfWeek: medicine.daysOfWeek,
      note: medicine.note,
      isActive: !medicine.isActive,
      color: medicine.color,
    );
    await updateMedicine(updated, userId: userId);
  }

  Future<void> _scheduleNotifications(MedicineModel medicine) async {
    if (!medicine.isActive || kIsWeb) return;

    for (var time in medicine.times) {
      for (var day in medicine.daysOfWeek) {
        await NotificationService().scheduleMedicineReminder(
          medicine.id,
          medicine.name,
          medicine.dosage,
          day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  Future<void> _cancelNotifications(MedicineModel medicine) async {
    if (kIsWeb) return;

    for (var time in medicine.times) {
      for (var day in medicine.daysOfWeek) {
        await NotificationService().cancelMedicineReminder(
          medicine.id,
          day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
