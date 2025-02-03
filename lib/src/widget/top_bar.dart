import 'package:flutter/material.dart';

/// Topbar of the app, which has the app name and navigation drawer (menu).
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeadingIconPressed;

  const TopBar({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onLeadingIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Set a custom toolbar height to add vertical space.
      toolbarHeight: 80, // or kToolbarHeight + 20, etc.

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,

      leadingWidth: 82, // LEFT MARGIN

      leading: IconButton(
        // Control the splash radius to keep it roouuund.
        splashRadius: 24,
        iconSize: 30,
        icon: Icon(leadingIcon),
        onPressed: onLeadingIconPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
