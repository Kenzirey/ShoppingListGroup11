import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/widget/actions/account_action.dart';
import 'package:shopping_list_g11/widget/dietary_preference.dart';
import 'package:shopping_list_g11/widget/logout_confirmation_dialog.dart';
import 'package:shopping_list_g11/widget/profile_menu_item.dart';
import 'package:shopping_list_g11/widget/styles/account_stat_section.dart';
import 'package:shopping_list_g11/widget/styles/profile_header.dart';

/// The main account page screen.
class AccountPageScreen extends ConsumerStatefulWidget {
  const AccountPageScreen({super.key});

  @override
  ConsumerState<AccountPageScreen> createState() => _AccountPageScreenState();
}

class _AccountPageScreenState extends ConsumerState<AccountPageScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext dialogContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.transparent,
            child: const LogoutConfirmationDialog(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(child: Text('You are not logged in.')),
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
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  ProfileHeader(currentUser: currentUser),
                  const SizedBox(height: 24),
                  const StatsSection(),
                  const SizedBox(height: 24),
                  if (currentUser.dietaryPreferences.isNotEmpty)
                    DietaryPreferences(currentUser: currentUser),
                  const SizedBox(height: 30),
                  const AccountActions(),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  ProfileMenuItem(
                    title: 'Information',
                    icon: Icons.info_outline,
                    textColor: Colors.white,
                    iconColor: Colors.lightBlueAccent,
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.1),
                    onTap: () => context.goNamed('informationPage'),
                  ),
                  ProfileMenuItem(
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    textColor: Colors.white,
                    iconColor: Colors.greenAccent,
                    backgroundColor: Colors.greenAccent.withOpacity(0.1),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help page coming soon'),
                        ),
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
                    onTap: () => _showLogoutConfirmationDialog(context),
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
}
