// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

/// ViewModel for the [SendSignInWithEmailLinkScreen].
class SendSignInWithEmailLinkScreenViewModel extends ChangeNotifier {
  /// Inidcates whether an operation is currently in progress.
  bool loading = false;

  /// Indicates whether the sign-in is currently in progress.
  bool signingIn = false;

  final FirebaseAuth? _firebaseSdk = FirebaseApp.firebaseAuth;

  /// Sets the loading state and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Sets the signingIn state and notifies listeners.
  void setSigningIn(bool value) {
    signingIn = value;
    notifyListeners();
  }

  /// Sends a sign-in link to the provided [email].
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      setLoading(true);

      await _firebaseSdk?.sendSignInLinkToEmail(email);

      BotToast.showText(text: 'Sign in link sent to $email');
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Signs in with the given [email] and [emailLink].
  Future<void> signInWithEmailLink(
    String email,
    String emailLink,
    VoidCallback onSuccess,
  ) async {
    try {
      setSigningIn(true);

      final userCredential = await _firebaseSdk?.signInWithEmailLink(
        email,
        emailLink,
      );

      if (userCredential != null) {
        BotToast.showText(
          text: 'Signed in successfully: ${userCredential.user.email}',
        );
        onSuccess();
      } else {
        BotToast.showText(text: 'Failed to sign in');
      }
    } catch (e) {
      BotToast.showText(text: 'Sign in failed: ${e.toString()}');
    } finally {
      setSigningIn(false);
    }
  }
}
