import 'package:firebase_dart_admin_auth_sdk/src/firebase_auth.dart';

void main() async {
  final auth =
      FirebaseAuth(apiKey: 'AIzaSyBli2c-dmD4w2kLHmZU3UtewETvuruVAN4', projectId: 'fire-base-dart-admin-auth-sdk');

  try {
    // Sign up a new user
    final newUser = await auth.createUserWithEmailAndPassword(
        'newuser@example.com', 'password123');
    print('User created: ${newUser?.user.displayName}');
    print('User created: ${newUser?.user.email}');

    // Sign in with the new user
    final userCredential = await auth.signInWithEmailAndPassword(
        'newuser@example.com', 'password123');
    print('Signed in: ${userCredential?.user.email}');
  } catch (e) {
    print('Error: $e');
  }
}
