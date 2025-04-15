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
    final router = GoRouter.of(context);

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
              final target = router.namedLocation('shoppingList');
              if (GoRouterState.of(context).uri.toString() != target) {
                context.pushNamed('shoppingList');
              }
              break;
            case 2: // Home button
              final target = router.namedLocation('home');
              if (GoRouterState.of(context).uri.toString() != target) {
                context.pushNamed('home');
              }
              break;
            case 3:
              final target = router.namedLocation('scanReceipt');
              if (GoRouterState.of(context).uri.toString() != target) {
                context.pushNamed('scanReceipt');
              }
              break;
            case 4:
              final target = router.namedLocation('purchaseHistory');
              if (GoRouterState.of(context).uri.toString() != target) {
                context.pushNamed('purchaseHistory');
              }
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