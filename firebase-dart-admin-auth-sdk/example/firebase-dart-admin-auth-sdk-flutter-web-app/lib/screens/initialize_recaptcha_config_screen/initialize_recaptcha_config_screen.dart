// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// A screen for initializing reCAPTCHA configuration.
class InitializeRecaptchaConfigScreen extends StatelessWidget {
  /// The [FirebaseAuth] instance.
  final FirebaseAuth auth;

  /// Constructs the [InitializeRecaptchaConfigScreen] with the given [auth] instance.
  const InitializeRecaptchaConfigScreen({super.key, required this.auth});

  Future<void> _initializeRecaptchaConfig(BuildContext context) async {
    try {
      // Replace with your actual reCAPTCHA site key
      const String siteKey =
          'YOUR_RECAPTCHA_SITE_KEY'; //'YOUR_RECAPTCHA_SITE_KEY';
      await auth.initializeRecaptchaConfig(siteKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('reCAPTCHA config initialized successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize reCAPTCHA config: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initialize reCAPTCHA Config')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _initializeRecaptchaConfig(context),
          child: const Text('Initialize reCAPTCHA Config'),
        ),
      ),
    );
  }
}
