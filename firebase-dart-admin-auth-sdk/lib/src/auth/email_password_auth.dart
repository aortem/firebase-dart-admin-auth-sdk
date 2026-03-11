import 'dart:developer';
import 'dart:convert';
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
      final apiKey = (auth.apiKey ?? '').trim();
      if (apiKey.isEmpty || apiKey == 'your_api_key') {
        throw FirebaseAuthException(
          code: 'api-key-required',
          message:
              'FirebaseAuth.signInWithEmailAndPassword requires a Firebase web API key.',
        );
      }

      final response = await auth.httpClient.post(
        Uri.https(
          'identitytoolkit.googleapis.com',
          '/v1/accounts:signInWithPassword',
          {'key': apiKey},
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseBody = response.body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(response.body) as Map);

      final challenge = tryParseMultiFactorError(
        responseBody,
        code: 'multi-factor-auth-required',
        message:
            'Second factor required. Use getMultiFactorResolver() to continue the sign-in flow.',
      );
      if (challenge != null) {
        throw challenge;
      }

      if (response.statusCode == 200) {
        final userData = responseBody;
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
        final error = responseBody['error'];
        throw FirebaseAuthException(
          code: error is Map<String, dynamic>
              ? error['message'] ?? 'unknown-error'
              : 'unknown-error',
          message: error is Map<String, dynamic>
              ? error['message'] ?? 'An unknown error occurred'
              : 'An unknown error occurred',
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException || e is MultiFactorError) {
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
