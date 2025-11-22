import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  late final Box<UserModel> _userBox = Hive.box<UserModel>('users');
  final Uuid _uuid = const Uuid();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Try to load from Firebase Auth first
      if (FirebaseService.isInitialized) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          // Try to load user from local storage using Firebase UID
          final user = _userBox.get(firebaseUser.uid);
          if (user != null) {
            _currentUser = user;
            await _saveCurrentUser(firebaseUser.uid);
            notifyListeners();
            return;
          }
        }
      }
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId != null) {
        final user = _userBox.get(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveCurrentUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
    } catch (e) {
      // Ignore errors
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    String userId;
    
    // Check if user already exists locally
    try {
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );

      if (existingUser.email.isNotEmpty) {
        throw Exception('Email already registered');
      }
    } catch (e) {
      // If user doesn't exist, firstWhere will throw, which is fine
      // If email already registered, rethrow
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      // Otherwise, user doesn't exist, continue with signup
    }

    // Create Firebase Auth user if Firebase is available
    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        );
        userId = credential.user!.uid;
        
        // Update Firebase Auth user display name
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
      } catch (e) {
        // If Firebase Auth fails (e.g., email already exists), check if it's a Firebase error
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            throw Exception('Email already registered');
          }
          // For other Firebase errors, fall back to local auth
          print('⚠️ Firebase Auth signup failed: ${e.message}. Using local auth.');
          userId = _uuid.v4();
        } else {
          // For non-Firebase errors, use local auth
          userId = _uuid.v4();
        }
      }
    } else {
      // Firebase not available, use local auth
      userId = _uuid.v4();
    }

    // Save user to local storage
    final newUser = UserModel(
      id: userId,
      email: email.trim().toLowerCase(),
      name: name.trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    await _userBox.put(newUser.id, newUser);
    await _saveCurrentUser(newUser.id);
    _currentUser = newUser;
    notifyListeners();

    return newUser.id;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String userId;
    UserModel? localUser;
    
    // Try Firebase Auth login first if available
    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        );
        userId = credential.user!.uid;
        
        // Try to load user from local storage
        localUser = _userBox.get(userId);
        
        // If user doesn't exist locally but exists in Firebase Auth, create local entry
        if (localUser == null) {
          localUser = UserModel(
            id: userId,
            email: email.trim().toLowerCase(),
            name: credential.user!.displayName ?? 'User',
            passwordHash: _hashPassword(password), // Store hash for local verification
            createdAt: credential.user!.metadata.creationTime ?? DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          await _userBox.put(userId, localUser);
        }
      } catch (e) {
        // Firebase Auth failed, try local auth
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            // Try local auth as fallback
          } else {
            print('⚠️ Firebase Auth login error: ${e.message}. Trying local auth.');
          }
        }
        
        // Fall back to local authentication
        try {
          localUser = _userBox.values.firstWhere(
            (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
          );

          if (localUser.passwordHash != _hashPassword(password)) {
            throw Exception('Invalid email or password');
          }
          userId = localUser.id;
        } catch (localError) {
          if (localError.toString().contains('StateError') || 
              localError.toString().contains('Invalid email or password')) {
            throw Exception('Invalid email or password');
          }
          rethrow;
        }
      }
    } else {
      // Firebase not available, use local auth only
      try {
        localUser = _userBox.values.firstWhere(
          (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
        );

        if (localUser.passwordHash != _hashPassword(password)) {
          throw Exception('Invalid email or password');
        }
        userId = localUser.id;
      } catch (e) {
        if (e.toString().contains('StateError')) {
          throw Exception('Invalid email or password');
        }
        rethrow;
      }
    }

    // Update last login
    final updatedUser = UserModel(
      id: userId,
      email: localUser!.email,
      name: localUser.name,
      passwordHash: localUser.passwordHash,
      createdAt: localUser.createdAt,
      lastLoginAt: DateTime.now(),
      profileImageUrl: localUser.profileImageUrl,
    );
    await _userBox.put(userId, updatedUser);

    await _saveCurrentUser(userId);
    _currentUser = updatedUser;
    notifyListeners();

    return userId;
  }

  Future<void> logout() async {
    // Sign out from Firebase Auth if available
    if (FirebaseService.isInitialized) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        // Ignore Firebase Auth errors
      }
    }
    
    await _clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name ?? _currentUser!.name,
      passwordHash: _currentUser!.passwordHash,
      createdAt: _currentUser!.createdAt,
      lastLoginAt: _currentUser!.lastLoginAt,
      profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
    );

    await _userBox.put(_currentUser!.id, updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    if (_currentUser!.passwordHash != _hashPassword(oldPassword)) {
      return false;
    }

    // Update Firebase Auth password if available
    if (FirebaseService.isInitialized) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == _currentUser!.email) {
          await user.updatePassword(newPassword);
        }
      } catch (e) {
        // If Firebase Auth update fails, still update local
        print('⚠️ Firebase Auth password update failed: $e');
      }
    }

    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      passwordHash: _hashPassword(newPassword),
      createdAt: _currentUser!.createdAt,
      lastLoginAt: _currentUser!.lastLoginAt,
      profileImageUrl: _currentUser!.profileImageUrl,
    );

    await _userBox.put(_currentUser!.id, updatedUser);
    _currentUser = updatedUser;
    notifyListeners();

    return true;
  }
}

