import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/services/api_service.dart';
import '../../../common/services/driver_api_service.dart';
import '../../../common/services/firebase_auth_service.dart';
import '../../../models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  // ── UI toggles ────────────────────────────────────────────────────────────
  var isSelected = true.obs;
  RxInt selectedIndex = 0.obs;
  void setSelectedIndex(int index) => selectedIndex.value = index;

  RxBool isVisibility = true.obs;
  void setVisibility() => isVisibility.value = !isVisibility.value;

  var password = ''.obs;
  bool get hasMinLength => password.value.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password.value);
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(password.value);

  RxBool passwordTwoVisibility = true.obs;
  void setPasswordtVisibility() =>
      passwordTwoVisibility.value = !passwordTwoVisibility.value;

  RxBool confirmpasswordTwoVisibility = true.obs;
  void setConfirmPasswordtVisibility() =>
      confirmpasswordTwoVisibility.value = !confirmpasswordTwoVisibility.value;

  RxInt otpMethod = 0.obs;
  void setOtpMethod(int index) => otpMethod.value = index;

  // ── Forgot-password UI state ──────────────────────────────────────────────
  RxInt selectedForgotIndex = 0.obs;
  void setSelectedForgotIndex(int index) => selectedForgotIndex.value = index;

  RxBool isForgotVisibility = false.obs;
  void setForgotVisibility() =>
      isForgotVisibility.value = !isForgotVisibility.value;

  RxBool newPassword = false.obs;
  void setNewPassword() => newPassword.value = !newPassword.value;

  RxBool newConfirmPassword = false.obs;
  void setNewConfirmPassword() =>
      newConfirmPassword.value = !newConfirmPassword.value;

  final RxBool isForgotLoading = false.obs;
  final RxString forgotError = ''.obs;

  // State carried across the forgot-password screens
  String forgotEmail = '';
  String forgotPhone = '';
  bool forgotIsPhone = false;
  String _phoneVerificationId = '';
  String forgotUserType = 'customer'; // 'customer' or 'driver'

  // ── Login / Register ──────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Registration state
  String regEmail = '';
  String regPhone = '';
  String regPassword = '';
  String regFirstName = '';
  String regLastName = '';
  String _regPhoneVerificationId = '';
  bool _regPhoneVerificationCompleted = false; // Track if auto-verification completed

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Determine if input is email or phone
      bool isEmail = email.contains('@');
      
      if (isEmail) {
        // Email login
        print('📧 Logging in with email: $email');
        await FirebaseAuthService.to.signInWithEmail(email, password);
        print('✅ Firebase authentication successful');
      } else {
        // Phone login - need to use phone OTP instead
        print('📱 Phone login detected - using OTP flow');
        errorMessage.value = 'Phone login requires OTP. Please use the phone OTP option.';
        return false;
      }

      // Try to fetch profile, but don't fail if it doesn't exist yet
      try {
        print('🔄 Fetching user profile...');
        await ApiService.fetchProfile();
        print('✅ Profile fetched successfully');
      } catch (e) {
        print('⚠️ Profile fetch failed: $e');
        print('⚠️ Continuing anyway - user is authenticated');
        // Don't fail login if profile fetch fails
        // User might not have a profile yet
      }

      // Mark session as customer
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_user_role', 'customer');
      print('💾 Session saved as customer');

      print('✅ Login successful - navigating to home');
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseMessage(e);
      print('❌ Firebase Auth Error: ${errorMessage.value}');
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Login Error: ${errorMessage.value}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get _isSimulator {
    if (kIsWeb) return false;
    return Platform.isIOS && Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }

  Future<bool> sendRegistrationOtp({
    required String email,
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      regEmail = email.trim();
      regPhone = phoneNumber.trim();
      regPassword = password.trim();
      regFirstName = firstName.trim();
      regLastName = lastName.trim();

      if (otpMethod.value == 0) {
        // Phone OTP via native Firebase (Free SMS)
        if (_isSimulator) {
          errorMessage.value = 'Phone OTP is not available on the iOS Simulator. Please test on a real device or use Email OTP.';
          isLoading.value = false;
          return false;
        }

        // Ensure phone number is in valid E.164 format (strip any non-digit chars except leading +)
        final sanitized = _sanitizePhoneNumber(regPhone);
        if (sanitized == null || sanitized.length < 10) {
          errorMessage.value = 'Please enter a valid phone number with country code.';
          isLoading.value = false;
          return false;
        }
        regPhone = sanitized;
        print('📱 Sending Phone OTP to: $regPhone');

        final completer = Completer<bool>();
        bool phoneVerificationCompleted = false;
        bool phoneVerificationFailed = false;
        _regPhoneVerificationCompleted = false; // Reset flag
        
        await FirebaseAuthService.to.verifyPhoneNumber(
          phoneNumber: regPhone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (phoneVerificationCompleted) {
              print('⚠️ verificationCompleted called multiple times, ignoring');
              return;
            }
            phoneVerificationCompleted = true;
            _regPhoneVerificationCompleted = true; // Set flag
            
            try {
              print('🔐 Auto-completing phone verification...');
              await FirebaseAuth.instance.signInWithCredential(credential);
              print('✅ Signed in with phone credential');
              
              final success = await _completeRegistration();
              if (!completer.isCompleted) {
                completer.complete(success);
              }
            } catch (e) {
              print('❌ verificationCompleted error: $e');
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            phoneVerificationFailed = true;
            print('❌ verificationFailed: ${e.code}');
            print('❌ Message: ${e.message}');
            print('❌ Details: ${e.toString()}');
            
            // Provide user-friendly error messages
            String userMessage = _firebaseMessage(e);
            errorMessage.value = userMessage;
            
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            print('✅ OTP code sent successfully');
            print('📱 Verification ID: $verificationId');
            print('🔄 Resend token: $resendToken');
            _regPhoneVerificationId = verificationId;
            
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('⏱️ Auto retrieval timeout');
            print('📱 Verification ID: $verificationId');
            _regPhoneVerificationId = verificationId;
            
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          timeout: const Duration(seconds: 120), // Increased timeout for iOS
        );

        final result = await completer.future;
        if (phoneVerificationFailed) {
          print('❌ Phone verification failed - check error message');
          return false;
        }
        return result;
      } else {
        // Email OTP - send verification email
        print('📧 Sending Email OTP...');
        try {
          // Create account with email and password
          await FirebaseAuthService.to.signUpWithEmail(regEmail, regPassword);
          print('✅ Email account created');
          
          // Send verification email only if user has email
          if (FirebaseAuth.instance.currentUser?.email != null &&
              FirebaseAuth.instance.currentUser!.email!.isNotEmpty) {
            await FirebaseAuthService.to.sendEmailVerification();
            print('✅ Verification email sent');
          }
          
          return true;
        } catch (e) {
          // Safe error handling - check exception type
          if (e is FirebaseAuthException) {
            errorMessage.value = _firebaseMessage(e);
          } else {
            errorMessage.value = e.toString().replaceFirst('Exception: ', '');
          }
          print('❌ Email signup error: ${errorMessage.value}');
          return false;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyRegistrationOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (otpMethod.value == 0) {
        // Phone OTP verification
        print('🔐 Verifying Phone OTP: $otp');
        print('📱 Verification ID: $_regPhoneVerificationId');

        // 1. Verify OTP via native Firebase
        await FirebaseAuthService.to.confirmPhoneCode(_regPhoneVerificationId, otp);
        print('✅ Phone OTP verified successfully');
        
        // 2. Complete registration ONLY if auto-verification didn't already do it
        if (_regPhoneVerificationCompleted) {
          print('✅ Auto-verification already completed registration, skipping...');
          return true;
        }
        
        print('🔧 Completing registration after manual phone OTP verification...');
        final success = await _completeRegistration();
        if (!success) {
          print('❌ Registration completion failed');
        }
        return success;
      } else {
        // Email verification - user already created account in sendRegistrationOtp
        print('🔐 Email account already created, completing registration...');
        final success = await _completeRegistration();
        if (!success) {
          print('❌ Registration completion failed');
        }
        return success;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseMessage(e);
      print('❌ Firebase Auth Error: ${errorMessage.value}');
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      print('❌ OTP Verification Error: ${errorMessage.value}');
      print('❌ Error Type: ${e.runtimeType}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Legacy support or direct registration
    regEmail = email;
    regPhone = phoneNumber;
    regPassword = password;
    regFirstName = firstName;
    regLastName = lastName;
    return await _completeRegistration();
  }

  Future<bool> _completeRegistration() async {
    try {
      isLoading.value = true;
      
      print('🔧 Starting registration completion...');
      print('   Email: $regEmail');
      print('   Phone: $regPhone');
      print('   Name: $regFirstName $regLastName');
      
      // If already signed in via OTP, we just need the token. 
      // If not (direct registration), we create the account.
      if (FirebaseAuth.instance.currentUser == null) {
        print('🔐 Creating Firebase Auth account...');
        await FirebaseAuthService.to.signUpWithEmail(regEmail, regPassword);
        print('✅ Firebase Auth account created');
      } else {
        print('✅ User already signed in via phone');
      }

      // 2. Force token refresh and wait a bit for auth state to settle
      print('🔄 Refreshing ID token...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.getIdToken(true);
        print('✅ ID token refreshed');
        
        // Wait a moment for the token to be properly set
        await Future.delayed(Duration(milliseconds: 500));
      }

      // 3. Send email verification (non-blocking) — only if user has an email
      if (FirebaseAuth.instance.currentUser?.email != null &&
          FirebaseAuth.instance.currentUser!.email!.isNotEmpty) {
        FirebaseAuthService.to.sendEmailVerification().catchError((_) {});
      }

      // 4. Create profile via backend API instead of Cloud Function
      print('🔧 Creating customer profile via backend API');
      int profileRetries = 0;
      const int maxRetries = 3;
      
      while (profileRetries < maxRetries) {
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          print('   Current User UID: ${currentUser?.uid}');
          print('   User Phone: ${currentUser?.phoneNumber}');
          print('   Attempt ${profileRetries + 1} of $maxRetries');
          
          // Call backend API to create customer profile
          final response = await _createCustomerProfile(
            uid: currentUser?.uid ?? '',
            firstName: regFirstName,
            lastName: regLastName,
            phoneNumber: regPhone,
            email: regEmail,
          );
          
          if (response) {
            print('✅ Customer profile created successfully via API');
            
            // Mark session as customer
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_user_role', 'customer');
            print('💾 Session saved as customer after signup');
            
            return true;
          } else {
            print('⚠️ Profile creation returned false');
            profileRetries++;
            if (profileRetries < maxRetries) {
              print('🔄 Retrying profile creation...');
              await Future.delayed(Duration(seconds: 2)); // Wait before retry
            }
          }
        } catch (e) {
          print('❌ Error creating customer profile (attempt ${profileRetries + 1}): $e');
          print('❌ Error Type: ${e.runtimeType}');
          
          profileRetries++;
          if (profileRetries < maxRetries) {
            print('🔄 Retrying profile creation after error...');
            await Future.delayed(Duration(seconds: 2)); // Wait before retry
          }
        }
      }
      
      // All retries failed
      print('❌ Failed to create customer profile after $maxRetries attempts');
      errorMessage.value = 'Failed to create profile after multiple attempts. Please contact support.';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseMessage(e);
      print('❌ Firebase Auth Exception: ${errorMessage.value}');
      return false;
    } on ApiError catch (e) {
      errorMessage.value = e.error;
      print('❌ API Error: ${errorMessage.value}');
      return false;
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
      print('❌ Registration Error: $e');
      print('❌ Error Type: ${e.runtimeType}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create customer profile via backend API
  Future<bool> _createCustomerProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      print('📤 Calling backend API to create customer profile...');
      print('   UID: $uid');
      print('   Name: $firstName $lastName');
      print('   Phone: $phoneNumber');
      print('   Email: $email');
      
      // Call the backend API to create the customer profile
      final profile = await ApiService.createProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      
      print('✅ Customer profile created successfully');
      print('   Profile ID: ${profile.id}');
      print('   Profile Email: ${profile.email}');
      return true;
    } on ApiError catch (e) {
      print('❌ API Error in _createCustomerProfile: ${e.error}');
      throw e;
    } catch (e) {
      print('❌ Error in _createCustomerProfile: $e');
      throw e;
    }
  }

  // ── Forgot password — email flow (Firebase handles it) ────────────────────

  /// Send a Firebase password-reset email. [userType] is accepted but ignored
  /// (Firebase handles both customers and drivers the same way).
  Future<bool> sendForgotOtp(String email, String userType) async {
    try {
      isForgotLoading.value = true;
      forgotError.value = '';
      forgotEmail = email.trim();
      forgotIsPhone = false;
      forgotUserType = userType; // Store user type for later password reset

      await FirebaseAuthService.to.sendPasswordResetEmail(forgotEmail);
      return true;
    } on FirebaseAuthException catch (e) {
      forgotError.value = _firebaseMessage(e);
      return false;
    } catch (e) {
      forgotError.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isForgotLoading.value = false;
    }
  }

  // ── Forgot password — phone OTP flow (Firebase SMS) ───────────────────────

  Future<bool> sendForgotOtpPhone(String phoneNumber, String userType) async {
    try {
      if (_isSimulator) {
        forgotError.value = 'Phone OTP is not available on the iOS Simulator. Please use Email OTP or test on a real device.';
        return false;
      }
      isForgotLoading.value = true;
      forgotError.value = '';
      forgotPhone = phoneNumber.trim();
      forgotIsPhone = true;
      forgotUserType = userType; // Store user type for later password reset

      final completer = Completer<bool>();

      await FirebaseAuthService.to.verifyPhoneNumber(
        phoneNumber: forgotPhone,
        verificationCompleted: (_) {
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            forgotError.value = _firebaseMessage(e);
            completer.complete(false);
          }
        },
        codeSent: (verificationId, _) {
          _phoneVerificationId = verificationId;
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (_) {},
      );

      return await completer.future;
    } catch (e) {
      forgotError.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isForgotLoading.value = false;
    }
  }

  /// Verify the SMS OTP entered by the user.
  Future<bool> verifyForgotOtp(String otp) async {
    try {
      isForgotLoading.value = true;
      forgotError.value = '';

      if (!forgotIsPhone) {
        // Email flow: Firebase already sent a reset link — nothing to verify here.
        // The user clicks the link in their inbox; no code to confirm on this side.
        return true;
      }

      // Phone flow: confirm the SMS code (this verifies the OTP)
      await FirebaseAuthService.to.confirmPhoneCode(_phoneVerificationId, otp);
      return true;
    } on FirebaseAuthException catch (e) {
      forgotError.value = _firebaseMessage(e);
      return false;
    } catch (e) {
      forgotError.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isForgotLoading.value = false;
    }
  }

  /// Set a new password after phone OTP verification.
  /// Uses backend API to securely update password via Firebase Admin SDK.
  Future<bool> resetForgotPassword(String newPwd) async {
    try {
      isForgotLoading.value = true;
      forgotError.value = '';

      print('🔧 Resetting password for $forgotUserType');

      // Call backend endpoint based on user type
      final Map<String, dynamic> response;
      if (forgotUserType == 'driver') {
        response = await DriverApiService.post('/reset-password', {
          'new_password': newPwd,
          'email': forgotEmail,
        });
      } else {
        response = await ApiService.post('/reset-password', {
          'new_password': newPwd,
          'email': forgotEmail,
        });
      }

      if (response['message'] != null) {
        // Sign out and navigate to login
        await FirebaseAuthService.to.signOut();
        forgotEmail = '';
        forgotPhone = '';
        forgotIsPhone = false;
        _phoneVerificationId = '';
        forgotUserType = 'customer'; // Reset to default
        print('✅ Password reset successfully');
        return true;
      } else {
        forgotError.value = response['error'] ?? 'Failed to reset password';
        print('❌ Password reset error: ${forgotError.value}');
        return false;
      }
    } on ApiError catch (e) {
      forgotError.value = e.error;
      print('❌ API Error: ${e.error}');
      return false;
    } catch (e) {
      // Handle both ApiError and DriverApiError generically
      if (e.toString().contains('error')) {
        forgotError.value = e.toString();
      } else {
        forgotError.value = e.toString().replaceFirst('Exception: ', '');
      }
      print('❌ Exception: ${forgotError.value}');
      return false;
    } finally {
      isForgotLoading.value = false;
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  File? image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      update(['imagepick']);
    }
  }

  File? imageTwo;
  final ImagePicker _pickerTwo = ImagePicker();

  Future<void> pickImageTwo(ImageSource source) async {
    final XFile? pickedFile = await _pickerTwo.pickImage(source: source);
    if (pickedFile != null) {
      imageTwo = File(pickedFile.path);
      update(['imagepicktwo']);
    }
  }

  // ── Car selection ─────────────────────────────────────────────────────────

  TextEditingController selectedCarCtrl = TextEditingController();
  RxString selectedCar = ''.obs;
  void saveTextOfCar(String text) {
    selectedCarCtrl.text = text;
    update(['getCarName']);
  }

  RxInt textIndex = 3.obs;
  void selectCar(String car, int index) {
    textIndex.value = index;
    selectedCar.value = car;
    update(['index']);
  }

  void clearError() => errorMessage.value = '';

  /// Restore customer session from persistent storage
  /// Called on app launch to auto-login if user was previously logged in
  Future<bool> restoreSession() async {
    try {
      print('🔄 Attempting to restore customer session...');
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No Firebase user found in session');
        return false;
      }

      print('✅ Firebase user found: ${currentUser.email ?? currentUser.phoneNumber}');

      // Try to fetch and cache the profile
      try {
        print('🔄 Fetching user profile...');
        await ApiService.fetchProfile();
        print('✅ Customer profile restored successfully');
        
        // Mark role as customer
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_role', 'customer');
        
        return true;
      } catch (e) {
        print('⚠️ Profile fetch failed: $e');
        // User is authenticated in Firebase but profile fetch failed
        // This might be a network issue - still allow app access with limited functionality
        return true;
      }
    } catch (e) {
      print('❌ Session restore failed: $e');
      return false;
    }
  }

  /// Sign out customer and clear all session data
  Future<void> signOutCustomer() async {
    try {
      print('🔐 Signing out customer...');
      await FirebaseAuthService.to.signOut();
      await ApiService.logout();
      
      // Clear session marker
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_user_role');
      
      print('✅ Customer signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Sanitize a phone number to valid E.164 format: +<countrycode><number>
  /// Returns null if the number is invalid.
  String? _sanitizePhoneNumber(String raw) {
    // Strip everything except digits and leading +
    final cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      // Already has +, strip any extra + and ensure only digits follow
      final digits = cleaned.replaceFirst('+', '').replaceAll('+', '');
      if (digits.length >= 10 && digits.length <= 15) return '+$digits';
      return null;
    }
    // No + prefix — treat as local number (should already have country code prepended)
    if (cleaned.length >= 10 && cleaned.length <= 15) return '+$cleaned';
    return null;
  }

  /// Send OTP for login via phone number
  Future<bool> sendLoginOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (_isSimulator) {
        errorMessage.value = 'Phone OTP is not available on the iOS Simulator. Please test on a real device or use Email login.';
        isLoading.value = false;
        return false;
      }

      // Sanitize phone number
      final sanitized = _sanitizePhoneNumber(phoneNumber);
      if (sanitized == null || sanitized.length < 10) {
        errorMessage.value = 'Please enter a valid phone number with country code.';
        isLoading.value = false;
        return false;
      }

      print('📱 Sending Login OTP to: $sanitized');

      final completer = Completer<bool>();
      bool phoneVerificationFailed = false;

      await FirebaseAuthService.to.verifyPhoneNumber(
        phoneNumber: sanitized,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('🔐 Auto-completing phone verification for login...');
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            print('✅ Signed in with phone credential');
            
            // Fetch profile after successful login
            try {
              await ApiService.fetchProfile();
              print('✅ Profile fetched successfully');
            } catch (e) {
              print('⚠️ Profile fetch failed: $e');
            }
            
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (e) {
            print('❌ Auto-verification error: $e');
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          phoneVerificationFailed = true;
          print('❌ Login verification failed: ${e.code}');
          String userMessage = _firebaseMessage(e);
          errorMessage.value = userMessage;
          
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP code sent successfully');
          _regPhoneVerificationId = verificationId;
          
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto retrieval timeout');
          _regPhoneVerificationId = verificationId;
          
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        timeout: const Duration(seconds: 120),
      );

      final result = await completer.future;
      if (phoneVerificationFailed) {
        return false;
      }
      return result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      print('❌ Send Login OTP Error: ${errorMessage.value}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify login OTP and sign in user
  Future<bool> verifyLoginOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔐 Verifying Login OTP: $otp');

      await FirebaseAuthService.to.confirmPhoneCode(_regPhoneVerificationId, otp);
      print('✅ Phone OTP verified successfully');

      // Fetch user profile after login
      try {
        print('🔄 Fetching user profile...');
        await ApiService.fetchProfile();
        print('✅ Profile fetched successfully');
        
        // Mark session as customer
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_role', 'customer');
        print('💾 Session saved as customer after phone login');
      } catch (e) {
        print('⚠️ Profile fetch failed: $e');
        print('⚠️ Continuing anyway - user is authenticated');
        
        // Still mark as customer even if profile fetch fails
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_role', 'customer');
        print('💾 Session marked as customer (profile fetch failed)');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseMessage(e);
      print('❌ Firebase Auth Error: ${errorMessage.value}');
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      print('❌ Login OTP Verification Error: ${errorMessage.value}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _firebaseMessage(FirebaseAuthException e) {
    // Log full error for debugging
    print('🔍 Firebase Auth Error Code: ${e.code}');
    print('🔍 Firebase Auth Message: ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please include your country code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later or use email verification.';
      case 'app-not-authorized':
        return 'Phone authentication is not properly configured. Please try again or use email.';
      case 'session-expired':
        return 'The verification session has expired. Please request a new code.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet and try again.';
      case 'operation-not-allowed':
        return 'Phone authentication is disabled. Please use email verification instead.';
      case 'missing-app-credential':
        return 'App credential missing. Please contact support.';
      case 'missing-client-identifier':
        return 'Client identifier missing. Please contact support.';
      default:
        // iOS-specific error handling
        final message = e.message ?? 'Authentication error.';
        if (message.contains('APNs')) {
          return 'APNs certificate issue. Please contact support.';
        }
        if (message.contains('reCAPTCHA')) {
          return 'reCAPTCHA verification failed. Please try again.';
        }
        if (message.contains('network')) {
          return 'Network error. Please check your connection and try again.';
        }
        if (message.contains('timeout')) {
          return 'Request timed out. Please try again.';
        }
        return message;
    }
  }
}
