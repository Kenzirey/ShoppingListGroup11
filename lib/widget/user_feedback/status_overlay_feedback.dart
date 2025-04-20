import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StatusOverlayFeedback {
  static OverlayEntry? _overlayEntry;

  /// A private helper to build a styled overlay with a blurred background.
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
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width *
                        0.4,
                    child: Lottie.asset(
                      lottieAsset,
                      repeat: false,
                      fit: BoxFit.contain, // scale to box
                    ),
                  ),
                  const SizedBox(height: 8),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                    decoration: TextDecoration.none,
                  ),
            ),
          if (title != null && message != null) const SizedBox(height: 12),
          if (message != null)
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    decoration: TextDecoration.none,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                    decoration: TextDecoration.none,
                  ),
            ),
          if (title != null && message != null) const SizedBox(height: 12),
          if (message != null)
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.none,
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
            child: Text(
              'Try Again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
            ),
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
