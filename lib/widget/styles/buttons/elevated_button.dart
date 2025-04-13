import 'package:flutter/material.dart';

class SolidButton extends StatelessWidget {
  const SolidButton({
    super.key,
    required this.context,
    required this.onPressed,
    required this.child,
  });

  final BuildContext context;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox( // Changed to SizedBox for direct height control
      height: 56,
      width: double.infinity, // Ensure it takes full width if needed
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0, // Removed shadows
          backgroundColor: theme.colorScheme.primaryContainer, // Set background color
          shadowColor: Colors.transparent, // Removed shadow color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56), // Ensure correct size
        ),
        child: child,
      ),
    );
  }
}