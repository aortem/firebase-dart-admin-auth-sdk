// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:provider/provider.dart';

/// A screen for checking if a link is a valid sign-in with email link.
class IsSignInWithEmailLinkScreen extends StatefulWidget {
  /// Constructs the [IsSignInWithEmailLinkScreen] widget.
  const IsSignInWithEmailLinkScreen({super.key});

  @override
  State<IsSignInWithEmailLinkScreen> createState() =>
      IsSignInWithEmailLinkScreenState();
}

/// State for [IsSignInWithEmailLinkScreen]
class IsSignInWithEmailLinkScreenState
    extends State<IsSignInWithEmailLinkScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool? _isValidLink;

  void _checkLink() {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    setState(() {
      _isValidLink = auth.isSignInWithEmailLink(_linkController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Email Sign-In Link')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Email Sign-In Link',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkLink,
              child: const Text('Check Link'),
            ),
            const SizedBox(height: 16),
            if (_isValidLink != null)
              Text(
                _isValidLink!
                    ? 'Valid email sign-in link'
                    : 'Invalid email sign-in link',
                style: TextStyle(
                  color: _isValidLink! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
