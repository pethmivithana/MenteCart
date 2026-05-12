/// Input validation helpers
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value!)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
}
