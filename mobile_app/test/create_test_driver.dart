import 'package:deliver_mee/src/common/services/driver_api_service.dart';

/// Script to create a test driver with pickup truck vehicle type
///
/// Usage: Run this script to create a test driver account
/// The driver will be registered with:
/// - Email: testdriver.pickuptruck@test.com
/// - Vehicle Type: PICKUP_TRUCK
/// - All required fields filled with test data
void main() async {
  print('🚀 Creating test driver with PICKUP_TRUCK vehicle type...\n');

  try {
    // Generate unique email with timestamp to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'testdriver.pickuptruck.$timestamp@test.com';

    print('📧 Email: $testEmail');
    print('🚗 Vehicle Type: PICKUP_TRUCK');
    print('📱 Phone: +1234567890');
    print('👤 Name: Test Driver (Pickup Truck)');
    print('🆔 License: TEST-LICENSE-${timestamp.toString().substring(0, 8)}');
    print('🚗 Vehicle: 2020 Ford F-150');
    print('🔢 Plate: TEST-PT-$timestamp\n');

    final response = await DriverApiService.register(
      phoneNumber: '+1234567890',
      firstName: 'Test',
      lastName: 'Driver',
      driverLicenseNumber:
          'TEST-LICENSE-${timestamp.toString().substring(0, 8)}',
      vehicleType: 'PICKUP_TRUCK', // Valid vehicle type
      vehicleMake: 'Ford',
      vehicleModel: 'F-150',
      vehicleYear: 2020,
      vehiclePlateNumber: 'TEST-PT-$timestamp',
      isAvailable: true,
    );

    print('\n✅ Test driver created successfully!');
    print('📋 Driver Details:');
    print('   ID: ${response.driver.id}');
    print('   Email: ${response.driver.email}');
    print('   Name: ${response.driver.firstName} ${response.driver.lastName}');
    print('   Vehicle Type: ${response.driver.vehicleType}');
    print(
        '   Vehicle: ${response.driver.vehicleYear} ${response.driver.vehicleMake} ${response.driver.vehicleModel}');
    print('   License: ${response.driver.licenseNumber}');
    print('   Available: ${response.driver.isAvailable}');
    print('\n🔑 Access Token: ${response.accessToken.substring(0, 20)}...');
    print('\n💡 You can now use these credentials to login:');
    print('   Email: $testEmail');
    print('   Password: TestDriver123!');
  } catch (e) {
    print('\n❌ Error creating test driver: $e');
    if (e.toString().contains('already exists') ||
        e.toString().contains('duplicate')) {
      print(
          '\n💡 Tip: The email might already exist. Try running again to get a new unique email.');
    }
  }
}




