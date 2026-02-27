// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// ViewModel for the Apple Sign-In screen.
class AppleSignInViewModel {
  /// The [FirebaseAuth] instance used for authentication.
  final FirebaseAuth auth;

  /// Creates an instance of [AppleSignInViewModel] with the given [auth].
  AppleSignInViewModel({required this.auth});

  /// Signs in the user with Apple using the provided [idToken] and optional [nonce].
  Future<UserCredential> signInWithApple(
    String idToken, {
    String? nonce,
  }) async {
    if (idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-id-token',
        message: 'Apple ID Token must not be empty',
      );
    }

    return await auth.signInWithApple(idToken, nonce: nonce);
  }
}
