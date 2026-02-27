// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

/// ViewModel for the [SignUpScreen].
class SignUpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  /// Constructs the [SignUpViewModel] with the given [auth] instance.
  SignUpViewModel(this._auth);

  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// Sets the loading state and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Signs up a user with [email] and [password].
  Future<void> signUp(
    String email,
    String password,
    VoidCallback onSuccess,
  ) async {
    try {
      setLoading(true);

      UserCredential? userCredential = await _auth
          .createUserWithEmailAndPassword(email, password);

      BotToast.showText(text: '${userCredential.user.email} just signed up');
      onSuccess();
    } catch (e) {
      BotToast.showText(text: 'Sign up error: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}
