import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/routes/routes.dart';

/// Bottom navigation bar for the entire app. Always visible,
/// allows user to navigate to the most used screens.
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
    // Use highlight mode to not highlight if we navigate using the drawer.
    final bool noHighlight = (selectedIndex == -1);
    // Provide a valid index even when nothing is highlighted.
    final int effectiveIndex = noHighlight ? 0 : selectedIndex;

    return BottomNavigationBar(
      currentIndex: effectiveIndex,
      // If noHighlight is true, force the selected color to match unselected.
      selectedItemColor: noHighlight
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.tertiary,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        AppRouter.isDrawerNavigation = false;
        if (index == 0) {
          // Use the passed scaffoldKey to open the drawer.
          scaffoldKey.currentState?.openDrawer();
        } else {
          switch (index) {
            case 1:
              context.goNamed('shoppingList');
              break;
            case 2:
              context.goNamed('home');
              break;
            case 3:
              context.goNamed('scanReceipt');
              break;
            case 4:
              context.goNamed('purchaseHistory');
              break;
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Drawer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Shopping List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'Scan Sten',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Purchase History',
        ),
      ],
    );
  }
}
