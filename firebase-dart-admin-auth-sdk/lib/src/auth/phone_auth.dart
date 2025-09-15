import 'dart:developer';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Class to handle phone authentication using Firebase Admin SDK.
class PhoneAuth {
  /// The FirebaseAuth instance to perform requests.
  final FirebaseAuth auth;

  /// Constructor to initialize PhoneAuth with a FirebaseAuth instance.
  PhoneAuth(this.auth);

  /// Sends a verification code to the specified phone number.
  Future<String> sendVerificationCode(
    String phoneNumber,
    ApplicationVerifier appVerifier,
  ) async {
    try {
      final response = await auth.performRequest(
        '/accounts:sendVerificationCode',
        {
          'phoneNumber': phoneNumber,
          'recaptchaToken': await appVerifier.verify(),
        },
        apiType: ApiType.admin,
      );

      if (response.statusCode != 200) {
        throw FirebaseAuthException(
          code: 'phone-auth-error',
          message: 'Failed to send verification code: ${response.body}',
        );
      }

      final sessionInfo = response.body['sessionInfo'];
      log(
        '[PhoneAuth] Verification code sent to $phoneNumber (sessionInfo: $sessionInfo)',
      );
      return sessionInfo;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'phone-auth-error',
        message: 'Failed to send verification code: $e',
      );
    }
  }

  /// Confirms the verification code received by the user and signs them in.
  Future<User> confirmCode(String sessionInfo, String smsCode) async {
    try {
      final response = await auth.performRequest(
        '/accounts:signInWithPhoneNumber',
        {'sessionInfo': sessionInfo, 'code': smsCode},
        apiType: ApiType.admin,
      );

      if (response.statusCode == 200) {
        final responseData = response.body; // already a Map<String, dynamic>
        return User.fromJson(responseData, apiKey: auth.apiKey);
      } else {
        final error = response.body['error'];
        throw FirebaseAuthException(
          code: error?['message'] ?? 'phone-auth-failed',
          message: error?['message'] ?? 'Failed to sign in with phone number',
        );
      }
    } catch (e) {
      log('[PhoneAuth] Error confirming code: $e');
      throw FirebaseAuthException(
        code: 'phone-auth-error',
        message: 'Failed to confirm code: $e',
      );
    }
  }
}
