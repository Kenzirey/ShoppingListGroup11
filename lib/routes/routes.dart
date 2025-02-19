import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/screen/chat_screen.dart';
import 'package:shopping_list_g11/screen/home_screen.dart';
import 'package:shopping_list_g11/screen/login.dart';
import 'package:shopping_list_g11/screen/meal_planner.dart';
import 'package:shopping_list_g11/screen/meal_recipe.dart';
import 'package:shopping_list_g11/screen/saved_recipes.dart';
import 'package:shopping_list_g11/screen/shopping_list.dart';
import 'package:shopping_list_g11/screen/purchase_history.dart';
import 'package:shopping_list_g11/screen/signup_screen.dart';
import 'package:shopping_list_g11/screen/trending_meal.dart';
import 'package:shopping_list_g11/widget/bottom_nav_bar.dart';
import 'package:shopping_list_g11/widget/my_drawer.dart';
import 'package:shopping_list_g11/widget/top_bar.dart';
import '../screen/scan_receipt_screen.dart';
import 'package:shopping_list_g11/screen/account_page_screen.dart';
import 'package:shopping_list_g11/screen/update_avatar_screen.dart';
import 'package:shopping_list_g11/screen/information_screen.dart';
import 'package:shopping_list_g11/screen/edit_account_details_screen.dart';

class AppRouter {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  static bool isDrawerNavigation = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final matchedLocation = state.matchedLocation;

          // Set selectedIndex to -1 if the location is not a valid tab (drawer navigation or invalid route)
          final selectedIndex =
              (isDrawerNavigation || !isValidTab(matchedLocation))
                  ? -1
                  : _getSelectedIndexForRoute(matchedLocation);

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
            path: '/shopping-list',
            name: 'shoppingList',
            builder: (context, state) => const ShoppingListScreen(),
          ),
          GoRoute(
            path: '/purchase-history',
            name: 'purchaseHistory',
            builder: (context, state) => const PurchaseHistoryScreen(),
          ),
          GoRoute(
            path: '/login',
            name: 'loginPage',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/sign-up',
            name: 'signUp',
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: '/scan-receipt',
            name: 'scanReceipt',
            builder: (context, state) => const ScanReceiptScreen(),
          ),
          GoRoute(
            path: '/chat', // chat screen (for asking for recipes)
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/recipe', // Recipe screen (showing ONE recipe)
            name: 'recipe',
            builder: (context, state) => const MealRecipeScreen(),
          ),
          GoRoute(
            path: '/meal-planner',
            name: 'mealPlanner',
            builder: (context, state) => const MealPlannerScreen(),
          ),
          GoRoute(
            path: '/trending',
            name: 'trending',
            builder: (context, state) => const TrendingRecipeScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'accountPage',
            builder: (context, state) => const AccountPageScreen(),
          ),
          GoRoute(
            path: '/savedRecipes',
            name: 'savedRecipes',
            builder: (context, state) => const SavedRecipesScreen(),
          ),
          GoRoute(
            path: '/edit-account-details',
            name: 'editAccountDetails',
            builder: (context, state) => const EditAccountDetailsScreen(),
          ),
          GoRoute(
            path: '/information',
            name: 'informationPage',
            builder: (context, state) => const InformationScreen(),
          ),

          GoRoute(
            path: '/update_avatar_screen',
            name: 'updateAvatarScreen',
            builder: (context, state) => const UpdateAvatarScreen(),
          ),
        ],
      ),
    ],
  );

  // Helper method to check if the location is a valid tab
  static bool isValidTab(String location) {
    return location == '/' ||
        location == '/shopping-list' ||
        location == '/purchase-history';
  }

  // Determine index based on route
  static int _getSelectedIndexForRoute(String location) {
    switch (location) {
      case '/shopping-list':
        return 0; // shopping list
      case '/':
        return 1; // "Home" tab
      case '/purchase-history':
        return 2; // purchase history
      default:
        return 1; // Invalid route, no index selected
    }
  }
}
