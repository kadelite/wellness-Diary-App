import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final Box<UserModel> _userBox = Hive.box<UserModel>('users');
  final Uuid _uuid = const Uuid();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
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
    // Check if user already exists
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

    final newUser = UserModel(
      id: _uuid.v4(),
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
    try {
      final user = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
      );

      if (user.passwordHash != _hashPassword(password)) {
        throw Exception('Invalid email or password');
      }

      // Update last login
      final updatedUser = UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        passwordHash: user.passwordHash,
        createdAt: user.createdAt,
        lastLoginAt: DateTime.now(),
        profileImageUrl: user.profileImageUrl,
      );
      await _userBox.put(user.id, updatedUser);

      await _saveCurrentUser(user.id);
      _currentUser = updatedUser;
      notifyListeners();

      return user.id;
    } catch (e) {
      if (e.toString().contains('StateError')) {
        throw Exception('Invalid email or password');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
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

