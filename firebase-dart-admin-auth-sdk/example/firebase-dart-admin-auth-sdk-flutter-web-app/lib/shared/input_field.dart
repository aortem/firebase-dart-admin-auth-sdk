// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:flutter/material.dart';

/// A custom input field widget.
class InputField extends StatelessWidget {
  /// The controller for the input field.
  final TextEditingController? controller;

  /// The hint text for the input field.
  final String? hint;

  /// The label for the input field.
  final String? label;

  /// Whether the text should be obscured.
  final bool? obscure;

  /// The type of keyboard to use.
  final TextInputType? textInputType;

  /// Whether the text should be obscured.
  final bool obscureText;

  /// Constructs the [InputField] widget.
  const InputField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscure,
    this.textInputType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure ?? false,
      // obscureText: obscureText,
      keyboardType: textInputType,
      decoration: InputDecoration(hintText: hint, labelText: label),
    );
  }
}
