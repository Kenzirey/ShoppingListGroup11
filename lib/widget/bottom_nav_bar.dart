import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/routes/routes.dart';

/// Bottom navigation bar for the entire app. Always visisble,
/// allows user to navigate to their to-buy list, home and to shopping list (receipts).
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    // Use highlight mode to not highlight if we navigate using drawer.
    final bool noHighlight = (selectedIndex == -1);

    // Need to pass an actual valid index (else app breaky)
    final int effectiveIndex = noHighlight ? 0 : selectedIndex;

    return BottomNavigationBar(
      currentIndex: effectiveIndex,

      // if it's not highlighted then don't highlight it (fix to not show tab highlight)
      selectedItemColor: noHighlight
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.primary,

      unselectedItemColor: Theme.of(context).colorScheme.tertiary,
      type: BottomNavigationBarType.fixed, // so all items are displayed, don't want it to disappear :(

      onTap: (index) {
        AppRouter.isDrawerNavigation = false;
        switch (index) {
          case 0:
            context.goNamed('shoppingList');
            break;
          case 1:
            context.goNamed('home');
            break;
          case 2:
            context.goNamed('purchaseHistory');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Shopping List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Purchase History',
        ),
      ],
    );
  }
}
