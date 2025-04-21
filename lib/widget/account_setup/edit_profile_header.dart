import 'package:flutter/material.dart';
import 'package:shopping_list_g11/models/app_user.dart';

/// Profile header for the user's edit account page, displaying the user's avatar, name, and email.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.context,
    required this.currentUser,
  });

  final BuildContext context;
  final AppUser currentUser;

  @override
  Widget build(BuildContext context) {
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
                ? const Icon(Icons.account_circle, size: 80, color: Colors.grey)
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
}
