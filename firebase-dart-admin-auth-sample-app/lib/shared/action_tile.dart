import 'package:flutter/material.dart';
import 'package:dart_admin_auth_sample_app/utils/extensions.dart';

class ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const ActionTile({
    super.key,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: 10.all,
        decoration: BoxDecoration(
          color: Colors.white, // Tile background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Text color
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.purple, // Icon color
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
