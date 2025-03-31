import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StatusOverlayFeedback {
  static OverlayEntry? _overlayEntry;

  // Private helper to build a styled overlay with a blurred background.
  static OverlayEntry _buildOverlayEntry({
    required BuildContext context,
    required String lottieAsset,
    required Widget content,
  }) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blurred background.
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Centered overlay container.
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                // You can adjust the background color or opacity here
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottieAsset,
                    repeat: false,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a success overlay.
  ///
  /// The caller only needs to supply the [title] and [message] text.
  /// The overlay automatically dismisses after [autoDismissDuration].
  static Future<void> showSuccessOverlay(
    BuildContext context, {
    String? title,
    String? message,
    String lottieAsset = 'assets/animations/success.json',
    Duration autoDismissDuration = const Duration(seconds: 2),
  }) async {
    removeOverlay();
    _overlayEntry = _buildOverlayEntry(
      context: context,
      lottieAsset: lottieAsset,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          if (title != null && message != null) const SizedBox(height: 12),
          if (message != null)
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    await Future.delayed(autoDismissDuration);
    removeOverlay();
  }

  /// Shows an error overlay.
  ///
  /// The caller only needs to supply the [title] and [message] text.
  /// A default "Try Again" button is provided to dismiss the overlay.
  static void showErrorOverlay(
    BuildContext context, {
    String? title,
    String? message,
    String lottieAsset = 'assets/animations/error.json',
  }) {
    removeOverlay();
    _overlayEntry = _buildOverlayEntry(
      context: context,
      lottieAsset: lottieAsset,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          if (title != null && message != null) const SizedBox(height: 12),
          if (message != null)
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: removeOverlay,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Removes any currently displayed overlay.
  static void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
