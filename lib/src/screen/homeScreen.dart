import 'package:flutter/material.dart';
import 'package:shopping_list_g11/src/widget/my_drawer.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Keeps track of the BottomNav tab's index. Though need to tweak this.
    if (index == 0) {
      context.goNamed('list'); // To-Buy?
    } else if (index == 1) {
      context.goNamed('home');
    } else if (index == 2) {
      context.goNamed('shoppingList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      drawer: const MyDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),

            /// Drawer
            const SizedBox(height: 8),
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.tertiary),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),

            /// Expiring Soon
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'About to expire',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Item 2',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
              ),
            ),

            /// Shopping List
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Shopping List',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      /// Bottom Navigation Bar
      /// TODO: Refactor this to a separate widget
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:Theme.of(context).colorScheme.surface,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping List',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
