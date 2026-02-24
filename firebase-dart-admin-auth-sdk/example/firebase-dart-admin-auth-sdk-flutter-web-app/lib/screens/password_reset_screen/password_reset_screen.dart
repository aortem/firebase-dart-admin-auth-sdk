// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  String _message = '';

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _message = '';
    });

    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    try {
      await auth.sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _message = 'Password reset email sent successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Reset')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: const Text('Send Password Reset Email'),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(
                color: _message.startsWith('Error') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
