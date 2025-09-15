import 'dart:developer';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Service to create a new user with email and password.
class CreateUserWithEmailAndPasswordService {
  /// The FirebaseAuth instance.
  final FirebaseAuth auth;

  /// Constructor for CreateUserWithEmailAndPasswordService.
  CreateUserWithEmailAndPasswordService({required this.auth});

  /// Creates a new user with the given email and password.
  Future<UserCredential?> createUser(String email, String password) async {
    try {
      log('[CreateUser] Using Admin API to create user: $email');
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
        return UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: true,
            providerId: 'password',
          ),
          operationType: 'signUp',
        );
      }
    } catch (e) {
      log('[CreateUser] Admin API failed, falling back to client API: $e');
      return _createWithClient(email, password);
    }
    return null;
  }

  Future<UserCredential?> _createWithClient(
    String email,
    String password,
  ) async {
    final response = await auth.performRequest('signUp', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    if (response.statusCode == 200) {
      final user = User.fromJson(response.body, apiKey: auth.apiKey);
      return UserCredential(
        user: user,
        additionalUserInfo: AdditionalUserInfo(
          isNewUser: true,
          providerId: 'password',
        ),
        operationType: 'signUp',
      );
    }
    final error = response.body['error'];
    throw FirebaseAuthException(
      code: error['message'] ?? 'signup-failed',
      message: error['message'] ?? 'Failed to sign up',
    );
  }
}
