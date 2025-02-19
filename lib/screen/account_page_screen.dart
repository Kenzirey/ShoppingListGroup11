import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:lottie/lottie.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.showTrailingIcon = true,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
      ),
      trailing: showTrailingIcon
          ? CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey.withOpacity(0.1),
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            )
          : null,
    );
  }
}

class AccountPageScreen extends ConsumerWidget {
  const AccountPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEBFF00),
              Color(0xFF424242),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: (currentUser.avatarUrl != null &&
                              currentUser.avatarUrl!.isNotEmpty)
                          ? (currentUser.avatarUrl!.startsWith('assets/')
                              ? AssetImage(currentUser.avatarUrl!) as ImageProvider
                              : NetworkImage(currentUser.avatarUrl!))
                          : null,
                      child: (currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty)
                          ? const Icon(Icons.account_circle, size: 80, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed('updateProfile');
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed('updateProfile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                ProfileMenuItem(
                  title: 'Information',
                  icon: Icons.info,
                  textColor: const Color.fromARGB(255, 250, 250, 250),
                  onTap: () {
                    context.goNamed('informationPage');
                  },
                ),
                ProfileMenuItem(
                  title: 'Logout',
                  icon: Icons.exit_to_app,
                  textColor: Colors.red,
                  showTrailingIcon: false,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          title: const Text(
                            'Confirm Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 100,
                                child: Lottie.asset(
                                  'assets/animations/logout_confirmation.json',
                                  repeat: false,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                          backgroundColor: Colors.black87,
                        );
                      },
                    );

                    if (confirmed == true) {
                      try {
                        await ref.read(authControllerProvider).logout(ref);
                        if (context.mounted) {
                          context.goNamed('loginPage');
                        }
                      } catch (e) {
                        print('Logout error: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ),

    );
  }
}
