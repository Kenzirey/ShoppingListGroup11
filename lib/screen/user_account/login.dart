import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/widget/styles/custom_text_field.dart';
import 'package:shopping_list_g11/widget/styles/gradient_button.dart';
import 'package:shopping_list_g11/widget/styles/social_button.dart';
import 'package:shopping_list_g11/widget/styles/status_overlay_feedback.dart';

/// Login entry point for the application.
/// Allows user to register & login via email or Google
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

/// Manages the state of the login screen.
class _LoginState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        //Shopping Buddy
                        //StillGood
                        //Listly
                        //Pantry Pal
                        "Savr", // noot noot
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New here?",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  theme.colorScheme.tertiary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            style: TextButton.styleFrom(
                              // TextButton inherently adds padding, and it was too much so I wanted to control it.
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => context.push('/sign-up'),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      CustomTextField(
                        controller: _emailController,
                        label: "Email",
                        hintText: "your.email@example.com",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        hintText: "••••••••",
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.colorScheme.tertiary.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: theme.colorScheme.tertiary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                          context: context,
                          onPressed: () async {
                            if (_isLoading) return;

                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Please fill in all fields'),
                                  backgroundColor: Colors.red[700],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final authController =
                                  ref.read(authControllerProvider);
                              await authController.login(email, password);

                              if (!context.mounted) return;
                              await StatusOverlayFeedback.showSuccessOverlay(
                                context,
                                title: 'Great!',
                                message: 'You have successfully logged in',
                              );

                              if (!context.mounted) return;
                              context.go('/');
                            } catch (e) {
                              if (!context.mounted) return;
                              StatusOverlayFeedback.showErrorOverlay(
                                context,
                                title: 'Login Failed',
                                message: 'Wrong username or password',
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color:
                                  theme.colorScheme.tertiary.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color:
                                    theme.colorScheme.tertiary.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color:
                                  theme.colorScheme.tertiary.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SocialButton(
                          onPressed: () async {
                            if (_isLoading) return;

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final authController =
                                  ref.read(authControllerProvider);
                              await authController.signInWithGoogle();
                              if (!context.mounted) return;
                              await StatusOverlayFeedback.showSuccessOverlay(
                                context,
                                title: 'Great!',
                                message: 'You have successfully logged in',
                              );
                              if (!context.mounted) return;
                              context.go('/');
                            } catch (e) {
                              if (!context.mounted) return;
                              StatusOverlayFeedback.showErrorOverlay(
                                context,
                                title: 'Login Failed',
                                message:
                                    'Google login failed. Please try again.',
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          icon: Icons.g_translate,
                          text: "Continue with Google",
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
