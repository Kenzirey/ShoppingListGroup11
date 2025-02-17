import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:lottie/lottie.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  String? selectedAvatar;

  OverlayEntry? _successOverlayEntry;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Profile')),
        body: const Center(child: Text('No user found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          children: [
            Text(
              'Select a new profile picture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildAvatarOption('assets/avatars/avatar1.png'),
                  _buildAvatarOption('assets/avatars/avatar2.png'),
                  _buildAvatarOption('assets/avatars/avatar3.png'),
                  _buildAvatarOption('assets/avatars/avatar4.png'),
                  _buildAvatarOption('assets/avatars/avatar5.png'),
                  _buildAvatarOption('assets/avatars/avatar6.png'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedAvatar == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an avatar')),
                  );
                  return;
                }
                try {
                  final updatedUser = await ref.read(authControllerProvider).updateProfile(
                    ref: ref,
                    avatarUrl: selectedAvatar,
                    dietaryPreferences: currentUser.dietaryPreferences,
                  );

                  _showSuccessOverlay(context);

                  await Future.delayed(const Duration(seconds: 2));
                  _removeSuccessOverlay();
                  if (context.mounted) {
                    GoRouter.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile update failed: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatarOption(String assetPath) {
    final isSelected = selectedAvatar == assetPath;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAvatar = assetPath;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundImage: AssetImage(assetPath),
        ),
      ),
    );
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
                    'Avatar Updated!',
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
}
