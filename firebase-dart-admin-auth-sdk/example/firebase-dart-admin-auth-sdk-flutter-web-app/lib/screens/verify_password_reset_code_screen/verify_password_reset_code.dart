// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:flutter/material.dart';

import '../../shared/button.dart';
import '../../shared/input_field.dart';

/// A screen for verifying a password reset code.
class VerifyPasswordResetCode extends StatelessWidget {
  /// Constructs the [VerifyPasswordResetCode] widget.
  VerifyPasswordResetCode({super.key});

  /// Controller for the password reset code input field.
  final TextEditingController verifyPasswordRestController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: 20.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: verifyPasswordRestController,
                label: 'Code',
                hint: '',
              ),
              20.vSpace,
              Button(
                onTap: () async {
                  try {
                    // Attempt to verify the password reset code
                    var email = await FirebaseApp.firebaseAuth
                        ?.verifyPasswordResetCode(
                          verifyPasswordRestController.text,
                        );

                    if (email != null) {
                      BotToast.showText(
                        text: "Password reset code verified. Email: $email",
                      );

                      log("Password reset code verified. Email: $email");
                      // Proceed with your logic, e.g., redirecting to reset password screen
                    }
                  } catch (e) {
                    BotToast.showText(text: e.toString());
                    // Log the error if verification fails
                    log("Error verifying password reset code: $e");
                    // Optionally show an error message to the user
                  }
                },
                title: 'Verify Code',
              ),
              20.vSpace,
            ],
          ),
        ),
      ),
    );
  }
}
