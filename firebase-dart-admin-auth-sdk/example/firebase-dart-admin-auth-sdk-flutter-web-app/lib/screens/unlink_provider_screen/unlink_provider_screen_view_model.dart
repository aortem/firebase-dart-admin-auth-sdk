// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

/// ViewModel for the [UnlinkProviderScreen].
class UnlinkProviderScreenViewModel extends ChangeNotifier {
  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// Sets the loading state and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Unlinks the provider with the given [providerId].
  Future<void> unLinkProvider(String providerId) async {
    try {
      setLoading(true);

      await FirebaseApp.firebaseAuth?.unlinkProvider(providerId);

      BotToast.showText(text: 'Provider Unlinked Successfully');
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }
}
