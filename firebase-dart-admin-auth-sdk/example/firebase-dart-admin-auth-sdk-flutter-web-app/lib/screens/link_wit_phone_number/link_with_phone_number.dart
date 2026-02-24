// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/button.dart';
import '../../shared/input_field.dart';

class LinkPhoneNumberScreen extends StatefulWidget {
  const LinkPhoneNumberScreen({super.key});

  @override
  State<LinkPhoneNumberScreen> createState() => _LinkPhoneNumberScreenState();
}

class _LinkPhoneNumberScreenState extends State<LinkPhoneNumberScreen> {
  final TextEditingController phoneLinkController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  @override
  void dispose() {
    phoneLinkController.dispose();
    super.dispose();
  }

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
                controller: codeController,
                label: 'Phone number ',
                hint: '',
              ),
              20.vSpace,
              InputField(
                controller: phoneLinkController,
                label: 'veify code ',
                hint: '',
              ),
              Button(
                onTap: () async {
                  if (phoneLinkController.text.length >= 11) {
                    if (kDebugMode) {
                      print('Please enter atleast 11 digit number');
                    }
                    BotToast.showText(
                      text: 'Please enter atleast 11 digit number',
                    );
                  } else {
                    await FirebaseApp.firebaseAuth
                        ?.firebasePhoneNumberLinkMethod(
                          phoneLinkController.text,
                          codeController.text,
                        );
                  }
                },
                title: 'Send',
              ),
              20.vSpace,
            ],
          ),
        ),
      ),
    );
  }
}
