import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.showTrailingIcon = true,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.05),
            backgroundColor?.withOpacity(0.1) ?? Theme.of(context).colorScheme.primary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                Theme.of(context).colorScheme.primary.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: showTrailingIcon
            ? Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor ?? Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const ProfileActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

class AccountPageScreen extends ConsumerStatefulWidget {
  const AccountPageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountPageScreen> createState() => _AccountPageScreenState();
}

class _AccountPageScreenState extends ConsumerState<AccountPageScreen> with SingleTickerProviderStateMixin {
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
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(
          child: Text('You are not logged in.'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed('home');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings page coming soon')),
              );
            },
          ),
        ],
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  buildProfileHeader(context, currentUser),
                  
                  const SizedBox(height: 24),
                  
                  buildStatsSection(context),
                  
                  const SizedBox(height: 24),
                  
                  if (currentUser.dietaryPreferences.isNotEmpty)
                    buildDietaryPreferencesSection(context, currentUser),
                  
                  const SizedBox(height: 30),
                  
                  buildActionButtons(context),
                  
                  const SizedBox(height: 30),
                  
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  
                  ProfileMenuItem(
                    title: 'Information',
                    icon: Icons.info_outline,
                    textColor: Colors.white,
                    iconColor: Colors.lightBlueAccent,
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.1),
                    onTap: () {
                      context.goNamed('informationPage');
                    },
                  ),
                  

                  ProfileMenuItem(
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    textColor: Colors.white,
                    iconColor: Colors.greenAccent,
                    backgroundColor: Colors.greenAccent.withOpacity(0.1),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help page coming soon')),
                      );
                    },
                  ),
                  
                  ProfileMenuItem(
                    title: 'Logout',
                    icon: Icons.exit_to_app,
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    showTrailingIcon: false,
                    onTap: () {
                      showLogoutConfirmationDialog(context, ref);
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileHeader(BuildContext context, dynamic currentUser) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            
            // Avatar container
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 60,
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
            ),
            
            // Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  context.pushNamed('updateAvatarScreen');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // User info
        Column(
          children: [
            Text(
              currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
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
      ],
    );
  }

  Widget buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStatItem(context, '15', 'Lists'),
          _buildVerticalDivider(),
          buildStatItem(context, '28', 'Recipes'),
          _buildVerticalDivider(),
          buildStatItem(context, '84', 'Items'),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget buildDietaryPreferencesSection(BuildContext context, dynamic currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preferences',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: currentUser.dietaryPreferences.map<Widget>((pref) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Text(
                pref,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ProfileActionButton(
          label: 'Account Details',
          icon: Icons.person,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            context.pushNamed('editAccountDetails');
          },
        ),
      ],
    );
  }

  void showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext dialogContext, Animation animation, Animation secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.transparent,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Confirm Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Lottie.asset(
                    'assets/animations/logout_confirmation.json',
                    repeat: true,
                  ),
                ),
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will miss you!',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(true);
                  try {
                    await ref.read(authControllerProvider).logout(ref);
                    if (context.mounted) {
                      context.goNamed('loginPage');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    },
  );
}

}