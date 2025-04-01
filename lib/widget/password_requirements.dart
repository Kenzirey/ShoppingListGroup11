import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/validators.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  const PasswordRequirements({Key? key, required this.password}) : super(key: key);

  bool get hasMinLength => password.length >= minPasswordLength;
  bool get hasUppercase => uppercaseRegExp.hasMatch(password);
  bool get hasLowercase => lowercaseRegExp.hasMatch(password);
  bool get hasDigit => digitRegExp.hasMatch(password);
  bool get hasSpecialChar => specialCharRegExp.hasMatch(password);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequirementRow(
          requirement: 'At least $minPasswordLength characters',
          fulfilled: hasMinLength,
        ),
        RequirementRow(
          requirement: 'At least one uppercase letter',
          fulfilled: hasUppercase,
        ),
        RequirementRow(
          requirement: 'At least one lowercase letter',
          fulfilled: hasLowercase,
        ),
        RequirementRow(
          requirement: 'At least one digit',
          fulfilled: hasDigit,
        ),
        RequirementRow(
          requirement: 'At least one special character',
          fulfilled: hasSpecialChar,
        ),
      ],
    );
  }
}

class RequirementRow extends StatelessWidget {
  final String requirement;
  final bool fulfilled;
  const RequirementRow({Key? key, required this.requirement, required this.fulfilled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check_circle : Icons.cancel,
          color: fulfilled ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          requirement,
          style: TextStyle(
            color: fulfilled ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
