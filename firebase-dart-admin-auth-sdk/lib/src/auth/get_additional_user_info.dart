import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Service to fetch additional user information.
class GetAdditionalUserInfo {
  /// The FirebaseAuth instance.
  final FirebaseAuth auth;

  /// Constructor for GetAdditionalUserInfo.
  GetAdditionalUserInfo({required this.auth});

  /// Fetches additional user information using the provided ID token.
  Future<User> getAdditionalUserInfo(String? idToken) async {
    try {
      assert(idToken != null, 'Id token cannot be null');

      // Use Admin API
      final response = await auth.performRequest('/accounts:lookup', {
        "idToken": idToken,
      }, apiType: ApiType.admin);

      final user = User.fromJson(
        (response.body['users'] as List)[0],
        apiKey: auth.apiKey,
      );
      auth.updateCurrentUser(user);
      return user;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'get-additional-user-info',
        message: 'Failed to get additional user info: $e',
      );
    }
  }
}
