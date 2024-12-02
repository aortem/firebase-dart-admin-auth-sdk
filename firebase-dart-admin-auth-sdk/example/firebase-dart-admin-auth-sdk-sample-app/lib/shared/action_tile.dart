import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';

class ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  final String? tooltipMessage; // Add a tooltip message

  const ActionTile({
    super.key,
    required this.onTap,
    required this.title,
    this.loading = false,
    this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage ??
          'Perform action: $title', // Display tooltip if provided
      child: InkWell(
        onTap: loading ? null : onTap, // Disable tap while loading
        child: Container(
          padding: 10.all,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.purple,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              loading
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.purple, // Match the theme
                      ),
                    )
                  : Text(title),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
