// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// ViewModel for the [FetchSignInMethodsScreen].
class FetchSignInMethodsViewModel extends ChangeNotifier {
  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// The list of sign-in methods fetched for the email.
  List<String>? result;

  /// Sets the loading state to [load] and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Fetches the sign-in methods for the given [email].
  Future<void> fetchSignInMethods(String email) async {
    if (email.isEmpty) {
      BotToast.showText(text: 'Please enter an email');
      return;
    }

    try {
      setLoading(true);
      var fetchedResult = await FirebaseApp.firebaseAuth
          ?.fetchSignInMethodsForEmail(email);
      result = fetchedResult?.cast<String>(); // Explicitly cast to List<String>
      notifyListeners();
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }
}
