// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:provider/provider.dart';

/// A screen to revoke an access token and sign out the user.
class RevokeAccessTokenScreen extends StatefulWidget {
  /// Creates a [RevokeAccessTokenScreen].
  const RevokeAccessTokenScreen({super.key});

  @override
  State<RevokeAccessTokenScreen> createState() =>
      RevokeAccessTokenScreenState();
}

/// The state for [RevokeAccessTokenScreen].
class RevokeAccessTokenScreenState extends State<RevokeAccessTokenScreen> {
  String _result = '';

  Future<void> _revokeAccessToken() async {
    setState(() {
      _result = 'Revoking access token...';
    });

    try {
      final auth = Provider.of<FirebaseAuth>(context, listen: false);

      // Revoke the token
      await auth.revokeToken('');

      setState(() {
        _result =
            'Access token revoked successfully. You have been signed out.';
      });

      // Navigate back to the splash screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed('/');
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revoke Access Token')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _revokeAccessToken,
              child: const Text('Revoke Access Token and Sign Out'),
            ),
            const SizedBox(height: 16),
            Text(_result, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
