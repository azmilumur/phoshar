import 'package:phoshar/core/utils/validators.dart';

class RegisterFormValidators {
  RegisterFormValidators._();

  // Registration-specific validation that might combine multiple fields
  static Map<String, String?> validateRegistrationForm({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return {
      'name': validateName(name),
      'username': validateUsername(username),
      'email': CoreValidators.validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(confirmPassword, password),
    };
  }

  // Cross-field validation (if needed)
  static String? validateUniqueUsername(
    String? username,
    List<String> existingUsernames,
  ) {
    final basicValidation = validateUsername(username);
    if (basicValidation != null) return basicValidation;

    if (existingUsernames.contains(username)) {
      return 'Username is already taken';
    }

    return null;
  }

  // Auth-specific password validation with business rules
  static String? validatePassword(String? value) {
    // Use core validation first
    final basicValidation = CoreValidators.validateRequired(value, 'Password');
    if (basicValidation != null) return basicValidation;

    // Auth-specific business rules
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Password must contain uppercase, lowercase, and number';
    // }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    final basicValidation = CoreValidators.validateRequired(
      value,
      'Confirm Password',
    );
    if (basicValidation != null) return basicValidation;

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Registration-specific username validation
  static String? validateUsername(String? value) {
    final basicValidation = CoreValidators.validateMinLength(
      value,
      3,
      'Username',
    );
    if (basicValidation != null) return basicValidation;

    // Username business rules
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (value.startsWith('_') || value.endsWith('_')) {
      return 'Username cannot start or end with underscore';
    }

    return null;
  }

  // Registration-specific name validation
  static String? validateName(String? value) {
    final basicValidation = CoreValidators.validateMinLength(value, 2, 'Name');
    if (basicValidation != null) return basicValidation;

    // Name-specific rules
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }
}
