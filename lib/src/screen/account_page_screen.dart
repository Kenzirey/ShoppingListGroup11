import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

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

    final dietaryPrefs = currentUser.dietaryPreferences;

    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () async {
                        try {
                          await ref.read(authControllerProvider).logout(ref);

                          if (context.mounted) {
                            context.goNamed('loginPage');
                          }
                        } catch (e) {
                          print('Logout error: $e');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Card(
                  color: Colors.black.withOpacity(0.8),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: (currentUser.avatarUrl?.isNotEmpty == true)
                              ? NetworkImage(currentUser.avatarUrl!)
                              : null,
                          child: (currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty)
                              ? const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          currentUser.email,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[300],
                              ),
                        ),

                        const Divider(
                          height: 32,
                          thickness: 1,
                          color: Colors.grey,
                        ),

                        Text(
                          'Dietary Preferences',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (dietaryPrefs.isEmpty)
                          Text(
                            'No dietary preferences specified',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[300],
                                ),
                          )
                        else
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: dietaryPrefs
                                .map((pref) => Chip(
                                      label: Text(pref),
                                      backgroundColor: Colors.grey[700],
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
