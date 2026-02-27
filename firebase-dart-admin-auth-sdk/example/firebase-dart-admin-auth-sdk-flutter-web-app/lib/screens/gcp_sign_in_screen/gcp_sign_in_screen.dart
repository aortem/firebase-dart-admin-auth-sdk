// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'gcp_sign_in_view_model.dart';

/// A screen for signing in with Google Cloud Platform (GCP).
class GCPSignInScreen extends StatefulWidget {
  /// Constructs the [GCPSignInScreen] widget.
  const GCPSignInScreen({super.key});

  @override
  State<GCPSignInScreen> createState() => _GCPSignInScreenState();
}

class _GCPSignInScreenState extends State<GCPSignInScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GCPSignInViewModel(),
      child: Consumer<GCPSignInViewModel>(
        builder: (context, value, child) => Scaffold(
          appBar: AppBar(title: const Text('Sign In with GCP')),
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  20.vSpace,
                  const Text(
                    'Sign in with your Google Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  20.vSpace,
                  Button(
                    onTap: () => value.signIn(
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      ),
                    ),
                    title: 'Sign in with Google',
                    loading: value.loading,
                  ),
                  20.vSpace,
                  GestureDetector(
                    onTap: () => showSignMethodsBottomSheet(context),
                    child: const Text(
                      'Explore more sign in options',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
