// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ViewModel for the [GCPSignInScreen].
class GCPSignInViewModel extends ChangeNotifier {
  /// Indicates whether an operation is currently in progress.
  bool loading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/cloud-platform'],
  );

  /// Sets the loading state to [load] and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// method to sign in with Google
  Future<void> signIn(VoidCallback onSuccess) async {
    try {
      setLoading(true);

      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Sign in was cancelled by the user',
        );
      }

      // Get auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Use tokens to sign in with Firebase
      await FirebaseApp.firebaseAuth?.signInWithGCP(
        clientId: googleAuth.accessToken!,
        clientSecret: googleAuth.idToken!,
      );

      onSuccess();
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
    setLoading(false);
  }

  /// method to sign out
  Future<void> signOut() async {
    try {
      setLoading(true);
      await Future.wait([
        _googleSignIn.signOut(),
        FirebaseApp.firebaseAuth?.signOut() ?? Future.value(),
      ]);
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }
}
