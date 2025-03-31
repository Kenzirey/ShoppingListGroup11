import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the entire app. Always visible,
/// allows the user to navigate to the most used screens.
/// Index 0 is reserved to open the drawer.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    // Use a valid index when nothing is highlighted.
    final int effectiveIndex = (selectedIndex == -1) ? 0 : selectedIndex;

    return NavigationBar(
      selectedIndex: effectiveIndex,
      // Only show the label for the selected item. (hover effect)
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: (index) {
        if (index == 0) {
          // Open the drawer.
          scaffoldKey.currentState?.openDrawer();
        } else {
          switch (index) {
            case 1:
              context.pushNamed('shoppingList');
              break;
            case 2:
              context.pushNamed('home');
              break;
            case 3:
              context.pushNamed('scanReceipt');
              break;
            case 4:
              context.pushNamed('purchaseHistory');
              break;
          }
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.menu),
          label: 'More',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart),
          label: 'Shopping List',
        ),
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.document_scanner),
          label: 'Scan Receipt',
        ),
        NavigationDestination(
          icon: Icon(Icons.history),
          label: 'Archive',
        ),
      ],
    );
  }
}
