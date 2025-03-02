import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/models/app_user.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class EditAccountDetailsScreen extends ConsumerStatefulWidget {
  const EditAccountDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditAccountDetailsScreen> createState() =>
      _EditAccountDetailsScreenState();
}

class _EditAccountDetailsScreenState
    extends ConsumerState<EditAccountDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final List<String> _dietaryOptions = [
    'Vegan', 
    'Vegetarian', 
    'Gluten-Free', 
    'Dairy-Free', 
    'Pescatarian', 
    'Keto'
  ];
  List<String> _selectedDiets = [];
  OverlayEntry? _successOverlayEntry;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _selectedDiets = List.from(currentUser.dietaryPreferences);
    }
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessOverlay(BuildContext context) {
    _successOverlayEntry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: size.width * 0.4,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your changes have been saved successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_successOverlayEntry!);
  }

  void _removeSuccessOverlay() {
    _successOverlayEntry?.remove();
    _successOverlayEntry = null;
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

    final bool isGoogleUser = currentUser.isGoogleUser;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Edit Account Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E1E1E),
              const Color(0xFF2D2D2D),
              const Color(0xFF3A3A3A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(currentUser),
                      
                      const SizedBox(height: 32),
                      
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 24),
                            
                            if (!isGoogleUser) ...[
                              Text(
                                'Security',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildPasswordField(
                                controller: _currentPasswordController,
                                label: 'Current Password',
                                prefixIcon: Icons.lock_outline,
                                showPassword: _showCurrentPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _showCurrentPassword = !_showCurrentPassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              _buildPasswordField(
                                controller: _newPasswordController,
                                label: 'New Password',
                                prefixIcon: Icons.lock,
                                showPassword: _showNewPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _showNewPassword = !_showNewPassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  '• Password must be at least 8 characters long',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.amber[300],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Password changes are not allowed for Google accounts.',
                                        style: TextStyle(color: Colors.amber[100]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            Text(
                              'Dietary Preferences',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildDietaryPreferencesChips(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      _buildSaveButton(currentUser, isGoogleUser),
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

  Widget _buildProfileHeader(dynamic currentUser) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[800],
            backgroundImage: (currentUser.avatarUrl != null &&
                    currentUser.avatarUrl!.isNotEmpty)
                ? (currentUser.avatarUrl!.startsWith('assets/')
                    ? AssetImage(currentUser.avatarUrl!) as ImageProvider
                    : NetworkImage(currentUser.avatarUrl!))
                : null,
            child: (currentUser.avatarUrl == null ||
                    currentUser.avatarUrl!.isEmpty)
                ? const Icon(Icons.account_circle,
                    size: 80, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                currentUser.isGoogleUser ? Icons.g_mobiledata : Icons.email,
                size: 18,
                color: currentUser.isGoogleUser ? Colors.red[300] : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                currentUser.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.primary),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildDietaryPreferencesChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _dietaryOptions.map((diet) {
        final isSelected = _selectedDiets.contains(diet);
        return FilterChip(
          label: Text(diet),
          selected: isSelected,
          showCheckmark: false,
          avatar: isSelected ? const Icon(Icons.check, size: 16) : null,
          backgroundColor: Colors.white.withOpacity(0.05),
          selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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
    );
  }

  Widget _buildSaveButton(dynamic currentUser, bool isGoogleUser) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _saveChanges(currentUser, isGoogleUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Future<void> _saveChanges(dynamic currentUser, bool isGoogleUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newName = _nameController.text.trim();
      final authController = ref.read(authControllerProvider);

      if (!isGoogleUser &&
          _currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        final currentPassword = _currentPasswordController.text.trim();
        final newPassword = _newPasswordController.text.trim();

        if ((currentPassword.isNotEmpty && newPassword.isEmpty) ||
            (currentPassword.isEmpty && newPassword.isNotEmpty)) {
          _showErrorSnackBar('Both password fields must be filled.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        if (newPassword.length < 8) {
          _showErrorSnackBar('Password must be at least 8 characters long.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
          try {
            final user = await authController.login(
                ref, currentUser.email, currentPassword);
            if (user != null) {
              await authController.changePassword(ref, newPassword);
            }
          } catch (e) {
            _showErrorSnackBar('Incorrect current password.');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }

      bool shouldUpdateProfile = _selectedDiets != currentUser.dietaryPreferences;

      if (shouldUpdateProfile) {
        await authController.updateProfile(
          ref: ref,
          avatarUrl: currentUser.avatarUrl,
          dietaryPreferences: _selectedDiets,
        );
      }

      if (newName.isNotEmpty && newName != currentUser.name) {
        final updatedData = await Supabase.instance.client
            .from('profiles')
            .update({'name': newName})
            .eq('auth_id', currentUser.authId)
            .select()
            .maybeSingle();
        if (updatedData != null) {
          final updatedUser =
              AppUser.fromMap(updatedData, currentUser.email);
          ref.read(currentUserProvider.notifier).state =
              updatedUser;
        }
      }

      _showSuccessOverlay(context);
      await Future.delayed(const Duration(seconds: 2));
      _removeSuccessOverlay();

      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorSnackBar('Update failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}