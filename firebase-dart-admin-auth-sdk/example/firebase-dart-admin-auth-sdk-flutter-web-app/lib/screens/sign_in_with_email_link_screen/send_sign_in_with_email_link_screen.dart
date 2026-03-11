// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:firebase/screens/sign_in_with_email_link_screen/send_sign_in_with_email_link_screen_view_model.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A screen for sending a sign-in email link.
class SendSignInWithEmailLinkScreen extends StatefulWidget {
  /// Constructs the [SendSignInWithEmailLinkScreen] widget.
  const SendSignInWithEmailLinkScreen({super.key});

  @override
  State<SendSignInWithEmailLinkScreen> createState() =>
      _SendSignInWithEmailLinkScreenState();
}

class _SendSignInWithEmailLinkScreenState
    extends State<SendSignInWithEmailLinkScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SendSignInWithEmailLinkScreenViewModel(),
      child: Consumer<SendSignInWithEmailLinkScreenViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(
                    controller: _emailController,
                    label: 'Email',
                    hint: '',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () =>
                        value.sendSignInLinkToEmail(_emailController.text),
                    title: 'Send Sign In Link',
                    loading: value.loading,
                  ),
                  30.vSpace,
                  const Divider(),
                  30.vSpace,
                  InputField(
                    controller: _linkController,
                    label: 'Sign-in Link',
                    hint: 'Paste the sign-in link here',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () => value.signInWithEmailLink(
                      _emailController.text,
                      _linkController.text,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      ),
                    ),
                    title: 'Sign In with Email Link',
                    loading: value.signingIn,
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
