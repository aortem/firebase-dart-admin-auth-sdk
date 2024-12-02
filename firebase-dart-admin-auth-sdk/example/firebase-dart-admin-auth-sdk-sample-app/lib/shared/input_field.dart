import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool? obscure;
  final TextInputType? textInputType;
  final bool obscureText;
  final String? tooltip; // New field for the tooltip message

  const InputField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscure,
    this.textInputType,
    this.obscureText = false,
    this.tooltip, // Initialize the tooltip field
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '', // Display tooltip if provided
      child: TextField(
        controller: controller,
        obscureText: obscure ?? false,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
        ),
      ),
    );
  }
}
