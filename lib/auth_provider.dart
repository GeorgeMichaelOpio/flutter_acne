import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;

  User? _user;
  bool _isLoading = true;
  String _error = '';
  String? _userName;
  String? _profileImageUrl;
  StreamSubscription<AuthState>? _authSubscription;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get error => _error;
  String? get userName => _userName;
  String? get profileImageUrl => _profileImageUrl;

  AuthProvider() {
    _googleSignIn = GoogleSignIn(
      clientId:
          Platform.isIOS
              ? '450394743637-m69sc4rp5sgs631889a7n3i57c6098ta.apps.googleusercontent.com'
              : null,
      serverClientId:
          '450394743637-pp24b6thgujj74mmta30gqem2ok24lct.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.signedIn) {
        _user = data.session?.user;
        _isLoading = false;

        if (_user != null) {
          await _fetchProfileData();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _userName = null;
        _profileImageUrl = null;
        _isLoading = false;
      }
      notifyListeners();
    });
  }

  Future<bool> updateProfile({String? name, File? avatarFile}) async {
    if (user == null) return false;

    try {
      String? avatarUrl;

      // Upload new avatar if provided
      if (avatarFile != null) {
        final fileExt = avatarFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${user!.id}/$fileName';

        await _supabase.storage
            .from('avatars')
            .upload(
              filePath,
              avatarFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        avatarUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      // Update profile
      await _supabase.from('profiles').upsert({
        'id': user!.id,
        'username': name ?? userName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update local state
      if (name != null) _userName = name;
      if (avatarUrl != null) _profileImageUrl = avatarUrl;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  Future<void> _fetchProfileData() async {
    if (_user == null) return;

    try {
      final response =
          await _supabase
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', _user!.id)
              .maybeSingle();

      if (response != null) {
        _userName = response['username'] as String?;
        _profileImageUrl = response['avatar_url'] as String?;
      } else {
        // Create a new profile if one doesn't exist
        await _createInitialProfile();
      }
    } catch (e) {
      _userName = _user?.email?.split('@').first;
      _profileImageUrl = null;
    }

    notifyListeners();
  }

  Future<void> _createInitialProfile() async {
    if (_user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': _user!.id,
        'username': _user?.email?.split('@').first,
        'avatar_url': null,
      });

      // Refresh profile data
      await _fetchProfileData();
    } catch (e) {
      _setError('Failed to create profile');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError('');

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      await _fetchProfileData();
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _setLoading(true);
    _setError('');

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      _user = response.user;

      // Create profile after successful registration
      if (_user != null) {
        await _createInitialProfile();
      }

      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError('');

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Google sign in was cancelled');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw 'No ID Token found from Google';
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      _user = _supabase.auth.currentUser;
      await _fetchProfileData();
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_supabase.auth.signOut(), _googleSignIn.signOut()]);
      _user = null;
      _userName = null;
      _profileImageUrl = null;
    } catch (e) {
      _setError(_parseAuthError(e));
    } finally {
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  String _parseAuthError(dynamic error) {
    if (error is AuthException) {
      final message = error.message.trim();

      switch (message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'User already registered':
          return 'This email is already registered';
        case 'Email not confirmed':
          return 'Please check your email to confirm your account before you can log in';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters';
        default:
          return message;
      }
    }

    return error?.toString() ?? 'An unknown error occurred';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _googleSignIn.disconnect();
    super.dispose();
  }
}
