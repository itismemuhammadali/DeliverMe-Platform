String? passwordValidator(
  String? value,
) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  return null; // Valid password
}

String? emailValidator(
  String? value,
) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // Regular expression for validating an email
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegExp.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null; // Valid email
}

String? nameValidator(
  String? value,
) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }

  return null; // Valid name
}

String? validatePhoneNumber(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    return "Phone number cannot be empty.";
  }

  // This regex matches phone numbers with optional country code (+) and 10-15 digits
  final RegExp regex = RegExp(r'^\+?[0-9]{10,15}$');
  if (!regex.hasMatch(phoneNumber)) {
    return "Invalid phone number format. Please enter a valid phone number.";
  }

  return null; // Return null if validation passes
}

String? validatorvalue(String? value, String name) {
  if (value == null || value.isEmpty) {
    return 'Please enter your ${name}';
  }

  return null; // Valid name
}

String? emailAndNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter something';
  }

  // Check if the input is numeric (assume phone)
  final isNumeric = RegExp(r'^\d+$').hasMatch(value);

  if (isNumeric) {
    if (value.length < 10 || value.length > 15) {
      return 'Enter a valid phone number';
    }
  } else {
    // Validate email format
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
  }

  return null; // valid
}
