import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseService _firebaseService;
  final _authStateController = StreamController<User?>.broadcast();

  User? _user;
  bool _loading = true;
  String? _error;
  StreamSubscription? _subscription;

  AuthProvider(this._authService, this._firebaseService) {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  Stream<User?> get authStateChanges => _authStateController.stream;

  void _onAuthStateChanged(User? user) {
    _user = user;
    _firebaseService.userId = user?.uid;
    _authStateController.add(user);
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      await _authService.login(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      await _authService.register(email, password);
      await _authService.logout();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return e.message ?? 'Terjadi kesalahan';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authStateController.close();
    super.dispose();
  }
}
