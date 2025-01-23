import 'package:go_router/go_router.dart';
import '../src/screen/homeScreen.dart';
import '../src/screen/shopping_list.dart';


/// Centralizes and handles all routes for the app.
/// https://pub.dev/packages/go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      /// Route for the home screen.
      GoRoute(
        path: '/', // as it is default that '/' is the landing page, using this for home.
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      /// Route for the shopping list screen (receipts)
      GoRoute(
        path: '/shopping-list',
        name: 'shoppingList',
        builder: (context, state) => const ShoppingList(),
      ),
      // TODO: Set up screen and route for the To-Buy list screen. 
    ],
  );
}