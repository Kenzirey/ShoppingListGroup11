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
import 'package:shopping_list_g11/screen/scan_receipt_screen.dart';
import 'package:shopping_list_g11/screen/account_page_screen.dart';
import 'package:shopping_list_g11/screen/update_avatar_screen.dart';
import 'package:shopping_list_g11/screen/information_screen.dart';
import 'package:shopping_list_g11/screen/edit_account_details_screen.dart';
import 'package:shopping_list_g11/widget/bottom_nav_bar.dart';
import 'package:shopping_list_g11/widget/my_drawer.dart';
import 'package:shopping_list_g11/screen/reset_password_screen.dart';
import 'package:shopping_list_g11/screen/set_new_password_screen.dart';


/// Class for definiting the routes and navigation logic for the entire app,
/// by using GoRouter package for named paths.
class AppRouter {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// This flag tells whether navigation was initiated via the drawer.
  /// So we can keep track of if navigation is via drawer or the bottom nav bar.
  static bool isDrawerNavigation = false;

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final String matchedLocation = state.matchedLocation;
          // Check if the current route is one of the main tabs.
          final bool isMainTab = isValidTab(matchedLocation);
          // If navigation comes from the drawer or the route isn't a main tab,
          // set selectedIndex to -1 so that no bottom nav item is highlighted.
          final int selectedIndex = (isDrawerNavigation || !isMainTab)
              ? -1
              : _getSelectedIndexForRoute(matchedLocation);

          return Scaffold(
            key: _scaffoldKey,
            drawer: const MyDrawer(),
            body: child,
            bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex, scaffoldKey: _scaffoldKey,),
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
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/recipe',
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
         GoRoute(
           path: '/forgot-password',
           builder: (context, state) => const ResetPasswordScreen(),
         ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['user_email'] ?? '';
          return SetNewPasswordScreen(token: token, email: email);
          },
        ),

        ],
      ),
    ],
  );

  /// Determines if the provided [location] is one of the main tab routes.
  /// So that we can highlight it if it is the current route.
  static bool isValidTab(String location) {
    return location == '/' ||
        location == '/shopping-list' ||
        location == '/purchase-history' ||
        location == '/scan-receipt';
  }

  /// Maps a route to its BottomNavBar index.
  ///
  /// 0 is the drawer trigger, not an actual route. So not using that.
  /// Keeps the same index as the icons / routes are placed.
  static int _getSelectedIndexForRoute(String location) {
    switch (location) {
      case '/shopping-list':
        return 1;
      case '/':
        return 2;
      case '/scan-receipt':
        return 3;
      case '/purchase-history':
        return 4;
      default:
        return 2; // defaults to the home screen
    }
  }
}
