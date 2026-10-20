import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordController extends GetxController {
  static PasswordController get to => Get.find<PasswordController>();

  // State
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Change password via Firebase
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Validate inputs
      if (currentPassword.isEmpty) {
        error.value = 'Current password is required';
        return false;
      }

      if (newPassword.isEmpty) {
        error.value = 'New password is required';
        return false;
      }

      if (newPassword.length < 6) {
        error.value = 'New password must be at least 6 characters';
        return false;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        error.value = 'User not logged in';
        return false;
      }

      try {
        // Re-authenticate with current password
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          ),
        );

        // Update password
        await user.updatePassword(newPassword);

        print('✅ Password changed successfully');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          error.value = 'Current password is incorrect';
        } else if (e.code == 'weak-password') {
          error.value = 'New password is too weak';
        } else {
          error.value = e.message ?? 'Failed to change password';
        }
        print('❌ Firebase Auth Error: ${error.value}');
        return false;
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('❌ Error changing password: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
