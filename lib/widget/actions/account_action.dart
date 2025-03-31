import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/widget/actions/profile_action_button.dart';

/// Extracted widget for the account action buttons.
class AccountActions extends StatelessWidget {
  const AccountActions({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileActionButton(
      label: 'Account Details',
      icon: Icons.person,
      color: Theme.of(context).colorScheme.primary,
      onPressed: () => context.pushNamed('editAccountDetails'),
    );
  }
}