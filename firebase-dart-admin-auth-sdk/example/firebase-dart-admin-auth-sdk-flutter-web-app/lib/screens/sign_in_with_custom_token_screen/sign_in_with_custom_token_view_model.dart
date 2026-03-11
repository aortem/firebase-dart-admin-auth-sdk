// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

/// ViewModel for the [SignInWithCustomTokenScreen].
class SignInWithCustomTokenViewModel extends ChangeNotifier {
  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// Sets the loading state and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Signs in with a custom token using the provided [uid].
  Future<void> signInWithCustomToken(String uid, VoidCallback onSuccess) async {
    try {
      setLoading(true);

      await FirebaseApp.firebaseAuth?.signInWithCustomToken(uid);

      onSuccess();
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
    setLoading(false);
  }
}
