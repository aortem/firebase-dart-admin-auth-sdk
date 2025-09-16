import 'dart:developer';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Email/Password Auth
class EmailPasswordAuth {
  /// Firebase Auth instance
  final FirebaseAuth auth;

  /// Constructor
  EmailPasswordAuth(this.auth);

  /// Sign in with email & password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final response = await auth.performRequest('signInWithPassword', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      print(response.body.toString());

      if (response.statusCode == 200) {
        final userData = response.body;
        final user = User.fromJson(userData, apiKey: auth.apiKey);

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: false,
            providerId: 'password',
          ),
          operationType: 'signIn',
        );

        auth.updateCurrentUser(userCredential.user);
        log("current user 123 ${userCredential.user.idToken}");
        FirebaseApp.instance.setCurrentUser(userCredential.user);

        return userCredential;
      } else {
        final error = response.body['error'];
        throw FirebaseAuthException(
          code: error['message'] ?? 'unknown-error',
          message: error['message'] ?? 'An unknown error occurred',
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(code: 'auth-error', message: e.toString());
    }
  }

  /// Sign up with email & password
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      log('[EmailPasswordAuth.signUp] Starting signup for: $email');
      log('[EmailPasswordAuth.signUp] Auth API Key: ${auth.apiKey}');

      // Try Admin API first
      final response = await auth.performRequest('/batchCreate', {
        'users': [
          {
            'email': email,
            'password': password,
            'emailVerified': false,
            'disabled': false,
          },
        ],
      }, apiType: ApiType.admin);

      if (response.statusCode == 200) {
        final userData = response.body['users'][0];
        final user = User.fromJson(userData, apiKey: auth.apiKey);

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: true,
            providerId: 'password',
          ),
          operationType: 'signUp',
        );

        auth.updateCurrentUser(userCredential.user);
        FirebaseApp.instance.setCurrentUser(userCredential.user);

        return userCredential;
      }
    } catch (e) {
      log(
        '[EmailPasswordAuth] Admin API failed, falling back to client API: $e',
      );
    }

    // Fallback → Client API
    return _signUpWithClientAPI(email, password);
  }

  /// Private client API signup fallback
  Future<UserCredential?> _signUpWithClientAPI(
    String email,
    String password,
  ) async {
    try {
      final response = await auth.performRequest('signUp', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      log(
        '[EmailPasswordAuth._signUpWithClientAPI] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final userData = response.body;
        final user = User.fromJson(userData, apiKey: auth.apiKey);

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: true,
            providerId: 'password',
          ),
          operationType: 'signUp',
        );

        auth.updateCurrentUser(userCredential.user);
        FirebaseApp.instance.setCurrentUser(userCredential.user);

        return userCredential;
      } else {
        throw FirebaseAuthException(
          code: response.body['error']['message'] ?? 'signup-failed',
          message: response.body['error']['message'] ?? 'Failed to sign up',
        );
      }
    } catch (e) {
      log('Exception during client API sign up: $e');
      if (e is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(code: 'signup-error', message: e.toString());
    }
  }
}
