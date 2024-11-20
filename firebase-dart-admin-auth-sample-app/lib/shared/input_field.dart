import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool? obscure;
  final TextInputType? textInputType;
  const InputField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscure,
    this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for contrast
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding inside the box
      child: TextField(
        controller: controller,
        obscureText: obscure ?? false,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          border: InputBorder.none, // Remove default border
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87, // Text color
        ),
      ),
    );
  }
}
