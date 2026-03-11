// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/set_language_code_screen/set_language_code_screen_view_model.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A screen for setting the language code.
class SetLanguageCodeScreen extends StatefulWidget {
  /// Constructs the [SetLanguageCodeScreen] widget.
  const SetLanguageCodeScreen({super.key});

  @override
  State<SetLanguageCodeScreen> createState() => _SetLanguageCodeScreenState();
}

class _SetLanguageCodeScreenState extends State<SetLanguageCodeScreen> {
  final TextEditingController _languageCodeController = TextEditingController();

  @override
  void dispose() {
    _languageCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SetLanguageCodeScreenViewModel(),
      child: Consumer<SetLanguageCodeScreenViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: 20.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputField(
                    controller: _languageCodeController,
                    label: 'Language Code',
                  ),
                  20.vSpace,
                  Button(
                    onTap: () =>
                        value.setLanguageCode(_languageCodeController.text),
                    loading: value.loading,
                    title: 'Set Language Code',
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
