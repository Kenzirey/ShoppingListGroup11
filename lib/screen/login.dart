import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:lottie/lottie.dart';

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

  OverlayEntry? _successOverlayEntry;
  OverlayEntry? _errorOverlayEntry;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSuccessOverlay(BuildContext context) {
    _successOverlayEntry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GreenRingPainter(),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.width * 0.5,
                    child: Lottie.asset(
                      'assets/animations/success.json',
                      repeat: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Successful!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_successOverlayEntry!);
  }

  void _removeSuccessOverlay() {
    if (_successOverlayEntry != null) {
      _successOverlayEntry!.remove();
      _successOverlayEntry = null;
    }
  }

  void _showErrorOverlay(BuildContext context, String errorMessage) {
    _errorOverlayEntry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: RedRingPainter(),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.width * 0.5,
                    child: Lottie.asset(
                      'assets/animations/error.json',
                      repeat: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_errorOverlayEntry!);
  }

  void _removeErrorOverlay() {
    if (_errorOverlayEntry != null) {
      _errorOverlayEntry!.remove();
      _errorOverlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: 'or ',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.tertiary.withOpacity(0.7),
                      ),
                      children: [
                        TextSpan(
                          text: 'sign up here',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.go('/sign-up');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  final authController = AuthController();
                  await authController.signInWithGoogle(ref);
                  if (mounted) {}
                  _showSuccessOverlay(context);
                  await Future.delayed(const Duration(seconds: 2));
                  _removeSuccessOverlay();
                  context.go('/');
                } catch (e) {
                  _showErrorOverlay(
                      context, 'Google login failed. Please try again.');
                  await Future.delayed(const Duration(seconds: 2));
                  _removeErrorOverlay();
                }
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
            const SizedBox(height: 14),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.tertiary,
              ),
            ),
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
            const SizedBox(height: 8),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.tertiary,
              ),
            ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                try {
                  final authController = AuthController();
                  await authController.login(ref, email, password);
                  _showSuccessOverlay(context);
                  await Future.delayed(const Duration(seconds: 2));
                  _removeSuccessOverlay();
                  context.go('/');
                } catch (e) {
                  _showErrorOverlay(context, 'Wrong username or password');
                  await Future.delayed(const Duration(seconds: 2));
                  _removeErrorOverlay();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class GreenRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
