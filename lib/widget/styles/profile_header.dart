import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/models/app_user.dart';

// Profile header for the user account page, displaying the user's avatar, name, and email.
class ProfileHeader extends StatelessWidget {
  final AppUser currentUser;

  const ProfileHeader({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Avatar container
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
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
                      ? const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.pushNamed('updateAvatarScreen'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          color: theme.colorScheme.primary.withOpacity(0.4),
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
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               currentUser.canUsePassword
                ? const Icon(
                    Icons.email,
                    size: 18,
                    color: Colors.white70,
                  )
                : Image.asset(
                    'assets/images/google_logo.png',
                    width: 18,
                    height: 18,
                  ),

                const SizedBox(width: 6),
                Text(
                  currentUser.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
}
