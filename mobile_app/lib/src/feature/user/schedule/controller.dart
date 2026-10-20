import 'package:get/get.dart';
import 'package:deliver_mee/src/common/services/delivery_service.dart';
import 'package:deliver_mee/src/models/delivery_model.dart';

class CustomerScheduleController extends GetxController {
  final RxList<DeliveryModel> deliveries = <DeliveryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentOffset = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMoreData = true.obs;

  final int limit = 20;
  String? statusFilter;

  DeliveryService get _deliveryService => Get.find<DeliveryService>();

  @override
  void onInit() {
    super.onInit();
    loadDeliveries(refresh: true);
  }

  Future<void> loadDeliveries({bool refresh = false, String? status}) async {
    try {
      if (refresh) {
        currentOffset.value = 0;
        hasMoreData.value = true;
        deliveries.clear();
      }

      if (!hasMoreData.value && !refresh) return;

      isLoading.value = true;
      errorMessage.value = '';
      statusFilter = status ?? statusFilter;

      print('🔍 Loading deliveries for authenticated customer');
      print('🔍 Status filter: $statusFilter');

      final result = await _deliveryService.getUserDeliveries(
        limit: limit,
        offset: currentOffset.value,
        // Don't filter by status - show ALL deliveries
        // status: statusFilter,
      );

      print('📡 Deliveries result: $result');

      if (result['success'] != true) {
        errorMessage.value =
            (result['error'] ?? 'Failed to load deliveries').toString();
        print('❌ Failed to load deliveries: ${errorMessage.value}');
        return;
      }

      final data = result['data'];
      List<dynamic> deliveriesJson = <dynamic>[];
      int total = 0;

      // Backend returns a list directly (not wrapped in 'deliveries' key)
      if (data is List) {
        deliveriesJson = data;
        total = deliveriesJson.length;
        print('✅ Backend returned ${deliveriesJson.length} deliveries for this customer');
      } else if (data is Map<String, dynamic>) {
        // Fallback: if backend returns wrapped response
        final rawDeliveries = data['deliveries'];
        if (rawDeliveries is List) {
          deliveriesJson = rawDeliveries;
          total = (data['total'] is num)
              ? (data['total'] as num).toInt()
              : deliveriesJson.length;
        }
      }

      final newDeliveries = deliveriesJson
          .map((d) => DeliveryModel.fromJson(d as Map<String, dynamic>))
          .toList();

      print('📦 Parsed ${newDeliveries.length} delivery models');
      deliveries.addAll(newDeliveries);
      totalCount.value = total;
      currentOffset.value += newDeliveries.length;
      hasMoreData.value = deliveries.length < totalCount.value;
      
      print('✅ Deliveries loaded successfully - Total: ${deliveries.length}');
    } catch (e) {
      errorMessage.value = 'Error loading deliveries: $e';
      print('❌ Error in loadDeliveries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDeliveries({String? status}) async {
    await loadDeliveries(refresh: true, status: status);
  }
}



