import 'dart:convert';
import 'dart:developer';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Password reset service
class PasswordResetEmailService {
  /// Firebase Auth instance
  final FirebaseAuth auth;

  /// Constructor
  PasswordResetEmailService({required this.auth});

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Try Admin API first
      await auth.performRequest('/sendOobCode', {
        'requestType': 'PASSWORD_RESET',
        'email': email,
      }, apiType: ApiType.admin);
    } catch (e) {
      log('[PasswordReset] Admin API failed, falling back to client API: $e');
      // Fallback to client API
      await _sendPasswordResetEmailClient(email);
    }
  }

  /// Fallback client API call
  Future<void> _sendPasswordResetEmailClient(String email) async {
    try {
      final url = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:sendOobCode',
        {if (auth.apiKey != 'your_api_key') 'key': auth.apiKey},
      );

      final response = await auth.httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (auth.accessToken != null)
            'Authorization': 'Bearer ${auth.accessToken}',
        },
        body: json.encode({'requestType': 'PASSWORD_RESET', 'email': email}),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body)['error'];
        throw FirebaseAuthException(
          code: error['message'],
          message: error['message'],
        );
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: 'password-reset-error',
        message: 'Failed to send password reset email: ${e.toString()}',
      );
    }
  }
}
