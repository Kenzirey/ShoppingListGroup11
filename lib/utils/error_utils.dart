/// Transforms a raw error into a user friendly message.
String getUserFriendlyErrorMessage(Object error) {
  if (error is Exception) {
    final errorStr = error.toString().toLowerCase();

    // Password reset errors for Google accounts.
    if (errorStr.contains('google')) {
      return 'Password reset is not available for Google accounts. Please sign in with Google.';
    } 
    // No user is logged in during password change.
    else if (errorStr.contains('no user logged in')) {
      return 'No user is currently logged in. Please log in and try again.';
    } 
    // Sign up specific errors.
    else if (errorStr.contains('failed to create profile')) {
      return 'We could not create your profile. Please try again later.';
    } 
    // Password update errors.
    else if (errorStr.contains('failed to update password')) {
      return 'We couldnt update your password. Please try again later.';
    } 
    // If the email is already registered.
    else if (errorStr.contains('already exists')) {
      return 'An account with this email already exists.';
    } 
    // Handle network-related errors.
    else if (errorStr.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } 
    // Handle invalid email errors.
    else if (errorStr.contains('invalid email')) {
      return 'The email address is invalid. Please check and try again.';
    }
    // Profile update errors.
    else if (errorStr.contains('profile update failed')) {
      return 'Failed to update your profile. Please try again later.';
    }
    // Login errors – general failure.
    else if (errorStr.contains('login failed')) {
      return 'Login failed. Please check your email and password and try again.';
    }
  }
  // Default fallback message.
  return 'Something went wrong. Please try again later.';
}

