import 'package:flutter/material.dart';

/// A customizable TopBar that can either show a back button or a drawer menu icon,
/// and allows a custom title widget (which could be a search bar).
class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget titleWidget;
  final bool showBackButton;
  final VoidCallback? onLeadingIconPressed;

  const CustomTopBar({
    super.key,
    required this.titleWidget,
    this.showBackButton = false,
    this.onLeadingIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      title: titleWidget,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 82,
      leading: IconButton(
        splashRadius: 24,
        iconSize: 30,
        icon: Icon(
          showBackButton ? Icons.arrow_back : Icons.menu,
        ),
        onPressed: showBackButton
            ? () {
                // This pops the current route.
                Navigator.of(context).pop();
              }
            : onLeadingIconPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
