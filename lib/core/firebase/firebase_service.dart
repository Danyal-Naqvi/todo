import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  bool _isInitialized = false;
  String _activeUserId = 'guest_user';

  bool get isInitialized => _isInitialized;
  String get activeUserId => _activeUserId;

  Future<bool> initialize() async {
    // If not configured yet, skip Firebase initialization to prevent crashes
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.startsWith('AIzaSyDemoPlaceholder')) {
        developer.log('Firebase credentials pending. Running in Local Offline-First Mode.', name: 'FirebaseService');
        _activeUserId = 'local_user';
        return false;
      }
    } catch (_) {
      _activeUserId = 'local_user';
      return false;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;

      // Sign in anonymously if no user is signed in
      try {
        final auth = FirebaseAuth.instance;
        User? user = auth.currentUser;
        if (user == null) {
          final userCredential = await auth.signInAnonymously();
          user = userCredential.user;
        }
        _activeUserId = user?.uid ?? 'authenticated_user';
      } catch (authError) {
        developer.log('Firebase Auth fallback: $authError', name: 'FirebaseService');
        _activeUserId = 'offline_user';
      }

      developer.log('Firebase successfully initialized! User: $_activeUserId', name: 'FirebaseService');
      return true;
    } catch (e) {
      developer.log('Firebase initialization error: $e. Falling back to local storage.', name: 'FirebaseService');
      _isInitialized = false;
      _activeUserId = 'local_user';
      return false;
    }
  }

  Future<void> signInAnonymously() async {
    if (!_isInitialized) return;
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      if (credential.user != null) {
        _activeUserId = credential.user!.uid;
      }
    } catch (e) {
      developer.log('Anonymous sign-in error: $e', name: 'FirebaseService');
    }
  }
}
