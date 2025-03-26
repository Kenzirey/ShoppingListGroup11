import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/routes/routes.dart';
import 'package:shopping_list_g11/widget/bottom_nav_bar.dart';
import 'package:shopping_list_g11/widget/my_drawer.dart';

/// Wrapper widget used inside the Shellroute to set how the main layout should be.
/// Shared [Scaffold] structure to keep track of correct active tab.
///
/// Handles the system back button behavior.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.toString();
    final int selectedIndex = AppRouter.getSelectedIndexForRoute(currentLocation);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentLocation != '/') {
          GoRouter.of(context).goNamed('home');
        }
      },
      child: Scaffold(
        key: AppRouter.scaffoldKey,
        drawer: const MyDrawer(),
        body: child,
        bottomNavigationBar: BottomNavBar(
          selectedIndex: selectedIndex,
          scaffoldKey: AppRouter.scaffoldKey,
        ),
      ),
    );
  }
}