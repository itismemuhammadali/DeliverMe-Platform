import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/driver_api_service.dart';
import '../../../../models/delivery_model.dart';
import '../../driver_home/widget/image_viewer_dialog.dart';

class DriverScheduleController extends GetxController {
  final RxList<DeliveryModel> deliveries = <DeliveryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Pagination
  final RxInt currentOffset = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMoreData = true.obs;
  final int limit = 50;
  final int days = 7;

  @override
  void onInit() {
    super.onInit();
    // Auto-load deliveries when the controller is initialized
    loadDeliveries();
  }

  /// Insert/update an accepted delivery locally so it appears immediately
  /// in the Scheduled tab after the driver accepts it.
  void addAcceptedDelivery(DeliveryModel delivery) {
    // Clear any previous error so UI can show the list.
    hasError.value = false;
    errorMessage.value = '';

    deliveries.removeWhere((d) => d.id == delivery.id);
    deliveries.insert(0, delivery);

    // Keep pagination counters coherent for UI
    totalCount.value = deliveries.length;
    currentOffset.value = deliveries.length;
    hasMoreData.value = false;
  }

  Future<void> loadDeliveries({bool refresh = false}) async {
    try {
      if (refresh) {
        currentOffset.value = 0;
        hasMoreData.value = true;
        deliveries.clear();
      }

      if (!hasMoreData.value && !refresh) return;

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print(
          '🔄 Loading deliveries - Offset: ${currentOffset.value}, Limit: $limit');

      final response = await DriverApiService.getDriverAcceptedDeliveries(
        limit: limit,
        offset: currentOffset.value,
        days: days,
      );

      final newDeliveries =
          (response['deliveries'] as List<DeliveryModel>? ?? <DeliveryModel>[]);
      final total = (response['total'] as int?) ?? newDeliveries.length;

      print('📦 Received ${newDeliveries.length} accepted deliveries');
      print('📊 Total count: $total');

      if (refresh) {
        deliveries.value = newDeliveries;
      } else {
        deliveries.addAll(newDeliveries);
      }

      totalCount.value = total;
      currentOffset.value += newDeliveries.length;

      // Check if we have more data to load
      hasMoreData.value = deliveries.length < totalCount.value;

      print('✅ Loaded ${deliveries.length}/${totalCount.value} deliveries');
    } catch (e) {
      print('❌ Error loading deliveries: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDeliveries() async {
    await loadDeliveries(refresh: true);
  }

  Future<void> loadMoreDeliveries() async {
    if (!isLoading.value && hasMoreData.value) {
      await loadDeliveries();
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null) return 'N/A';

    try {
      final time = DateTime.parse(timeString);
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return 'N/A';
    }
  }

  String getVehicleTypeDisplayName(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return 'Sedan';
      case 'suv':
        return 'SUV';
      case 'truck':
        return 'Truck';
      case 'box_truck':
        return 'Box Truck';
      case 'van':
        return 'Van';
      case 'cargo_van':
        return 'Cargo Van';
      case 'pickup_truck':
        return 'Pickup Truck';
      case 'motorcycle':
        return 'Motorcycle';
      default:
        return vehicleType;
    }
  }

  String getItemTypeDisplayName(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'small':
        return 'Small Item';
      case 'medium':
        return 'Medium Item';
      case 'large':
        return 'Large Item';
      case 'extra_large':
        return 'Extra Large Item';
      default:
        return itemType;
    }
  }

  String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Assigned';
      case 'accepted':
        return 'Accepted';
      case 'picked_up':
        return 'Picked Up';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// View item photo for a delivery
  Future<void> viewItemPhoto(DeliveryModel delivery, BuildContext context) async {
    try {
      print('📸 Viewing item photo for delivery: ${delivery.id}');
      print('📸 Item photo URL from delivery: ${delivery.itemPhotoUrl}');

      // Check if delivery has a photo
      if (delivery.itemPhotoUrl == null || delivery.itemPhotoUrl!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This delivery does not have an item photo'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Construct the full photo URL
      String photoUrl = delivery.itemPhotoUrl!;
      
      // If it's a relative path (object key), construct full URL
      if (!photoUrl.startsWith('http')) {
        // Use Firebase Storage public URL format
        final bucketName = 'delivermee-12c26.firebasestorage.app';
        photoUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/${Uri.encodeComponent(photoUrl)}?alt=media';
      }

      print('📸 Full photo URL: $photoUrl');

      // Show image in dialog using the provided context
      if (context.mounted) {
        ImageViewerDialog.show(
          context,
          photoUrl,
          title: 'Item Photo - Delivery #${delivery.id}',
        );
        print('✅ Photo dialog opened successfully');
      } else {
        throw Exception('Context not available');
      }
    } catch (e) {
      print('❌ Error viewing item photo: $e');
    }
  }
}
