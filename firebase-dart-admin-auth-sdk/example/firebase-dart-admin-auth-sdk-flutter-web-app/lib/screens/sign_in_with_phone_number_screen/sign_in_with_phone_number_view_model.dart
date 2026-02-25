// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

/// ViewModel for the [SignInWithPhoneNumberScreen].
class SignInWithPhoneNumberViewModel extends ChangeNotifier {
  /// Indicates whether an operation is currently in progress.
  bool loading = false;

  /// Indicates whether the verification code has been sent.
  bool codeSent = false;

  /// The verification ID received from Firebase.
  String? verificationId;

  /// Sets the loading state and notifies listeners.
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  /// Sets the codeSent state and verificationId, then notifies listeners.
  void setCodeSent(bool sent, String? verId) {
    codeSent = sent;
    verificationId = verId;
    notifyListeners();
  }

  /// Sends a verification code to the provided [phoneNumber].
  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      setLoading(true);

      // Simulating sending verification code
      await Future.delayed(const Duration(seconds: 2));
      setCodeSent(true, 'test_verification_id');

      BotToast.showText(text: 'Verification code sent to $phoneNumber');
    } catch (e) {
      BotToast.showText(text: 'Failed to send verification code: $e');
    }
    setLoading(false);
  }

  /// Verifies the [smsCode] and signs in the user.
  Future<void> verifyCode(String smsCode, VoidCallback onSuccess) async {
    try {
      setLoading(true);

      if (smsCode != '123456') {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Invalid verification code. Use 123456 for testing.',
        );
      }

      // Simulate sign in
      await Future.delayed(const Duration(seconds: 2));

      onSuccess();
      BotToast.showText(text: 'Signed in successfully');
    } catch (e) {
      BotToast.showText(text: 'Failed to sign in: $e');
    }
    setLoading(false);
  }
}
