class UserModel {
  final int? id;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final UserModel customer;

  AuthResponse({
    required this.accessToken,
    required this.customer,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      customer: UserModel.fromJson(json['customer'] ?? {}),
    );
  }
}

class RegistrationResponse {
  final String message;
  final UserModel customer;
  final String accessToken;

  RegistrationResponse({
    required this.message,
    required this.customer,
    required this.accessToken,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      message: json['message'] ?? '',
      customer: UserModel.fromJson(json['customer'] ?? {}),
      accessToken: json['access_token'] ?? '',
    );
  }
}

class ApiError {
  final String error;
  final String? details;

  ApiError({
    required this.error,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] ?? json['message'] ?? 'Unknown error',
      details: json['details'],
    );
  }

  @override
  String toString() => error;
}
