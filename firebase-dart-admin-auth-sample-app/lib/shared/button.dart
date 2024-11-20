import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? title;
  final VoidCallback onTap;
  final bool loading;
  const Button({
    super.key,
    required this.onTap,
    required this.title,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: const Color(0xFFDA70D6), // Button background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      textColor: Colors.black, // Button text color
      elevation: 8, // Elevation for shadow effect
      child: loading
          ? const SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                color: Colors.black, // Spinner color
                strokeWidth: 2,
              ),
            )
          : Text(
              title ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
