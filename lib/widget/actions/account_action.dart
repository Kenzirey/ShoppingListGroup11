import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/widget/profile_menu_item.dart';

/// Extracted widget for the account action buttons.
class AccountActions extends StatelessWidget {
  const AccountActions({super.key});

   @override
  Widget build(BuildContext context) {
    return ProfileMenuItem(
      title: 'Account Details',
      icon: Icons.person_outline,
      textColor: Colors.white,
      iconColor: Colors.greenAccent,
      backgroundColor: Colors.greenAccent.withOpacity(0.1),
      onTap: () => context.pushNamed('editAccountDetails'),
    );
  }
}