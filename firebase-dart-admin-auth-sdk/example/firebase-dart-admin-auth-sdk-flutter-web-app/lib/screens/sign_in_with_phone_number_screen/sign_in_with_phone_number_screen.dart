// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign_in_with_phone_number_view_model.dart';

/// A screen for signing in with a phone number.
class SignInWithPhoneNumberScreen extends StatefulWidget {
  /// Constructs the [SignInWithPhoneNumberScreen] widget.
  const SignInWithPhoneNumberScreen({super.key});

  @override
  State<SignInWithPhoneNumberScreen> createState() =>
      _SignInWithPhoneNumberScreenState();
}

class _SignInWithPhoneNumberScreenState
    extends State<SignInWithPhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInWithPhoneNumberViewModel(),
      child: Consumer<SignInWithPhoneNumberViewModel>(
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(title: const Text('Sign In with Phone Number')),
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                    controller: _phoneController,
                    hint: '+16505550101',
                    label: 'Phone Number',
                    textInputType: TextInputType.phone,
                  ),
                  20.vSpace,
                  Button(
                    onTap: model.loading || model.codeSent
                        ? () {}
                        : () =>
                              model.sendVerificationCode(_phoneController.text),
                    title: 'Send Verification Code',
                    loading: model.loading && !model.codeSent,
                  ),
                  if (model.codeSent) ...[
                    20.vSpace,
                    InputField(
                      controller: _smsCodeController,
                      hint: '123456',
                      label: 'SMS Code',
                      textInputType: TextInputType.number,
                    ),
                    20.vSpace,
                    Button(
                      onTap: model.loading
                          ? () {}
                          : () => model.verifyCode(_smsCodeController.text, () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }),
                      title: 'Verify Code',
                      loading: model.loading && model.codeSent,
                    ),
                  ],
                  20.vSpace,
                  const Text(
                    'Use Firebase test phone numbers like +16505550101',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
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
