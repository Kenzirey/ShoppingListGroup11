// lib/utils/error_messages.dart

/// Transforms a raw exception into a user‑friendly message.
String getUserFriendlyErrorMessage(Object error) {
  final msg = error.toString().toLowerCase();

  if (msg.contains('no such user')) {
    return 'We couldn’t find an account with that email.';
  }
  if (msg.contains('google')) {
    return 'This feature isn’t available for Google‑only accounts.';
  }
  if (msg.contains('no user logged in')) {
    return 'You need to be signed in to do that.';
  }
  if (msg.contains('failed to create profile')) {
    return 'Couldn’t create your profile right now. Please try again later.';
  }
  if (msg.contains('already exists')) {
    return 'An account with this email already exists.';
  }
  if (msg.contains('network')) {
    return 'Network error. Please check your connection and try again.';
  }
  if (msg.contains('invalid email')) {
    return 'The email address looks invalid. Please check and try again.';
  }

  // Wrong current password during login/password change
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid password') ||
      msg.contains('wrong password') ||
      msg.contains('401')) {
    return 'The current password you entered is incorrect.';
  }

  // Login‑failed fallback
  if (msg.contains('login failed')) {
    return 'Login failed. Please verify your credentials.';
  }
  if (msg.contains('failed to update password')) {
    return 'Couldn’t update your password. Please try again later.';
  }

  // fallback
  return 'Something went wrong. Please try again.';
}
