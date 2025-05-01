import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/widget/my_drawer.dart';
import 'package:shopping_list_g11/widget/bottom_nav_bar.dart';
import 'package:shopping_list_g11/routes/routes.dart';

/// Wrapper widget used inside the Shellroute to set how the main layout should be.
/// Shared [Scaffold] structure to keep track of correct active tab.
///
/// Handles the system back button behavior.
class AppShell extends StatefulWidget {
  final StatefulNavigationShell nav;
  const AppShell({super.key, required this.nav});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<int> _history = [];
  late int _lastIndex;

  List<GlobalKey<NavigatorState>> get _branchKeys => [
        AppRouter.drawerBranchKey,
        AppRouter.shoppingListBranchKey,
        AppRouter.homeBranchKey,
        AppRouter.scanReceiptBranchKey,
        AppRouter.purchaseHistoryBranchKey,
      ];

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.nav.currentIndex;
    _history.add(_lastIndex);
  }

  Future<bool> _onWillPop() async {
    final idx = widget.nav.currentIndex;
    final key = _branchKeys[idx];

    if (key.currentState?.canPop() ?? false) {
      key.currentState!.pop();
      return false;
    }
    if (_history.length > 1) {
      _history.removeLast();
      widget.nav.goBranch(_history.last);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final curr = widget.nav.currentIndex;
    if (curr != _lastIndex) {
      _history.add(curr);
      _lastIndex = curr;
    }

    return WillPopScope( // well the other stuff works like doo doo
      onWillPop: _onWillPop,
      child: Scaffold(
        key: AppRouter.scaffoldKey,
        drawer: const MyDrawer(),
        drawerEnableOpenDragGesture: false,
        body: widget.nav,
        bottomNavigationBar: BottomNavBar(
          nav: widget.nav,
          scaffoldKey: AppRouter.scaffoldKey,
        ),
      ),
    );
  }
}
