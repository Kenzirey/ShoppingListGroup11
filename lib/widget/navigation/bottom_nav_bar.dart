import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the entire app. Always visible,
/// allows the user to navigate to the most used screens.
/// Index 0 is reserved to open the drawer.
class BottomNavBar extends StatelessWidget {
  final StatefulNavigationShell nav;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BottomNavBar({
    super.key,
    required this.nav,
    required this.scaffoldKey,
  });

//TODO: remove text from bottom bar, only keep hint text and icons.
  @override
  Widget build(BuildContext context) {
    final int effectiveIndex = nav.currentIndex;
    return NavigationBar(
      selectedIndex: effectiveIndex,
      // Only show the label for the selected item. (hover effect)
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      onDestinationSelected: (i) {
        if (i == 0) {
          scaffoldKey.currentState?.openDrawer();
        } else {
          nav.goBranch(i);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.document_scanner), label: 'Scan Receipt'),
        NavigationDestination(icon: Icon(Icons.history), label: 'Archive'),
      ],
    );
  }
}
