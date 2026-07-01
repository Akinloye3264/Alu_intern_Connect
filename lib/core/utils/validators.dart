class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? aluStudentEmail(String? value) {
    final base = email(value);
    if (base != null) return base;
    if (!value!.trim().toLowerCase().endsWith('@alustudent.com')) {
      return 'Students must use an @alustudent.com email';
    }
    return null;
  }

  static String? website(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Startup website is required';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Enter a full website URL (https://...)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? notEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
}
