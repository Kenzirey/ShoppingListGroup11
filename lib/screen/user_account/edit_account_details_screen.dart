import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/models/app_user.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/providers/edit_account_details_provider.dart';
import 'package:shopping_list_g11/utils/error_utils.dart';
import 'package:shopping_list_g11/utils/validators.dart';
import 'package:shopping_list_g11/widget/password_requirements.dart';
import 'package:shopping_list_g11/widget/user_feedback/status_overlay_feedback.dart';
import '../../widget/account_setup/edit_profile_header.dart';

/// Screen for editing the account details of a user.
/// Allows to change username, password, and dietary preferences.
class EditAccountDetailsScreen extends ConsumerStatefulWidget {
  const EditAccountDetailsScreen({super.key});

  @override
  ConsumerState<EditAccountDetailsScreen> createState() =>
      _EditAccountDetailsScreenState();
}

class _EditAccountDetailsScreenState extends ConsumerState<EditAccountDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  final List<String> _dietaryOptions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Dairy-Free',
    'Pescatarian',
    'Keto'
  ];
  List<String> _selectedDiets = [];
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _isLoading = false;
  String _newPassword = '';

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    if (currentUser != null) {
      _selectedDiets = List.from(currentUser.dietaryPreferences);
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
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

 void _saveChanges(AppUser currentUser, bool isGoogleUser) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // The async call, to use then, catch, whenComplete to avoid the context across async gaps.
    final future = ref.read(editAccountDetailsProvider.notifier).saveChanges(
      newName: _nameController.text.trim(),
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      selectedDiets: _selectedDiets,
      currentUser: currentUser,
    );

    future.then((_) {
      if (!mounted) return;

      StatusOverlayFeedback.showSuccessOverlay(
        context,
        title: 'Account Details Updated!',
        message: 'Your changes have been saved successfully.',
      );
      context.pop();
    })

    .catchError((error) {
      if (!mounted) return;
      StatusOverlayFeedback.showErrorOverlay(
        context,
        title: 'Error',
        message: getUserFriendlyErrorMessage(error),
      );
    })

    .whenComplete(() {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: theme.colorScheme.tertiary),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter $label';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: theme.colorScheme.tertiary.withOpacity(0.4),
                fontSize: 16,
              ),
              prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.tertiary.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.tertiary.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    String? hintText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !showPassword,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(color: theme.colorScheme.tertiary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: theme.colorScheme.tertiary.withOpacity(0.7)),
          prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.tertiary.withOpacity(0.7),
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDietaryPreferencesChips() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _dietaryOptions.map((diet) {
        final isSelected = _selectedDiets.contains(diet);
        return FilterChip(
          label: Text(diet),
          selected: isSelected,
          showCheckmark: false,
          avatar: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white,) : null,
          backgroundColor: Colors.white.withOpacity(0.05),
          selectedColor: theme.colorScheme.secondary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected ? theme.colorScheme.secondary : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          labelStyle: TextStyle(
            color: isSelected ? theme.colorScheme.primary : Colors.white,
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

  Widget _buildSaveButton(AppUser currentUser, bool isGoogleUser) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF2D2D2D),
              Color(0xFF3A3A3A),
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
                child: Form(
                  key: _formKey,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(context: context, currentUser: currentUser),
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
                                hintText: 'Enter your name',
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
                                  validator: (value) {
                                    if (_newPasswordController.text.isNotEmpty &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter your current password to change it.';
                                    }
                                    return null;
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }
                                    return validatePassword(value);
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _newPassword = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                PasswordRequirements(password: _newPassword),
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
      ),
    );
  }
}

