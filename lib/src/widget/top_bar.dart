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

  // Added padding so that it doesn't kiss the top bar of the phone.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: AppBar(
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
        leading: Builder(
          builder: (context) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  leadingIcon,
                  size: 30,
                ),
                onPressed: onLeadingIconPressed,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 20); // NO SMUSH
}
