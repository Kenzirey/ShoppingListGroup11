import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/src/screen/home_screen.dart';
import 'package:shopping_list_g11/src/screen/login.dart';
import 'package:shopping_list_g11/src/screen/to_buy.dart';
import 'package:shopping_list_g11/src/screen/shopping_list.dart';
import 'package:shopping_list_g11/src/widget/bottom_nav_bar.dart';
import 'package:shopping_list_g11/src/widget/my_drawer.dart';
import 'package:shopping_list_g11/src/widget/top_bar.dart';

class AppRouter {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static bool isDrawerNavigation = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final matchedLocation = state.matchedLocation;

          // Set selectedIndex to -1 if the location is not a valid tab (drawer navigation or invalid route)
          final selectedIndex = (isDrawerNavigation || !isValidTab(matchedLocation)) ? -1 : _getSelectedIndexForRoute(matchedLocation);

          //TODO: figure out a better solution for this.
          return Scaffold(
            key: _scaffoldKey,
            appBar: TopBar(
              title: 'Waste Not',
              leadingIcon: Icons.menu,
              onLeadingIconPressed: () {
                isDrawerNavigation = true;
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            body: child,
            bottomNavigationBar: BottomNavBar(
              selectedIndex: selectedIndex,
            ),
            drawer: const MyDrawer(),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/to-buy',
            name: 'toBuy',
            builder: (context, state) => const ToBuyScreen(),
          ),
          GoRoute(
            path: '/shopping-list',
            name: 'shoppingList',
            builder: (context, state) => const ShoppingList(),
          ),
          GoRoute(
            path: '/login',
            name: 'loginPage',
            builder: (context, state) => const LoginScreen(),
          ),
        ],
      ),
    ],
  );

  // Helper method to check if the location is a valid tab
  static bool isValidTab(String location) {
    return location == '/' || location == '/to-buy' || location == '/shopping-list';
  }

  // Determine index based on route
  static int _getSelectedIndexForRoute(String location) {
    switch (location) {
      case '/to-buy':
        return 0; // "To Buy" tab
      case '/':
        return 1; // "Home" tab
      case '/shopping-list':
        return 2; // "Shopping List" tab
      default:
        return 1; // Invalid route, no index selected
    }
  }
}
