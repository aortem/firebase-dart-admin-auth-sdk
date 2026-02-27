// ignore_for_file: library_private_types_in_public_apipublic_member_api_docs uri_does_not_exist undefined_class undefined_function undefined_identifier undefined_method undefined_getter creation_with_non_type extends_non_class super_formal_parameter_without_associated_named undefined_super_member override_on_non_overriding_member non_type_as_type_argument non_constant_list_element unchecked_use_of_nullable_value

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

/// A screen to monitor changes to the ID token.
class IdTokenChangedScreen extends StatefulWidget {
  /// The [FirebaseAuth] instance to monitor.
  final FirebaseAuth auth;

  /// Creates an [IdTokenChangedScreen].
  const IdTokenChangedScreen({super.key, required this.auth});

  @override
  State<IdTokenChangedScreen> createState() => IdTokenChangedScreenState();
}

/// The state for [IdTokenChangedScreen].
class IdTokenChangedScreenState extends State<IdTokenChangedScreen> {
  String _tokenStatus = 'Monitoring ID token...';
  late StreamSubscription<User?> _subscription;
  DateTime? _lastTokenUpdate;

  @override
  void initState() {
    super.initState();
    _setupIdTokenListener();
  }

  void _setupIdTokenListener() {
    _subscription = widget.auth.onIdTokenChanged().listen(
      (User? user) {
        setState(() {
          _lastTokenUpdate = DateTime.now();
          _tokenStatus = user != null
              ? 'Token updated for user: ${user.email ?? user.uid}'
              : 'No active token';
        });
      },
      onError: (error) {
        setState(() {
          _tokenStatus = 'Error: $error';
        });
      },
    );
  }

  Future<void> _refreshToken() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      try {
        await user.getIdToken(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token refresh requested')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Token refresh failed: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user signed in')));
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Token Monitor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token Status:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_tokenStatus),
            if (_lastTokenUpdate != null) ...[
              const SizedBox(height: 8),
              Text('Last Updated: ${_lastTokenUpdate!.toString()}'),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshToken,
              child: const Text('Refresh Token'),
            ),
          ],
        ),
      ),
    );
  }
}
