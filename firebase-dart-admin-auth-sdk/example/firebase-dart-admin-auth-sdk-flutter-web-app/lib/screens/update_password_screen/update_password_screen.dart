// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/update_password_screen/update_password_screen_view_model.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A screen for updating the user's password.
class UpdatePasswordScreen extends StatefulWidget {
  /// Constructs the [UpdatePasswordScreen] widget.
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UpdatePasswordScreenViewModel(),
      child: Consumer<UpdatePasswordScreenViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(
                    controller: _passwordController,
                    label: 'Password',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () => value.updatePassword(_passwordController.text),
                    loading: value.loading,
                    title: 'Update Password',
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
