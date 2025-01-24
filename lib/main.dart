import 'package:flutter/material.dart';
import 'package:shopping_list_g11/routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shopping List',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: const Color(0xFFEBFF00), // Solwr fargen
          tertiary: Colors.white,
          surface: Colors.black87,
          background: Colors.grey[900],
        ),
      ),
      routerConfig: AppRouter.router, // Routes similar to vue, logic is in the routes folder.
    );
  }
}
