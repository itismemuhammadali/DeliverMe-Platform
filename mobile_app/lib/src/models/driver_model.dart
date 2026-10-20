class DriverModel {
  final int? id;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String licenseNumber;
  final String? drivingLicenseImage;
  final String? idCardImage;
  final String? drivingLicenseUrl;
  final String? idCardUrl;
  final String? drivingLicenseFilename;
  final String? idCardFilename;
  final String vehiclePlate;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleYear;
  final String? vehicleType;
  final String? vehicleMake;
  final bool isAvailable;
  final bool hasPaymentMethod;
  final String status;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? rating;
  final int? totalRides;
  final bool isActive;
  final bool notificationEnabled;
  final String? createdAt;
  final String? updatedAt;

  DriverModel({
    this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.licenseNumber,
    this.drivingLicenseImage,
    this.idCardImage,
    this.drivingLicenseUrl,
    this.idCardUrl,
    this.drivingLicenseFilename,
    this.idCardFilename,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleYear,
    this.vehicleType,
    this.vehicleMake,
    this.isAvailable = false,
    this.hasPaymentMethod = false,
    this.status = 'offline',
    this.currentLatitude,
    this.currentLongitude,
    this.rating,
    this.totalRides,
    this.isActive = true,
    this.notificationEnabled = true,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      drivingLicenseImage: json['driving_license_image'],
      idCardImage: json['id_card_image'],
      drivingLicenseUrl: json['driving_license_url'],
      idCardUrl: json['id_card_url'],
      drivingLicenseFilename: json['driving_license_filename'],
      idCardFilename: json['id_card_filename'],
      vehiclePlate: json['vehicle_plate'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      vehicleColor: json['vehicle_color'] ?? '',
      vehicleYear: json['vehicle_year']?.toString() ?? '',
      vehicleType: json['vehicle_type'],
      vehicleMake: json['vehicle_make'],
      isAvailable: json['is_available'] ?? false,
      hasPaymentMethod: json['has_payment_method'] ?? false,
      status: json['status'] ?? 'offline',
      currentLatitude: json['current_latitude']?.toDouble(),
      currentLongitude: json['current_longitude']?.toDouble(),
      rating: json['rating']?.toDouble(),
      totalRides: json['total_rides'],
      isActive: json['is_active'] ?? true,
      notificationEnabled: json['notification_enabled'] ?? true,
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
      'license_number': licenseNumber,
      'driving_license_image': drivingLicenseImage,
      'id_card_image': idCardImage,
      'driving_license_url': drivingLicenseUrl,
      'id_card_url': idCardUrl,
      'driving_license_filename': drivingLicenseFilename,
      'id_card_filename': idCardFilename,
      'vehicle_plate': vehiclePlate,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'vehicle_year': vehicleYear,
      'vehicle_type': vehicleType,
      'vehicle_make': vehicleMake,
      'is_available': isAvailable,
      'has_payment_method': hasPaymentMethod,
      'status': status,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'rating': rating,
      'total_rides': totalRides,
      'is_active': isActive,
      'notification_enabled': notificationEnabled,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  DriverModel copyWith({
    int? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? licenseNumber,
    String? drivingLicenseImage,
    String? idCardImage,
    String? drivingLicenseUrl,
    String? idCardUrl,
    String? drivingLicenseFilename,
    String? idCardFilename,
    String? vehiclePlate,
    String? vehicleModel,
    String? vehicleColor,
    String? vehicleYear,
    String? vehicleType,
    String? vehicleMake,
    bool? isAvailable,
    bool? hasPaymentMethod,
    String? status,
    double? currentLatitude,
    double? currentLongitude,
    double? rating,
    int? totalRides,
    bool? isActive,
    bool? notificationEnabled,
    String? createdAt,
    String? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      drivingLicenseImage: drivingLicenseImage ?? this.drivingLicenseImage,
      idCardImage: idCardImage ?? this.idCardImage,
      drivingLicenseUrl: drivingLicenseUrl ?? this.drivingLicenseUrl,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      drivingLicenseFilename: drivingLicenseFilename ?? this.drivingLicenseFilename,
      idCardFilename: idCardFilename ?? this.idCardFilename,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      isAvailable: isAvailable ?? this.isAvailable,
      hasPaymentMethod: hasPaymentMethod ?? this.hasPaymentMethod,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isActive: isActive ?? this.isActive,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DriverAuthResponse {
  final String accessToken;
  final DriverModel driver;

  DriverAuthResponse({
    required this.accessToken,
    required this.driver,
  });

  factory DriverAuthResponse.fromJson(Map<String, dynamic> json) {
    return DriverAuthResponse(
      accessToken: json['access_token'] ?? '',
      driver: DriverModel.fromJson(json['driver'] ?? {}),
    );
  }
}

class DriverRegistrationResponse {
  final String message;
  final DriverModel driver;
  final String accessToken;

  DriverRegistrationResponse({
    required this.message,
    required this.driver,
    required this.accessToken,
  });

  factory DriverRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return DriverRegistrationResponse(
      message: json['message'] ?? '',
      driver: DriverModel.fromJson(json['driver'] ?? {}),
      accessToken: json['access_token'] ?? '',
    );
  }
}

class DriverNotification {
  final int id;
  final int driverId;
  final int? rideId;
  final String type;
  final String title;
  final String message;
  final String status;
  final String createdAt;
  final String? userImage;
  final String? timeRange;
  final String? date;

  DriverNotification({
    required this.id,
    required this.driverId,
    this.rideId,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    required this.createdAt,
    this.userImage,
    this.timeRange,
    this.date,
  });

  factory DriverNotification.fromJson(Map<String, dynamic> json) {
    return DriverNotification(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      rideId: json['ride_id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      userImage: json['user_image'],
      timeRange: json['time_range'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'ride_id': rideId,
      'type': type,
      'title': title,
      'message': message,
      'status': status,
      'created_at': createdAt,
      'user_image': userImage,
      'time_range': timeRange,
      'date': date,
    };
  }
}

class LocationUpdate {
  final double latitude;
  final double longitude;

  LocationUpdate({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PushTokenUpdate {
  final String pushToken;
  final String? deviceId;

  PushTokenUpdate({
    required this.pushToken,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'push_token': pushToken,
      if (deviceId != null) 'device_id': deviceId,
    };
  }
}

class StatusUpdate {
  final String status;

  StatusUpdate({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class AvailabilityUpdate {
  final bool isAvailable;

  AvailabilityUpdate({
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_available': isAvailable,
    };
  }
}

class PaymentMethodUpdate {
  final bool hasPaymentMethod;

  PaymentMethodUpdate({
    required this.hasPaymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'has_payment_method': hasPaymentMethod,
    };
  }
}

class DocumentUpdate {
  final String? drivingLicenseImage;
  final String? idCardImage;

  DocumentUpdate({
    this.drivingLicenseImage,
    this.idCardImage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (drivingLicenseImage != null)
        'driving_license_image': drivingLicenseImage,
      if (idCardImage != null) 'id_card_image': idCardImage,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
    };
  }
}

class DocumentUploadRequest {
  final String docType;
  final String filename;
  final String contentType;

  DocumentUploadRequest({
    required this.docType,
    required this.filename,
    required this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'doc_type': docType,
      'filename': filename,
      'content_type': contentType,
    };
  }
}

class DocumentUploadResponse {
  final String uploadUrl;
  final String objectKey;
  final int expiresIn;

  DocumentUploadResponse({
    required this.uploadUrl,
    required this.objectKey,
    required this.expiresIn,
  });

  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResponse(
      uploadUrl: json['upload_url'] ?? '',
      objectKey: json['object_key'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
    );
  }
}

class DocumentConfirmUpload {
  final String docType;
  final String objectKey;

  DocumentConfirmUpload({
    required this.docType,
    required this.objectKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'doc_type': docType,
      'object_key': objectKey,
    };
  }
}

class DriverApiError {
  final String error;
  final String? details;

  DriverApiError({
    required this.error,
    this.details,
  });

  factory DriverApiError.fromJson(Map<String, dynamic> json) {
    return DriverApiError(
      error: json['error'] ?? json['message'] ?? 'Unknown error',
      details: json['details'],
    );
  }

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      return '$error: $details';
    }
    return error;
  }
}
