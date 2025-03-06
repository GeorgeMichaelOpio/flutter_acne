import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLoading = false;
  String _error = '';
  bool _initialCheckCompleted = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get initialCheckCompleted => _initialCheckCompleted;

  AuthProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      await _persistAuthState();
      notifyListeners();
    });
    _checkPersistedAuth();
  }

  Future<void> _checkPersistedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persistedAuth = prefs.getBool('isAuthenticated') ?? false;

      if (persistedAuth && _user == null) {
        // Attempt silent sign-in
        await _trySilentSignIn();
      }
    } finally {
      _initialCheckCompleted = true;
      notifyListeners();
    }
  }

  Future<void> _trySilentSignIn() async {
    try {
      // Try Google silent sign-in first
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        await _handleGoogleSignIn(googleUser);
        return;
      }

      // Add other silent sign-in methods here if needed
    } catch (e) {
      _error = 'Automatic sign-in failed: ${e.toString()}';
    }
  }

  Future<void> _persistAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', _user != null);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _persistAuthState();
      return true;
    } catch (e) {
      _error = _parseFirebaseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmailAndPassword(
      String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _persistAuthState();
      return true;
    } catch (e) {
      _error = _parseFirebaseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        await _handleGoogleSignIn(googleSignInAccount);
        return true;
      }
      return false;
    } catch (e) {
      _error = _parseFirebaseError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleGoogleSignIn(
      GoogleSignInAccount googleSignInAccount) async {
    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    await _persistAuthState();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _persistAuthState();
    _user = null;
    notifyListeners();
  }

  String _parseFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'This email is already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        default:
          return error.message ?? 'Authentication failed';
      }
    }
    return error.toString();
  }
}
