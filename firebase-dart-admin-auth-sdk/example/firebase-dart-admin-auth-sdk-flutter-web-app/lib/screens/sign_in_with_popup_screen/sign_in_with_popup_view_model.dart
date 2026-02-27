// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// ViewModel for the [SignInWithPopupScreen].
class SignInWithPopupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  /// The current user.
  User? user;

  /// Inidicates whether sign-in is in progress.
  bool isLoading = false;

  /// Error message if sign-in fails.
  String? errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  /// Constructs the [SignInWithPopupViewModel] with the given [auth] instance.
  SignInWithPopupViewModel(this._auth) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authStateSubscription = _auth.onAuthStateChanged().listen(
      (User? updatedUser) {
        user = updatedUser;
        notifyListeners();
      },
      onError: (error) {
        errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Signs in with Google using a popup.
  Future<void> signInWithGoogle() async {
    await _signInWithPopup(
      GoogleAuthProvider(),
      'YOUR_CLIENT_ID', //Replace with your actual google ClientID
    );
  }

  /// Signs in with Facebook using a popup.
  Future<void> signInWithFacebook() async {
    await _signInWithPopup(
      FacebookAuthProvider(),
      'YOUR_FACEBOOK_APP_ID', // Replace with your actual Facebook App ID
    );
  }

  Future<void> _signInWithPopup(AuthProvider provider, String clientId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.signInWithPopup(provider, clientId);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'An unexpected error occurred';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
