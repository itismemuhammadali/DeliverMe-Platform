import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../constant/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.customersEndpoint;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create customer profile in Firestore after Firebase sign-up.
  /// Call this once right after [FirebaseAuth.createUserWithEmailAndPassword].
  static Future<UserModel> createProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    try {
      final headers = await _getHeaders();
      print('🔧 POST /register with headers: ${headers.keys}');
      print('📤 Request body: firstName=$firstName, lastName=$lastName, phoneNumber=$phoneNumber');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (zipCode != null) 'zip_code': zipCode,
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final customer = UserModel.fromJson(data['customer'] ?? {});
        print('✅ Customer profile parsed: ${customer.firstName} ${customer.lastName}');
        await _cacheCustomer(customer);
        return customer;
      }
      print('❌ Server error: ${data['error']}');
      throw ApiError.fromJson(data);
    } catch (e) {
      print('❌ Exception in createProfile: $e');
      if (e is ApiError) rethrow;
      throw ApiError(error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Fetch the authenticated customer's profile and update last_login_at.
  static Future<UserModel> fetchProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final customer = UserModel.fromJson(data);
      await _cacheCustomer(customer);
      return customer;
    }
    throw ApiError.fromJson(data);
  }

  static Future<void> _cacheCustomer(UserModel customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      try {
        await prefs.setString('user_data', jsonEncode(customer.toJson()));
      } catch (e) {
        print('⚠️ Warning: Failed to cache user_data: $e');
      }
      
      try {
        if (customer.id != null) {
          await prefs.setInt('customer_id', customer.id!);
        }
      } catch (e) {
        print('⚠️ Warning: Failed to cache customer_id: $e');
      }
      
      try {
        await prefs.setString('email', customer.email);
      } catch (e) {
        print('⚠️ Warning: Failed to cache email: $e');
      }
      
      try {
        await prefs.setString('first_name', customer.firstName);
      } catch (e) {
        print('⚠️ Warning: Failed to cache first_name: $e');
      }
      
      try {
        await prefs.setString('last_name', customer.lastName);
      } catch (e) {
        print('⚠️ Warning: Failed to cache last_name: $e');
      }
      
      try {
        await prefs.setString('phone_number', customer.phoneNumber);
      } catch (e) {
        print('⚠️ Warning: Failed to cache phone_number: $e');
      }
      
      print('✅ Customer data cached (with error handling)');
    } catch (e) {
      print('❌ Critical error in _cacheCustomer: $e');
      // Don't rethrow - caching failure should not prevent registration
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  /// Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }
      throw ApiError.fromJson(data);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(error: 'Network error: ${e.toString()}');
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
