class DeliveryModel {
  final int id;
  final int customerId;
  final int? driverId;
  final String pickupAddress;
  final String dropoffAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String itemName;
  final String? itemDescription;
  final String? itemPhotoUrl;
  final String? driverItemPhotoUrl; // Completion/proof photo uploaded by driver
  final String itemType;
  final double? width;
  final double? height;
  final double? length;
  final double? weight;
  final String vehicleType;
  final String? specialInstructions;
  final String deliveryType;
  final String status;
  final String? paymentStatus;
  final String? scheduleType;
  final String? scheduledDate;
  final String? timeSlot;
  final String? deliveryPreference;
  final double? estimatedDistanceKm;
  final double? estimatedCost;
  final int? estimatedDuration;
  final String? trackingNumber;
  final String? createdAt;
  final String? updatedAt;
  final String? assignedTime;
  final String? requestedTime;
  final String? acceptedTime;
  final String? pickupTime;
  final String? deliveredTime;
  final String? cancelledTime;
  final CustomerInfo? customer;
  final String? customerFirstName;
  final String? customerLastName;
  final int? cancelledBy;
  final String? cancelledByUser;

  DeliveryModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.itemName,
    this.itemDescription,
    this.itemPhotoUrl,
    this.driverItemPhotoUrl,
    required this.itemType,
    this.width,
    this.height,
    this.length,
    this.weight,
    required this.vehicleType,
    this.specialInstructions,
    required this.deliveryType,
    required this.status,
    this.paymentStatus,
    this.scheduleType,
    this.scheduledDate,
    this.timeSlot,
    this.deliveryPreference,
    this.estimatedDistanceKm,
    this.estimatedCost,
    this.estimatedDuration,
    this.trackingNumber,
    this.createdAt,
    this.updatedAt,
    this.assignedTime,
    this.requestedTime,
    this.acceptedTime,
    this.pickupTime,
    this.deliveredTime,
    this.cancelledTime,
    this.customer,
    this.customerFirstName,
    this.customerLastName,
    this.cancelledBy,
    this.cancelledByUser,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: _toInt(json['id']) ?? 0,
      customerId: _toInt(json['customer_id']) ?? 0,
      driverId: _toInt(json['driver_id']),
      pickupAddress: json['pickup_address'] ?? '',
      dropoffAddress: json['dropoff_address'] ?? '',
      pickupLatitude: _toDouble(json['pickup_latitude']),
      pickupLongitude: _toDouble(json['pickup_longitude']),
      dropoffLatitude: _toDouble(json['dropoff_latitude']),
      dropoffLongitude: _toDouble(json['dropoff_longitude']),
      itemName: json['item_name'] ?? '',
      itemDescription: json['item_description'],
      itemPhotoUrl: json['item_photo_url'],
      driverItemPhotoUrl: json['driver_item_photo_url'],
      itemType: json['package_type'] ?? '',
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
      length: _toDouble(json['length']),
      weight: _toDouble(json['weight']),
      vehicleType: json['vehicle_type'] ?? '',
      specialInstructions: json['special_instructions'],
      deliveryType: json['delivery_type'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'],
      scheduleType: json['schedule_type'],
      scheduledDate: json['scheduled_date'],
      timeSlot: json['time_slot'],
      deliveryPreference: json['delivery_preference'],
      estimatedDistanceKm: _toDouble(json['estimated_distance_km']),
      estimatedCost: _toDouble(json['estimated_fare'] ?? json['estimated_cost']),
      estimatedDuration: _toInt(json['estimated_duration']),
      trackingNumber: json['tracking_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      assignedTime: json['assigned_time'],
      requestedTime: json['requested_time'],
      acceptedTime: json['accepted_time'],
      pickupTime: json['pickup_time'],
      deliveredTime: json['delivered_time'],
      cancelledTime: json['cancelled_time'],
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'])
          : null,
      customerFirstName: json['customer_first_name'] ?? json['customer']?['first_name'],
      customerLastName: json['customer_last_name'] ?? json['customer']?['last_name'],
      cancelledBy: _toInt(json['cancelled_by']),
      cancelledByUser: json['cancelled_by_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'item_name': itemName,
      'item_description': itemDescription,
      'item_photo_url': itemPhotoUrl,
      'driver_item_photo_url': driverItemPhotoUrl,
      'package_type': itemType,
      'width': width,
      'height': height,
      'length': length,
      'weight': weight,
      'vehicle_type': vehicleType,
      'special_instructions': specialInstructions,
      'delivery_type': deliveryType,
      'status': status,
      'payment_status': paymentStatus,
      'schedule_type': scheduleType,
      'scheduled_date': scheduledDate,
      'time_slot': timeSlot,
      'delivery_preference': deliveryPreference,
      'estimated_distance_km': estimatedDistanceKm,
      'estimated_cost': estimatedCost,
      'estimated_duration': estimatedDuration,
      'tracking_number': trackingNumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'assigned_time': assignedTime,
      'requested_time': requestedTime,
      'accepted_time': acceptedTime,
      'pickup_time': pickupTime,
      'delivered_time': deliveredTime,
      'cancelled_time': cancelledTime,
      'customer': customer?.toJson(),
      'customer_first_name': customerFirstName,
      'customer_last_name': customerLastName,
      'cancelled_by': cancelledBy,
      'cancelled_by_user': cancelledByUser,
    };
  }
}

class CustomerInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  CustomerInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
    };
  }

  String get fullName => '$firstName $lastName';
}

class AssignedDeliveriesResponse {
  final List<DeliveryModel> deliveries;
  final int total;
  final int limit;
  final int offset;
  final DateRange dateRange;
  final List<String> statusFilter;
  final List<String> vehicleTypeFilter;
  final DriverInfo driverInfo;

  AssignedDeliveriesResponse({
    required this.deliveries,
    required this.total,
    required this.limit,
    required this.offset,
    required this.dateRange,
    required this.statusFilter,
    required this.vehicleTypeFilter,
    required this.driverInfo,
  });

  factory AssignedDeliveriesResponse.fromJson(Map<String, dynamic> json) {
    List<String> _parseStringList(dynamic value) {
      if (value == null) return <String>[];
      if (value is List) return value.map((e) => e.toString()).toList();
      // Backwards-compat: backend may return a single string
      if (value is String && value.isNotEmpty) return <String>[value];
      return <String>[];
    }

    return AssignedDeliveriesResponse(
      deliveries: (json['deliveries'] as List<dynamic>?)
              ?.map((delivery) => DeliveryModel.fromJson(delivery))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 50,
      offset: json['offset'] ?? 0,
      dateRange: DateRange.fromJson(json['date_range'] ?? {}),
      statusFilter: _parseStringList(json['status_filter']),
      vehicleTypeFilter: _parseStringList(json['vehicle_type_filter']),
      driverInfo: DriverInfo.fromJson(json['driver_info'] ?? {}),
    );
  }
}

// Helper functions for type conversion
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

class DateRange {
  final String from;
  final String to;

  DateRange({
    required this.from,
    required this.to,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class DriverInfo {
  final int id;
  final String name;
  final String vehicleType;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;

  DriverInfo({
    required this.id,
    required this.name,
    required this.vehicleType,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      vehicleMake: json['vehicle_make'],
      vehicleModel: json['vehicle_model'],
      vehicleYear: json['vehicle_year'],
    );
  }
}
