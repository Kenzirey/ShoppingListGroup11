// lib/utils/validators.dart

const int minPasswordLength = 8;
final RegExp uppercaseRegExp = RegExp(r'[A-Z]');
final RegExp lowercaseRegExp = RegExp(r'[a-z]');
final RegExp digitRegExp = RegExp(r'\d');
final RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

/// Validates the given [value] as a secure password.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < minPasswordLength) {
    return 'Password must be at least $minPasswordLength characters long';
  }
  if (!uppercaseRegExp.hasMatch(value)) {
    return 'Password must include at least one uppercase letter';
  }
  if (!lowercaseRegExp.hasMatch(value)) {
    return 'Password must include at least one lowercase letter';
  }
  if (!digitRegExp.hasMatch(value)) {
    return 'Password must include at least one digit';
  }
  if (!specialCharRegExp.hasMatch(value)) {
    return 'Password must include at least one special character';
  }
  return null;
}
