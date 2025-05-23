import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/utils/error_utils.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';

/// Screen for updating the user's profile picture avatar.
class UpdateAvatarScreen extends ConsumerStatefulWidget {
  const UpdateAvatarScreen({super.key});

  @override
  ConsumerState<UpdateAvatarScreen> createState() => _UpdateAvatarScreenState();
}

class _UpdateAvatarScreenState extends ConsumerState<UpdateAvatarScreen>
    with SingleTickerProviderStateMixin {
  String? selectedAvatar;
  OverlayEntry? _successOverlayEntry;
  String? _originalGoogleAvatarUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // List of local avatar image paths.
  final List<String> avatarPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png', //todo: remove sonic, add more
  ];

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
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    _removeSuccessOverlay();
    super.dispose();
  }

  Widget _buildAvatarOption(String assetPath, int index) { // index for unique labeling of the avatars.
    final isSelected = selectedAvatar == assetPath;
    ImageProvider imageProvider;
    String semanticLabel;

    if (assetPath.startsWith('http')) { //http check so that the profile pics load properly on android devices too
      imageProvider = NetworkImage(assetPath);
      semanticLabel = "Current Google profile picture";
      if (isSelected) {
        semanticLabel += ", selected";
      }
    } else {
      imageProvider = AssetImage(assetPath);
      final avatarName = assetPath.split('/').last.split('.').first;
      semanticLabel = "Avatar option ${index + 1}: $avatarName";
      if (isSelected) {
        semanticLabel += ", selected";
      }
    }

    return Semantics(
      label: semanticLabel,
      button: true, // to let screen readers know it is a button
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAvatar = assetPath;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 3)
                : Border.all(color: Colors.transparent, width: 3),
          ),
          child: CircleAvatar(
            backgroundImage: imageProvider,
            radius: 40,
          ),
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
              child: Container(
                color: Colors.black54,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserValueProvider);
    final theme = Theme.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Avatar')),
        body: const Center(child: Text('No user found.')),
      );
    }

    // Initialize originalGoogleAvatarUrl only once and if it's a valid URL
    if (_originalGoogleAvatarUrl == null &&
        currentUser.googleAvatarUrl != null &&
        currentUser.googleAvatarUrl!.startsWith('http') && // u r l u r lick
        currentUser.googleAvatarUrl!.isNotEmpty) {
      _originalGoogleAvatarUrl = currentUser.googleAvatarUrl;
    }

    final List<String> availableAvatars = List.from(avatarPaths);
    if (_originalGoogleAvatarUrl != null &&
        !availableAvatars.contains(_originalGoogleAvatarUrl)) {
      availableAvatars.insert(0, _originalGoogleAvatarUrl!);
    }

    // Ensure selectedAvatar is initialized if current user's avatar is in the list
    if (selectedAvatar == null && currentUser.avatarUrl != null && availableAvatars.contains(currentUser.avatarUrl)) {
      selectedAvatar = currentUser.avatarUrl;
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Avatar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select a new profile picture',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: availableAvatars.length,
                        itemBuilder: (context, index) {
                          // Pass index to _buildAvatarOption for unique labeling
                          return _buildAvatarOption(availableAvatars[index], index);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Tooltip( // tooltips for screen reader
                        message: "Save selected avatar",
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedAvatar == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  CustomSnackbar.buildSnackBar(
                                    title: 'Missing Selection',
                                    message: 'Please select an avatar',
                                    innerPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                );
                              return;
                            }

                            try {
                              await ref
                                  .read(authControllerProvider)
                                  .updateProfileWithoutPassword(
                                    avatarUrl: selectedAvatar,
                                    dietaryPreferences:
                                        currentUser.dietaryPreferences,
                                  );

                              if (!context.mounted) return;
                              _showSuccessOverlay(context);

                              await Future.delayed(const Duration(seconds: 2));

                              if (!context.mounted) return;
                              _removeSuccessOverlay();
                              GoRouter.of(context).pop();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  CustomSnackbar.buildSnackBar(
                                    title: 'Error',
                                    message: getUserFriendlyErrorMessage(e),
                                    innerPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.black87, // for contrast
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
