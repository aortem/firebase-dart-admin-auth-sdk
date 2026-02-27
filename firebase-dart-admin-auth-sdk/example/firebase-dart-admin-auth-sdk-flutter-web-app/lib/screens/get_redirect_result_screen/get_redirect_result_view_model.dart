// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// Represents the result of a redirect sign-in flow.
class RedirectResult {
  /// The signed-in user.
  final User? user;

  /// The authentication credential.
  final AuthCredential? credential;

  /// Additional user information.
  final AdditionalUserInfo? additionalUserInfo;

  /// The type of operation that generated this result.
  final String? operationType;

  /// Constructs a [RedirectResult].
  RedirectResult({
    this.user,
    this.credential,
    this.additionalUserInfo,
    this.operationType,
  });

  /// Creates a [RedirectResult] from a JSON map.
  factory RedirectResult.fromJson(Map<String, dynamic> json) {
    return RedirectResult(
      user: json['user'] != null
          ? User(
              uid: json['user']['uid'],
              email: json['user']['email'],
              displayName: json['user']['displayName'],
              photoURL: json['user']['photoUrl'],
              emailVerified: json['user']['emailVerified'] ?? false,
              idToken: json['user']['idToken'],
              refreshToken: json['user']['refreshToken'],
            )
          : null,
      credential: json['credential'] != null
          ? OAuthCredential(
              providerId: json['credential']['providerId'] ?? 'google.com',
              accessToken: json['credential']['accessToken'],
              idToken: json['credential']['idToken'],
              signInMethod: json['credential']['signInMethod'] ?? 'redirect',
            )
          : null,
      additionalUserInfo: json['additionalUserInfo'] != null
          ? AdditionalUserInfo.fromJson(json['additionalUserInfo'])
          : null,
      operationType: json['operationType'],
    );
  }
}

/// ViewModel for the [GetRedirectResultScreen].
class GetRedirectResultViewModel extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  RedirectResult? _redirectResult;

  /// Indicates whether an operation is currently in progress.
  bool get loading => _loading;

  /// The error message, if any.
  String? get error => _error;

  /// The result of the redirect sign-in.
  RedirectResult? get redirectResult => _redirectResult;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Retrieves the redirect result.
  Future<void> getRedirectResults() async {
    _setLoading(true);
    _error = null;
    _redirectResult = null;

    try {
      // First check if we have a current user
      final currentUser = FirebaseApp.instance.getCurrentUser();
      if (currentUser == null) {
        _error = 'No signed-in user found';
        return;
      }

      final result = await FirebaseApp.firebaseAuth?.getRedirectResult();
      log('Redirect result: $result');

      if (result != null) {
        _redirectResult = RedirectResult.fromJson(result);
        BotToast.showText(text: 'Successfully retrieved redirect result');
      } else {
        _error = 'No redirect result available';
        BotToast.showText(text: 'No redirect result available');
      }
    } catch (e) {
      log('Error getting redirect result: $e');
      _error = e is FirebaseAuthException
          ? e.message
          : 'Failed to get redirect result';
      BotToast.showText(text: 'Error: $_error');
    } finally {
      _setLoading(false);
    }
  }
}
