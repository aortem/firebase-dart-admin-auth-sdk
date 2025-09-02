import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

///create user connect
class CreateUserWithEmailAndPasswordService {
  ///
  CreateUserWithEmailAndPasswordService(this.auth);

  ///
  final FirebaseAuth auth;

  ///
  Future<UserCredential> create(
    ///
    String email,

    ///
    String password,

    ///
    FirebaseAuth authInstance,
  ) async {
    try {
      //print('[CreateUser] Starting user creation for email: $email');
      //print('[CreateUser] API Key available: ${authInstance.apiKey != null}');

      final response = await authInstance.performRequest('signUp', {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      //print('[CreateUser] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = response.body;

        // Debug logging
        //print(
        //  '[CreateUser] Response has idToken: ${userData['idToken'] != null}',
        //);
        //print(
        //  '[CreateUser] Response has refreshToken: ${userData['refreshToken'] != null}',
        //);
        //print('[CreateUser] API Key being passed: ${authInstance.apiKey}');

        // Create User with apiKey AND ensure tokens are set
        final user = User.fromJson(userData, apiKey: authInstance.apiKey);

        // Ensure the tokens are properly set
        if (userData['idToken'] != null) {
          user.idToken = userData['idToken'];
        }
        if (userData['refreshToken'] != null) {
          user.refreshToken = userData['refreshToken'];
        }

        //print('[CreateUser] User object created:');
        //print('[CreateUser] - uid: ${user.uid}');
        //print('[CreateUser] - idToken exists: ${user.idToken != null}');
        //print(
        //  '[CreateUser] - refreshToken exists: ${user.refreshToken != null}',
        //);
        //print('[CreateUser] - apiKey exists: ${user.apiKey != null}');

        final userCredential = UserCredential(
          user: user,
          additionalUserInfo: AdditionalUserInfo(
            isNewUser: true,
            providerId: 'password',
          ),
          operationType: 'signUp',
        );

        // Update current user in auth
        authInstance.updateCurrentUser(user);

        return userCredential;
      } else {
        throw FirebaseAuthException(
          code: response.body['error']['message'],
          message: response.body['error']['message'],
        );
      }
    } catch (e) {
      print('[CreateUser] Error during creation: $e');
      if (e is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(code: 'signup-error', message: e.toString());
    }
  }
}
