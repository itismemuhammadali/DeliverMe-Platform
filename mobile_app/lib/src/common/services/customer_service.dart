import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/api_config.dart';

class CustomerService extends GetxService {
  static CustomerService get to => Get.find<CustomerService>();

  String get baseUrl => ApiConfig.baseUrl;

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get customer profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final url = Uri.parse('$baseUrl/customers/profile');
      final response = await http.get(url, headers: await _getHeaders());

      print('📡 Get Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      print('❌ Get profile error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Update customer profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? password,
    String? address,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/customers/profile');

      final requestBody = <String, dynamic>{};

      if (firstName != null && firstName.isNotEmpty) {
        requestBody['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        requestBody['last_name'] = lastName;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phone_number'] = phoneNumber;
      }
      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }
      if (password != null && password.isNotEmpty) {
        requestBody['password'] = password;
      }
      if (address != null && address.isNotEmpty) {
        requestBody['address'] = address;
      }
      if (city != null && city.isNotEmpty) {
        requestBody['city'] = city;
      }
      if (state != null && state.isNotEmpty) {
        requestBody['state'] = state;
      }
      if (zipCode != null && zipCode.isNotEmpty) {
        requestBody['zip_code'] = zipCode;
      }

      print('📝 Updating profile with data: ${jsonEncode(requestBody)}');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      print('📡 Update Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Update stored user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (responseData['customer'] != null) {
          final customer = responseData['customer'];
          
          // Update user_data JSON
          await prefs.setString('user_data', jsonEncode(customer));
          
          // Update individual fields
          if (customer['id'] != null) {
            await prefs.setInt('customer_id', customer['id']);
          }
          if (customer['first_name'] != null) {
            await prefs.setString('first_name', customer['first_name']);
          }
          if (customer['last_name'] != null) {
            await prefs.setString('last_name', customer['last_name']);
          }
          if (customer['phone_number'] != null) {
            await prefs.setString('phone_number', customer['phone_number']);
          }
          if (customer['email'] != null) {
            await prefs.setString('email', customer['email']);
          }
          
          print('✅ SharedPreferences updated with new profile data');
        }

        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Profile updated successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Delete customer account and data
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final url = Uri.parse('$baseUrl/customers/profile');
      print('🗑️ Deleting customer profile via: $url');
      
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      );

      print('📡 Delete Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Account and all data deleted successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to delete account from server',
        };
      }
    } catch (e) {
      print('❌ Delete account error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
