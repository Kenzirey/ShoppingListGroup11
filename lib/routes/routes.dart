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
/// Handles [StatefulShellRoute] to separate bottom navigation bar and drawer-based screens.
class AppRouter {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> drawerBranchKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shoppingListBranchKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeBranchKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> scanReceiptBranchKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> purchaseHistoryBranchKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authRefreshListenable,
    redirect: (BuildContext context, GoRouterState state) async {
      final supa = Supabase.instance.client;
      Session? s = supa.auth.currentSession;

      // validate the cached session with the server
      bool loggedIn = false;
      if (s != null) {
        final res = await supa.auth.getUser();
        loggedIn = res.user != null;
        if (!loggedIn) {
          await supa.auth.signOut();
          s = null;
        }
      }
      final path = state.uri.path;

    // Routes that doesnt require login
      const publicPaths = {
        '/login',
        '/sign-up',
        '/forgot-password',
        '/reset-password',
      };
      final isPublic = publicPaths.contains(path);
      // 1) If not logged in and trying to visit a protected page - go to /login
      if (!loggedIn && !isPublic) return '/login';
      // 2) If already logged in but on an auth page go to home, and allow logged in user to visit reset-password screen via deep link
      if (loggedIn && isPublic && path != '/reset-password') return '/'; // or 3 we have a cached session object but its already expired.
      if (!loggedIn && s != null) {
        try {
          await supa.auth.refreshSession();
          loggedIn = true;
        } catch (_) {
          await supa.auth.signOut();
          return '/login';
        }
      }
      // 4) no redirect
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(nav: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: drawerBranchKey,
            routes: [
              GoRoute(
                  path: '/chat',
                  name: 'chat',
                  builder: (context, state) => const ChatScreen()),
              GoRoute(
                  path: '/recipe',
                  name: 'recipe',
                  builder: (context, state) => const MealRecipeScreen()),
              GoRoute(
                  path: '/shopping-suggestion',
                  name: 'shoppingSuggestions',
                  builder: (context, state) => const ShoppingSuggestionsScreen()),
              GoRoute(
                  path: '/meal-planner',
                  name: 'mealPlanner',
                  builder: (context, state) => const MealPlannerScreen()),
              GoRoute(
                  path: '/pantry',
                  name: 'pantry',
                  builder: (context, state) => const PantryListScreen()),
              GoRoute(
                  path: '/trending',
                  name: 'trending',
                  builder: (context, state) => const TrendingRecipeScreen()),
              GoRoute(
                  path: '/purchase-statistics',
                  name: 'purchaseStatistics',
                  builder: (context, state) => const PurchaseStatistics()),
              GoRoute(
                  path: '/account',
                  name: 'accountPage',
                  builder: (context, state) => const AccountPageScreen()),
              GoRoute(
                  path: '/savedRecipes',
                  name: 'savedRecipes',
                  builder: (context, state) => const SavedRecipesScreen()),
              GoRoute(
                  path: '/edit-account-details',
                  name: 'editAccountDetails',
                  builder: (context, state) => const EditAccountDetailsScreen()),
              GoRoute(
                  path: '/information',
                  name: 'informationPage',
                  builder: (context, state) => const InformationScreen()),
              GoRoute(
                  path: '/update_avatar_screen',
                  name: 'updateAvatarScreen',
                  builder: (context, state) => const UpdateAvatarScreen()),
              GoRoute(
                path: '/receipt-screen',
                name: 'receiptScreen',
                builder: (context, state) {
                  final data = state.extra as ReceiptData;
                  return ReceiptDisplayScreen(receiptData: data);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shoppingListBranchKey,
            routes: [
              GoRoute(
                  path: '/shopping-list',
                  name: 'shoppingList',
                  builder: (context, state) => const ShoppingListScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: homeBranchKey,
            routes: [
              GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: scanReceiptBranchKey,
            routes: [
              GoRoute(
                  path: '/scan-receipt',
                  name: 'scanReceipt',
                  builder: (context, state) => const ScanReceiptScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: purchaseHistoryBranchKey,
            routes: [
              GoRoute(
                  path: '/purchase-history',
                  name: 'purchaseHistory',
                  builder: (context, state) => const PurchaseHistoryScreen()),
            ],
          ),
        ],
      ),
      // Auth-related routes outside shell
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/login',
        name: 'loginPage',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/forgot-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['user_email'] ?? '';
          return SetNewPasswordScreen(token: token, email: email);
        },
      ),
    ],
  );
}
