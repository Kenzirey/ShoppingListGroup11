import 'package:flutter/material.dart';
import 'package:shopping_list_g11/src/screen/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],

        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.amber,
          tertiary: Colors.white,
          surface: Colors.black87,
          background: Colors.grey[900],
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black54,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white70,
        ),

      ),
      home: const HomeScreen(),
    );
  }
}
