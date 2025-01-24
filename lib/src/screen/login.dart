import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login entry point for the application.
/// Allows user to register & login via email, google or apple.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

/// Manages the state of the login screen.
class _LoginState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access our theme so it can be manipulated.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Added "margins" on sides, work in progress.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft, // Align text to left, more dyslexic friendly?
              child: Text(
                "Log In",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Apple setup with temporary icon
            ElevatedButton(
              onPressed: () {
                // add logic :)
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  const Text("Apple Login"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Google button, with temporary icon (will be replaced with svg)
            ElevatedButton(
              onPressed: () {
                // add google login logic :)
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_translate,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  const Text("Google Login"),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email field section
            Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Lisanordmann@hotmail.com',
                hintStyle: TextStyle(
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                  fontSize: 16,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.tertiary),
                ),
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              style: TextStyle(color: theme.colorScheme.tertiary),
            ),
            const SizedBox(height: 16),

            // Password Field section
            Text(
              "Password",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '********',
                hintStyle: TextStyle(
                  color: theme.colorScheme.tertiary.withOpacity(0.6),
                  fontSize: 16,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.tertiary),
                ),
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              style: TextStyle(color: theme.colorScheme.tertiary),
            ),
            const SizedBox(height: 16),

            // Login Button (without logic)
            ElevatedButton(
              onPressed: () {
                // logic
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.secondary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 16),

            // Sign Up - temporary placement. Discuss.
            TextButton(
              onPressed: () {
                // Navigate to sign-up screen
              },
              child: Text(
                //TODO: temporary placing, maybe have it under login directly on top? Discuss.
                "Sign Up",
                style: TextStyle(color: theme.colorScheme.tertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

