// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:provider/provider.dart';

/// A screen to confirm a password reset with a code from a reset link.
class ConfirmPasswordResetScreen extends StatefulWidget {
  /// Creates a [ConfirmPasswordResetScreen].
  const ConfirmPasswordResetScreen({super.key});

  @override
  ConfirmPasswordResetScreenState createState() =>
      ConfirmPasswordResetScreenState();
}

/// The state for [ConfirmPasswordResetScreen].
class ConfirmPasswordResetScreenState
    extends State<ConfirmPasswordResetScreen> {
  final TextEditingController _resetLinkController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> _confirmPasswordReset() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    try {
      String oobCode = _extractOobCode(_resetLinkController.text);
      await auth.confirmPasswordReset(oobCode, _newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset confirmed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm password reset: $e')),
      );
    }
  }

  String _extractOobCode(String resetLink) {
    Uri uri = Uri.parse(resetLink);
    return uri.queryParameters['oobCode'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Password Reset')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _resetLinkController,
              decoration: const InputDecoration(labelText: 'Reset Link'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _confirmPasswordReset,
              child: const Text('Confirm Password Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
