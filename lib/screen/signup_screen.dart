import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:flutter/services.dart';

/// A visually enhanced sign up screen with animations, validation, and improved UI
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final authController = AuthController();
      await authController.signUp(ref, email, password, userName: userName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString().split(']').last}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: size.width > 600 ? 500 : double.infinity,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo or App Icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_basket_rounded,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Title
                              Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                "Join today!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Username Field
                              TextFormField(
                                controller: _userNameController,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  hintText: "Enter your username",
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Username is required';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  hintText: "Create a strong password",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                          ? Icons.visibility_outlined 
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: _validatePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _signUp(),
                              ),
                              const SizedBox(height: 32),
                              
                              // Sign Up Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  backgroundColor: theme.colorScheme.primary,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "SIGN UP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to login page
                                      context.go('/login');
                                    },
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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