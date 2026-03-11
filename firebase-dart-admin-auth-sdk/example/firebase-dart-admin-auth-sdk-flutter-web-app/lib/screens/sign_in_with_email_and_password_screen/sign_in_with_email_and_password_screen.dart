// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign_in_with_email_and_password_view_model.dart';

/// A screen for signing in with email and password.
class SignInWithEmailAndPasswordScreen extends StatefulWidget {
  /// Constructs the [SignInWithEmailAndPasswordScreen] widget.
  const SignInWithEmailAndPasswordScreen({super.key});

  @override
  State<SignInWithEmailAndPasswordScreen> createState() =>
      _SignInWithEmailAndPasswordScreenState();
}

class _SignInWithEmailAndPasswordScreenState
    extends State<SignInWithEmailAndPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInWithEmailAndPasswordViewModel(),
      child: Consumer<SignInWithEmailAndPasswordViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                    controller: _emailController,
                    hint: 'test@gmail.com',
                    label: 'Email',
                  ),
                  20.vSpace,
                  InputField(
                    controller: _passwordController,
                    hint: '******',
                    label: 'Password',
                    obscure: true,
                  ),
                  20.vSpace,
                  Button(
                    onTap: () {
                      value.signIn(
                        _emailController.text,
                        _passwordController.text,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        ),
                      );
                    },
                    title: 'Sign In',
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
