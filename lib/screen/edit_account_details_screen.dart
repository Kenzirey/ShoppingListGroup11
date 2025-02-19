import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/models/app_user.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';

class EditAccountDetailsScreen extends ConsumerStatefulWidget {
  const EditAccountDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditAccountDetailsScreen> createState() =>
      _EditAccountDetailsScreenState();
}

class _EditAccountDetailsScreenState extends ConsumerState<EditAccountDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<String> _dietaryOptions = ['Vegan', 'Vegetarian', 'Gluten-Free'];
  final List<String> _selectedDiets = [];

  OverlayEntry? _successOverlayEntry;

  @override
  void dispose() {
    _nameController.dispose();
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
              child: Container(color: Colors.black54),
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
                  const Text(
                    'Account Details Updated!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Account Details')),
        body: const Center(child: Text('No user found.')),
      );
    }

    _nameController.text = currentUser.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Account Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dietary Preferences:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _dietaryOptions.map((diet) {
                  final isSelected = _selectedDiets.contains(diet);
                  return ChoiceChip(
                    label: Text(diet),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDiets.add(diet);
                        } else {
                          _selectedDiets.remove(diet);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final newPassword = _passwordController.text.trim();
                      if (newPassword.isNotEmpty) {
                        await ref.read(authControllerProvider).changePassword(ref, newPassword);
                      }

                      final newName = _nameController.text.trim();
                      final authController = ref.read(authControllerProvider);
                      await authController.updateProfile(
                        ref: ref,
                        avatarUrl: currentUser.avatarUrl,
                        dietaryPreferences: _selectedDiets.isEmpty
                            ? currentUser.dietaryPreferences
                            : _selectedDiets,
                      );

                      if (newName.isNotEmpty && newName != currentUser.name) {
                        final updatedData = await Supabase.instance.client
                            .from('profiles')
                            .update({'name': newName})
                            .eq('auth_id', currentUser.authId)
                            .select()
                            .maybeSingle();
                        if (updatedData != null) {
                          final updatedUser = AppUser.fromMap(updatedData, currentUser.email);
                          ref.read(currentUserProvider.notifier).state = updatedUser;
                        }
                      }

                      _showSuccessOverlay(context);
                      await Future.delayed(const Duration(seconds: 2));
                      _removeSuccessOverlay();

                      if (context.mounted) {
                        context.pop();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
