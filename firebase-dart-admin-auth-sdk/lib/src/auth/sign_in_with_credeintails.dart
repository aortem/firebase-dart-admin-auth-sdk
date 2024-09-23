import '../../firebase_dart_admin_auth_sdk.dart';

class FirebaseSignInWithCredientials {
  final FirebaseAuth auth;

  FirebaseSignInWithCredientials(this.auth);

  // Method to sign in using OAuth credentials
  Future<void> signInWithCredential(
      String accessToken, String providerId) async {
    try {
      final response = await auth.performRequest('signInWithIdp', {
        "postBody": "id_token=$accessToken&providerId=$providerId",
        "requestUri": "http://localhost", // Dummy URL
        "returnIdpCredential": true,
        "returnSecureToken": true,
      });
      if (response.statusCode == 200) {
        print("Successfully signed in! ID Token: ${response.body}");
      } else {
        print('Failed to set signed in: ${response.body}');
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }
}
