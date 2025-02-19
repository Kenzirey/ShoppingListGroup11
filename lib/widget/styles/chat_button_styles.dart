import 'package:flutter/material.dart';

/// Represents a collection of button styles for the chat screen.
class ButtonStyles {
  // Base style for buttons with configurable background color.
  static ButtonStyle baseStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12), // Fixed vertical padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: backgroundColor,
    );
  }
  // Style for the "Add for later" button.
  static ButtonStyle addForLater(Color color) {
    return baseStyle(color);
  }

  // Style for the "View Recipe" button.
  static ButtonStyle viewRecipe(Color color) {
    return baseStyle(color);
  }
}
