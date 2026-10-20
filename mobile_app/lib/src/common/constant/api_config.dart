/// API Configuration for DeliverMee
/// 
/// This file contains the base URL configuration for the backend API.
/// Update the baseUrl to point to your local or production backend.

class ApiConfig {
  // LOCAL BACKEND - Using your computer's IP address
  // Make sure backend is running: python app.py
  // static const String baseUrl = 'http://10.96.189.157:5000/api';

  // PRODUCTION BACKEND (Firebase Cloud Functions 2nd Gen)
  static const String baseUrl = 'https://api-v1-4wjmghwnrq-uc.a.run.app';
  
  // API Endpoints
  static const String customersEndpoint = '$baseUrl/customers';
  static const String driversEndpoint = '$baseUrl/drivers';
  static const String deliveriesEndpoint = '$baseUrl/deliveries';
  static const String paymentsEndpoint = '$baseUrl/payments';
  static const String mobilePaymentsEndpoint = '$baseUrl/mobile-payments';
  static const String pricingEndpoint = '$baseUrl/pricing';
  
  /// Check if using local backend
  static bool get isLocal => baseUrl.contains('10.96.') || baseUrl.contains('192.168.') || baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
  
  /// Check if using production backend
  static bool get isProduction => !isLocal;
  
  /// Get environment name
  static String get environment => isLocal ? 'Local' : 'Production';
}
