import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

/// A global provider that holds the current logged in user.
/// After a successful login or signup call:
/// ref.read(currentUserProvider.notifier).state = theAppUser; to update the global user state
final currentUserProvider = StateProvider<AppUser?>((ref) {
  return null;
});
