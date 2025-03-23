import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shopping_list_g11/routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

// https://pub.dev/packages/flutter_gemini
const gemApi = 'AIzaSyD0lMRQQP0rx4D024lV55WX1SoaeyFrzPg';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Gemini (with Emma's key)
  Gemini.init(apiKey: gemApi);
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ympkztethjtejhdajsol.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InltcGt6dGV0aGp0ZWpoZGFqc29sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc2MjUzMTUsImV4cCI6MjA1MzIwMTMxNX0.GA21O-DEqkNCO1DbVEJ3KHh74fg5e0ZxejNnFrwhHto',
  );

  runApp(const ProviderScope(child: MyApp()));
}
final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return MaterialApp.router(
      title: 'Shopping List',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF212121),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFADEBB3), // Mint green
          secondary: Color(0xFF58855C), // darker mint green
          inversePrimary: Color(0xFF0D3311),
          tertiary: Color(0xffefefef),
          surface: Color(0xFF212121), // Night from Solwr design guide.
          primaryContainer: Color(0xff424242),
          onSurfaceVariant: Color(0xFFBDBDBD), // hint text, used by search bar inherently.
        ),
      ),
      routerConfig: AppRouter.router, // Routes similar to vue, logic is in the routes folder.
          builder: (context, child) {
        return SafeArea(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
