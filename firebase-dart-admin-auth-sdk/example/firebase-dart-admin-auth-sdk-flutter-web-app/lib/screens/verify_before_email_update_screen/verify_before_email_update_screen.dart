// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/apply_action_code_screen/apply_action_code_screen.dart';
import 'package:firebase/screens/verify_before_email_update_screen/verify_before_email_update_view_model.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A screen for verifying user before email update.
class VerifyBeforeEmailUpdate extends StatefulWidget {
  /// Constructs the [VerifyBeforeEmailUpdate] widget.
  const VerifyBeforeEmailUpdate({super.key});

  @override
  State<VerifyBeforeEmailUpdate> createState() =>
      _VerifyBeforeEmailUpdateState();
}

class _VerifyBeforeEmailUpdateState extends State<VerifyBeforeEmailUpdate> {
  final TextEditingController _verifyPasswordRestController =
      TextEditingController();

  @override
  void dispose() {
    _verifyPasswordRestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerifyBeforeEmailUpdateViewModel(),
      child: Consumer<VerifyBeforeEmailUpdateViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(
                    controller: _verifyPasswordRestController,
                    label: 'New Email ',
                    hint: 'johndoe@gmail.com',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () async => value.verifyBeforeEmailUpdate(
                      _verifyPasswordRestController.text,
                      onFinished: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ApplyActionCodeScreen(),
                        ),
                      ),
                    ),
                    title: 'Verify new email',
                    loading: value.loading,
                  ),
                  20.vSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
