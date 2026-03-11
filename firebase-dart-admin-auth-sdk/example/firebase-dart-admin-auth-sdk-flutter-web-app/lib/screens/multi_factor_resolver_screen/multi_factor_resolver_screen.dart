// ignore_for_file: implementation_imports, public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value

import 'package:flutter/material.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:provider/provider.dart';
import 'package:firebase_dart_admin_auth_sdk/src/auth/get_multi_factor.dart'
    as multi_factor;

/// A screen to resolve multi-factor authentication.
class MultiFactorResolverScreen extends StatefulWidget {
  /// Creates a [MultiFactorResolverScreen].
  const MultiFactorResolverScreen({super.key});

  @override
  State<MultiFactorResolverScreen> createState() =>
      MultiFactorResolverScreenState();
}

/// The state for [MultiFactorResolverScreen].
class MultiFactorResolverScreenState extends State<MultiFactorResolverScreen> {
  /// The multi-factor resolver.
  multi_factor.MultiFactorResolver? resolver;

  /// Gets the multi-factor resolver.
  Future<void> getMultiFactorResolver() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    try {
      final mockError = multi_factor.MultiFactorError(
        hints: [
          multi_factor.MultiFactorInfo(
            factorId: 'totp',
            displayName: 'Authenticator app',
            enrollmentId: 'mock-totp-enrollment',
          ),
        ],
        session: multi_factor.MultiFactorSession(
          pendingCredential: 'mock-session-id',
        ),
        rawResponse: const {},
      );
      final obtainedResolver = await auth.getMultiFactorResolver(mockError);
      setState(() {
        resolver = obtainedResolver;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get multi-factor resolver: $e')),
      );
    }
  }

  /// Resolves the sign-in with the multi-factor assertion.
  Future<void> resolveSignIn() async {
    if (resolver == null) return;

    try {
      final mockAssertion = multi_factor.MultiFactorAssertion(
        factorId: 'totp',
        secret: '123456',
      );
      final userCredential = await resolver!.resolveSignIn(mockAssertion);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as: ${userCredential.user.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to resolve sign-in: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Factor Resolver')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: getMultiFactorResolver,
              child: const Text('Get Multi-Factor Resolver'),
            ),
            if (resolver != null) ...[
              const SizedBox(height: 20),
              const Text('Resolver obtained. Hints:'),
              ...resolver!.hints.map((hint) => Text(hint.displayName)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: resolveSignIn,
                child: const Text('Resolve Sign-In'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
