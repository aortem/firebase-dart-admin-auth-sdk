import 'dart:developer';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

///emailpasswordauth
class EmailPasswordAuth {
  ///auth
  final FirebaseAuth auth;

  ///emailpassword
  EmailPasswordAuth(this.auth);

  ///signin
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final response = await auth.performRequest('signInWithPassword', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });
      print(response.body.toString());

      if (response.statusCode == 200) {
        // Pass apiKey when creating UserCredential
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
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(code: 'auth-error', message: e.toString());
    }
  }

  ///signup
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      log('[EmailPasswordAuth.signUp] Starting signup for: $email');
      log('[EmailPasswordAuth.signUp] Auth API Key: ${auth.apiKey}');

      final response = await auth.performRequest('signUp', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      log('[EmailPasswordAuth.signUp] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = response.body;

        // Debug the response
        log(
          '[EmailPasswordAuth.signUp] Response idToken exists: ${userData['idToken'] != null}',
        );
        log(
          '[EmailPasswordAuth.signUp] Response refreshToken exists: ${userData['refreshToken'] != null}',
        );

        // Pass apiKey when creating User
        final user = User.fromJson(userData, apiKey: auth.apiKey);

        // Verify user was created correctly
        log('[EmailPasswordAuth.signUp] Created User:');
        log('[EmailPasswordAuth.signUp] - uid: ${user.uid}');
        log('[EmailPasswordAuth.signUp] - email: ${user.email}');
        log(
          '[EmailPasswordAuth.signUp] - idToken exists: ${user.idToken != null}',
        );
        log(
          '[EmailPasswordAuth.signUp] - refreshToken exists: ${user.refreshToken != null}',
        );
        log(
          '[EmailPasswordAuth.signUp] - apiKey exists: ${user.apiKey != null}',
        );

        final additionalUserInfo = AdditionalUserInfo(
          isNewUser: true,
          providerId: 'password',
        );

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: additionalUserInfo,
          operationType: 'signUp',
        );

        auth.updateCurrentUser(userCredential.user);
        FirebaseApp.instance.setCurrentUser(userCredential.user);

        return userCredential;
      } else {
        log('Error signing up: ${response.body}');
        throw FirebaseAuthException(
          code: response.body['error']['message'] ?? 'signup-failed',
          message: response.body['error']['message'] ?? 'Failed to sign up',
        );
      }
    } catch (e) {
      log('Exception during sign up: $e');
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(code: 'signup-error', message: e.toString());
    }
  }
}
