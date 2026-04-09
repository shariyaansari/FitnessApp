import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _db = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserProfile? _profile;
  String? _errorMessage;
  bool _needsOnboarding = false;

  AuthStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get needsOnboarding => _needsOnboarding;
  User? get firebaseUser => _auth.currentUser;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _profile = null;
      notifyListeners();
      return;
    }
    await _loadProfile(user);
  }

  Future<void> _loadProfile(User user) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final profile = await _db.getUser(user.uid);
      if (profile == null) {
        _needsOnboarding = true;
        _profile = UserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Fitness Fan',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
        );
        await _db.createUser(_profile!);
      } else {
        _needsOnboarding = false;
        _profile = profile;
      }
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeOnboarding({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String goalType,
  }) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      goalType: goalType,
      dailyCalorieGoal: _profile!.copyWith(
        age: age, gender: gender, heightCm: heightCm,
        weightKg: weightKg, goalType: goalType,
      ).adjustedCalorieGoal,
    );
    await _db.updateUser(updated.uid, updated.toMap());
    _profile = updated;
    _needsOnboarding = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_profile == null) return;
    await _db.updateUser(_profile!.uid, data);
    final refreshed = await _db.getUser(_profile!.uid);
    _profile = refreshed;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
