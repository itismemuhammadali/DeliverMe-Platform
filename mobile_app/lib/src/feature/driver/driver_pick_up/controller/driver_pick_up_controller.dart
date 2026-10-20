import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../common/services/driver_api_service.dart';
import '../../../../common/services/customer_delivery_tracking_service.dart';
import '../../../driver/driver_home/controller/controller.dart';
import 'driver_delivery_history_controller.dart';

class DriverPickUpController extends GetxController {
  static DriverPickUpController get to => Get.find();

  RxInt ratingIndex = 3.obs;
  void updateRatingIndex(int index) {
    ratingIndex.value = index;
  }

  RxString date = ''.obs;

  TextEditingController timeController = TextEditingController();
  Future<void> pickDateTime(BuildContext context) async {
    // Pick Date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        String formattedDate =
            DateFormat('dd  MMMM, yyyy').format(selectedDate);
        date.value = formattedDate;

        String formattedTime = selectedTime.format(context);
        timeController.text = formattedTime;
      }

      date.value = '${date.value} ${timeController.text} ';
    }
  }

  File? selectedImage;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
    }
    update(['selecteImage']);
  }

  File? pickedFilePath;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      pickedFilePath = File(result.files.single.path!);
      ;
    }
    update(['pickfile']);
  }

  /// Upload delivery item photo using the driver API service
  Future<bool> uploadDeliveryItemPhoto(int deliveryId) async {
    final photo = selectedImage ?? pickedFilePath;
    if (photo == null) {
      Get.snackbar(
        'Error',
        'Please select an image first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      print('📸 Uploading delivery item photo for delivery: $deliveryId');

      final result = await DriverApiService.uploadDriverDeliveryItemPhoto(
        deliveryId: deliveryId,
        photoFile: photo,
      );

      if (result['success']) {
        print('✅ Delivery item photo uploaded successfully');
        Get.snackbar(
          'Success',
          'Item photo uploaded successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        print('❌ Failed to upload item photo: ${result['error']}');
        Get.snackbar(
          'Error',
          'Failed to upload item photo: ${result['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error uploading item photo: $e');
      Get.snackbar(
        'Error',
        'Failed to upload item photo: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // API call methods for delivery actions
  RxBool isLoading = false.obs;

  Future<bool> startArrivingDelivery(int deliveryId) async {
    try {
      isLoading.value = true;
      print('🚚 Driver is now arriving for delivery: $deliveryId');
      
      final response = await DriverApiService.startArrivingDelivery(deliveryId);
      print('✅ Arriving started: $response');
      
      Get.snackbar(
        'On the way',
        'You are now on your way to the pickup location!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('❌ Start arriving failed: $e');
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> reachedDelivery(int deliveryId) async {
    try {
      isLoading.value = true;
      print('🚚 Driver has arrived at pickup location for delivery: $deliveryId');

      final response = await DriverApiService.reachedDelivery(deliveryId);
      print('✅ Arrived successful: $response');
      
      // Refresh tracking
      try {
        if (Get.isRegistered<CustomerDeliveryTrackingService>()) {
          await CustomerDeliveryTrackingService.to.refreshStatus(deliveryId);
        }
      } catch (_) {}
      
      Get.snackbar(
        'Arrived',
        'You have arrived at the pickup location!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('❌ Reached location update failed: $e');
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> pickupDelivery(int deliveryId) async {
    try {
      isLoading.value = true;
      print('🚚 Picking up delivery: $deliveryId');

      final response = await DriverApiService.pickupDelivery(deliveryId);
      print('✅ Pickup successful: $response');
      
      // Refresh the customer tracking status
      try {
        if (Get.isRegistered<CustomerDeliveryTrackingService>()) {
          await CustomerDeliveryTrackingService.to.refreshStatus(deliveryId);
        }
      } catch (_) {}
      
      Get.snackbar(
        'Success',
        'Item marked as picked up!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('❌ Pickup process error: $e');
      Get.snackbar(
        'Error',
        'Failed to mark as picked up: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> startTransitDelivery(int deliveryId) async {
    try {
      isLoading.value = true;
      print('🚚 Starting transit for delivery: $deliveryId');

      final response = await DriverApiService.startTransitDelivery(deliveryId);
      print('✅ Transit started: $response');
      
      // Refresh the customer tracking status
      try {
        if (Get.isRegistered<CustomerDeliveryTrackingService>()) {
          await CustomerDeliveryTrackingService.to.refreshStatus(deliveryId);
        }
      } catch (_) {}
      
      Get.snackbar(
        'Success',
        'You are now on your way to deliver!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('❌ Start transit process error: $e');
      Get.snackbar(
        'Error',
        'Failed to start transit: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> completeDelivery(int deliveryId) async {
    try {
      isLoading.value = true;
      print('🚚 Completing delivery: $deliveryId');

      // Try to upload photo if selected
      if (selectedImage != null || pickedFilePath != null) {
        try {
          print('📸 Uploading delivery photo before completion...');
          await uploadDeliveryItemPhoto(deliveryId);
        } catch (photoError) {
          print('⚠️ Photo upload failed (proceeding): $photoError');
        }
      }

      final response = await DriverApiService.completeDelivery(deliveryId);
      print('✅ Delivery completed: $response');

      // Refresh the customer tracking status
      try {
        if (Get.isRegistered<CustomerDeliveryTrackingService>()) {
          await CustomerDeliveryTrackingService.to.refreshStatus(deliveryId);
        }
      } catch (_) {}

      Get.snackbar(
        'Success',
        'Delivery marked as completed!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('❌ Complete delivery process error: $e');
      Get.snackbar(
        'Error',
        'Failed to complete delivery: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelDelivery({
    required int deliveryId,
    String? cancellationReason,
    double? rating,
    String? review,
  }) async {
    try {
      isLoading.value = true;
      print('❌ Cancelling delivery: $deliveryId');

      final response = await DriverApiService.cancelDelivery(
        deliveryId: deliveryId,
        cancellationReason: cancellationReason,
        rating: rating,
        review: review,
      );

      print('✅ Delivery cancelled: $response');

      isLoading.value = false;

      // Close the reason dialog
      Navigator.of(Get.context!, rootNavigator: true).pop();
      
      // Refresh both home screen and history to show cancelled delivery
      try {
        await Future.delayed(Duration(milliseconds: 300));
        
        // Refresh home screen to show cancelled delivery back to available
        if (Get.isRegistered<DriverHomeController>()) {
          await DriverHomeController.to.loadDeliveryRequests();
          print('✅ Refreshed available deliveries - cancelled delivery now available for other drivers');
        }
        
        // Refresh history controller to show the cancelled delivery
        if (Get.isRegistered<DriverDeliveryHistoryController>()) {
          await DriverDeliveryHistoryController.to.refreshDeliveries();
          print('✅ Refreshed delivery history - cancelled delivery now shows as Cancelled');
        }
      } catch (e) {
        print('⚠️ Could not refresh controllers: $e');
      }

      // Show success message
      Future.delayed(Duration(milliseconds: 500), () {
        if (Get.context != null) {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Success'),
              content: Text('Delivery cancelled successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog only
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    } catch (e) {
      print('❌ Cancel delivery failed: $e');
      isLoading.value = false;

      // Close the reason dialog
      Navigator.of(Get.context!, rootNavigator: true).pop();

      Future.delayed(Duration(milliseconds: 300), () {
        if (Get.context != null) {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Cannot Cancel Delivery'),
              content: Text(
                e.toString(),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }
}
