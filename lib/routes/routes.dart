import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/models/receipt_data.dart';
import 'package:shopping_list_g11/routes/app_shell.dart';
import 'package:shopping_list_g11/screen/chat_screen.dart';
import 'package:shopping_list_g11/screen/home_screen.dart';
import 'package:shopping_list_g11/screen/pantry_screen.dart';
import 'package:shopping_list_g11/screen/purchase_statistics.dart';
import 'package:shopping_list_g11/screen/receipts/view_scanned_receipt_screen.dart';
import 'package:shopping_list_g11/screen/shopping_suggestion.dart';
import 'package:shopping_list_g11/screen/user_account/login.dart';
import 'package:shopping_list_g11/screen/meal_planner.dart';
import 'package:shopping_list_g11/screen/meal_recipe.dart';
import 'package:shopping_list_g11/screen/saved_recipes.dart';
import 'package:shopping_list_g11/screen/shopping_list.dart';
import 'package:shopping_list_g11/screen/purchase_history.dart';
import 'package:shopping_list_g11/screen/user_account/signup_screen.dart';
import 'package:shopping_list_g11/screen/trending_meal.dart';
import 'package:shopping_list_g11/screen/receipts/scan_receipt_screen.dart';
import 'package:shopping_list_g11/screen/user_account/account_page_screen.dart';
import 'package:shopping_list_g11/screen/user_account/update_avatar_screen.dart';
import 'package:shopping_list_g11/screen/information_screen.dart';
import 'package:shopping_list_g11/screen/user_account/edit_account_details_screen.dart';
import 'package:shopping_list_g11/screen/user_account/reset_password_screen.dart';
import 'package:shopping_list_g11/screen/user_account/set_new_password_screen.dart';
import 'auth_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Defines the app's routing and navigation logic using the GoRouter package.
///
/// Handles [ShellRoute] to separate bottom navigation bar and drawer-based screens.
class AppRouter {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authRefreshListenable,

    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final path = state.uri.path;

    // Routes that doesnt require login
      final publicPaths = {
        '/login',
        '/sign-up',
        '/forgot-password',
        '/reset-password',
      };
       final isPublic = publicPaths.contains(path);

      // 1) If not logged in and trying to visit a protected page - go to /login
      if (!loggedIn && !isPublic) {
        return '/login';
      }

      // 2) If already logged in but on an auth page go to home
      if (loggedIn && isPublic) {
        return '/';
      }
      if (loggedIn && isPublic) {
        return '/';
      }
      // 3) no redirect
      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) => MaterialPage(
          child: AppShell(child: child),
        ),
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
            path: '/scan-receipt',
            name: 'scanReceipt',
            builder: (context, state) => const ScanReceiptScreen(),
          ),

          // Drawer pages inside ShellRoute ⏬
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
            path: '/shopping-suggestion',
            name: 'shoppingSuggestions',
            builder: (context, state) => const ShoppingSuggestionsScreen(),
          ),
          GoRoute(
            path: '/meal-planner',
            name: 'mealPlanner',
            builder: (context, state) => const MealPlannerScreen(),
          ),
            GoRoute(
            path: '/pantry',
            name: 'pantry',
            builder: (context, state) => const PantryListScreen(),
          ),
          GoRoute(
            path: '/trending',
            name: 'trending',
            builder: (context, state) => const TrendingRecipeScreen(),
          ),
          GoRoute(
            path: '/purchase-statistics',
            name: 'purchaseStatistics',
            builder: (context, state) => const PurchaseStatistics(),
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
          path: '/receipt-screen',
          name: 'receiptScreen',
          builder: (context, state) {
            // Directly cast extra; this assumes that you always push the route with a valid ReceiptData.
            final receiptData = state.extra as ReceiptData;
            return ReceiptDisplayScreen(receiptData: receiptData);
          },
        ),

        ],
      ),

      // Auth-related routes outside shell
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: 'loginPage',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/forgot-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['user_email'] ?? '';
          return SetNewPasswordScreen(token: token, email: email);
        },
      ),
    ],
  );

  /// Checks if a current route is from the drawer navigation.
  ///
  /// Returns true if [location] is one of the drawer routes.
  static bool isDrawerRoute(String location) {
    return location.startsWith('/chat') ||
        location.startsWith('/recipe') ||
        location.startsWith('/meal-planner') ||
        location.startsWith('/trending') ||
        location.startsWith('/account') ||
        location.startsWith('/savedRecipes') ||
        location.startsWith('/edit-account-details') ||
        location.startsWith('/information') ||
        location.startsWith('/purchase-statistics') ||
        location.startsWith('/update_avatar_screen');
  }

  /// Maps a [location] to its corresponding bottom navigation index.
  ///
  /// Returns 0 for any drawer routes, -1 if not recognized.
  static int getSelectedIndexForRoute(String location) {
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
        return isDrawerRoute(location) ? 0 : -1;
    }
  }
}
