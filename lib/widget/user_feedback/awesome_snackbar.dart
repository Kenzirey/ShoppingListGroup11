import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AwesomeSnackbarWithUndoContent extends StatelessWidget {
  final String title;
  final String message;
  final ContentType contentType;
  final VoidCallback onUndo;

  const AwesomeSnackbarWithUndoContent({
    Key? key,
    required this.title,
    required this.message,
    required this.contentType,
    required this.onUndo,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (contentType) {
      case ContentType.failure:
        return Colors.redAccent;
      case ContentType.success:
        return Colors.green;
      case ContentType.warning:
        return Colors.amber;
      case ContentType.help:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded area for title and message.
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Inline UNDO button.
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onUndo,
            child: const Text('UNDO'),
          ),
        ],
      ),
    );
  }
}
