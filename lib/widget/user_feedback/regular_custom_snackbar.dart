import 'package:flutter/material.dart';

/// A reusable snackbar widget that displays a title, message,
/// and an optional action button snapped to the right.
/// Contains all the styling related to the snackbar.
class CustomSnackbar extends StatelessWidget {
  final String title;
  final String message;

  final String? actionText; // such as undo
  final VoidCallback? onAction;
  final double? maxHeight;
  final EdgeInsetsGeometry innerPadding;

  const CustomSnackbar({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.maxHeight,
    this.innerPadding = EdgeInsets.zero,
  });

  /// Build a SnackBar with our default styling
  static SnackBar buildSnackBar({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    double? maxHeight,
    EdgeInsetsGeometry innerPadding = EdgeInsets.zero,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: CustomSnackbar(
        title: title,
        message: message,
        actionText: actionText,
        onAction: onAction,
        maxHeight: maxHeight,
        innerPadding: innerPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 60.0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryContainer, // background color of the container of the snackbar
        borderRadius: BorderRadius.zero, // flush with screen edges, no padding on sides
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: innerPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.tertiary, // text of the main part of the snackbar
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (actionText != null && onAction != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryContainer, // background of the button
                  foregroundColor: theme.primary, // color of the text
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(actionText!),
              ),
            ),
        ],
      ),
    );
  }
}
