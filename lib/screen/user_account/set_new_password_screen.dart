import 'package:flutter/material.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/utils/error_utils.dart';
import 'package:shopping_list_g11/utils/validators.dart';
import 'package:shopping_list_g11/widget/password_requirements.dart';

/// Screen for setting a new password after a password reset request.
class SetNewPasswordScreen extends StatefulWidget {
  final String? token;
  final String email;

  const SetNewPasswordScreen({
    super.key,
    this.token,
    required this.email,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _token;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    final tokenFromParam = widget.token;
    if (tokenFromParam != null && tokenFromParam.isNotEmpty) {
      setState(() => _token = tokenFromParam);
    } else {
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;
      if (accessToken != null) {
        setState(() => _token = accessToken);
      } else {
        debugPrint(' No token available for password reset');
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.buildSnackBar(
              title: 'Error',
              message: 'Invalid or missing token',
              innerPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );
            return;
    }

    final newPassword = _passwordController.text.trim();
    final validationError = validatePassword(newPassword);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final updateRes = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateRes.user != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar.buildSnackBar(
              title: 'Success',
              message: 'Password updated successfully!',
              innerPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );
        context.go('/login');
      } else {
        throw Exception('Failed to update password.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.buildSnackBar(
            title: 'Error',
            message: getUserFriendlyErrorMessage(e),
            innerPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _token == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  PasswordRequirements(password: _password),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Update Password'),
                  ),
                ],
              ),
      ),
    );
  }
}
