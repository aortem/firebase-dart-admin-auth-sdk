// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/apply_action_code_screen/apply_action_code_screen_view_model.dart';
import 'package:firebase/screens/home_screen/home_screen.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplyActionCodeScreen extends StatefulWidget {
  const ApplyActionCodeScreen({super.key});

  @override
  State<ApplyActionCodeScreen> createState() => _ApplyActionCodeScreenState();
}

class _ApplyActionCodeScreenState extends State<ApplyActionCodeScreen> {
  final TextEditingController _actionCodeController = TextEditingController();

  @override
  void dispose() {
    _actionCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplyActionCodeScreenViewModel(),
      child: Consumer<ApplyActionCodeScreenViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(
                    controller: _actionCodeController,
                    label: 'Action Code',
                    hint: '',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () => value.applyActionCode(
                      _actionCodeController.text,
                      () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      ),
                    ),
                    title: 'Apply Action Code',
                    loading: value.loading,
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
