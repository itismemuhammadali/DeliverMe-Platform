import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/services/customer_delivery_tracking_service.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/payment/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDeliveryTrackingPage extends StatefulWidget {
  final int deliveryId;
  final Map<String, dynamic>? initialData;
  final bool viewOnly;

  const CustomerDeliveryTrackingPage({
    super.key,
    required this.deliveryId,
    this.initialData,
    this.viewOnly = false,
  });

  @override
  State<CustomerDeliveryTrackingPage> createState() =>
      _CustomerDeliveryTrackingPageState();
}

class _CustomerDeliveryTrackingPageState
    extends State<CustomerDeliveryTrackingPage> {
  late CustomerDeliveryTrackingService trackingService;

  @override
  void initState() {
    super.initState();
    trackingService = Get.find<CustomerDeliveryTrackingService>();
    _initializeTracking();
    _listenForDeliveryCompletion();
  }

  void _listenForDeliveryCompletion() {
    // Listen to status changes
    ever(trackingService.currentStatus, (status) {
      final statusStr = status?.toString().toLowerCase() ?? '';
      if (statusStr == 'delivered' ||
          statusStr == 'completed') {
        // Show dialog when delivery is completed
        _showDeliveryCompletedDialog();
      }
    });
  }

  @override
  void dispose() {
    trackingService.stopTracking();
    super.dispose();
  }

  void _initializeTracking() {
    // Initialize with initial data if available
    if (widget.initialData != null) {
      trackingService.deliveryData.value = widget.initialData!;
      trackingService.driverData.value = widget.initialData!['driver'] ?? {};
    }

    // Start tracking
    trackingService.startTracking(widget.deliveryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        title: TextWidget(
          text: 'Track Your Delivery',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        centerTitle: true,
        actions: [
          // Refresh button
          Obx(() => IconButton(
                onPressed: trackingService.isLoading.value
                    ? null
                    : () => _refreshStatus(),
                icon: trackingService.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      )
                    : Icon(Icons.refresh, color: AppColors.primaryColor),
                tooltip: 'Refresh Status',
              )),
        ],
      ),
      body: Obx(() {
        if (trackingService.isLoading.value &&
            trackingService.deliveryData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16.h),
                TextWidget(
                  text: 'Loading delivery information...',
                  fontSize: 16.sp,
                  color: AppColors.greyTextColor,
                ),
              ],
            ),
          );
        }

        if (trackingService.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64.sp, color: AppColors.redColor),
                SizedBox(height: 16.h),
                TextWidget(
                  text: 'Error',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.redColor,
                ),
                SizedBox(height: 8.h),
                TextWidget(
                  text: trackingService.error.value,
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () =>
                      trackingService.startTracking(widget.deliveryId),
                  child: TextWidget(
                    text: 'Retry',
                    fontSize: 14.sp,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Map placeholder
              _buildMapSection(),

              SizedBox(height: 20.h),

              // Delivery status card
              _buildStatusCard(),

              SizedBox(height: 20.h),

              // Action buttons (Pay Now card for pending_payment)
              if (!widget.viewOnly) _buildActionButtons(),

              SizedBox(height: 20.h),

              // Driver information
              if (trackingService.isDriverAssigned) ...[
                _buildDriverCard(),
                SizedBox(height: 20.h),
              ],

              // Progress timeline
              _buildProgressTimeline(),

              SizedBox(height: 20.h),

              // Delivery details
              _buildDeliveryDetailsCard(),

              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMapSection() {
    return SizedBox.shrink(); // Remove map section
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: 'Delivery Status',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TextWidget(
                  text: trackingService.currentStatus.value.toUpperCase(),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Progress bar
          LinearProgressIndicator(
            value: trackingService.progressValue.value,
            backgroundColor: AppColors.greyColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            minHeight: 8.h,
          ),

          SizedBox(height: 12.h),

          TextWidget(
            text:
                '${(trackingService.progressValue.value * 100).toInt()}% Complete',
            fontSize: 14.sp,
            color: AppColors.greyTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: AppColors.primaryColor,
                child: TextWidget(
                  text: _getDriverInitial(),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: _getDriverName(),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(height: 8.h),
                    TextWidget(
                      text: _formatVehicleType(trackingService.deliveryData['vehicle_type'] ?? 'cargo_van'),
                      fontSize: 13.sp,
                      color: AppColors.greyTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDriverName() {
    // Try multiple sources for driver name
    if (trackingService.driverName.value.isNotEmpty) {
      return trackingService.driverName.value;
    }

    // Try from driver data
    if (trackingService.driverData.isNotEmpty) {
      final driver = trackingService.driverData;
      final fullName = driver['full_name']?.toString().trim();
      if (fullName != null && fullName.isNotEmpty) {
        return fullName;
      }

      final firstName = driver['first_name']?.toString().trim() ?? '';
      final lastName = driver['last_name']?.toString().trim() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }

      final name = driver['name']?.toString().trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    // Try from delivery data
    if (trackingService.deliveryData['driver'] != null) {
      final driver = trackingService.deliveryData['driver'] as Map<String, dynamic>;
      final fullName = driver['full_name']?.toString().trim();
      if (fullName != null && fullName.isNotEmpty) {
        return fullName;
      }

      final firstName = driver['first_name']?.toString().trim() ?? '';
      final lastName = driver['last_name']?.toString().trim() ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }

      final name = driver['name']?.toString().trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    return 'Driver';
  }

  String _getDriverInitial() {
    final name = _getDriverName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  Widget _buildProgressTimeline() {
    final steps = [
      {
        'title': 'Delivery Created',
        'status': 'confirmed',
        'icon': AppIcons.diliveriesIcon,
      },
      {
        'title': 'Driver Assigned',
        'status': 'assigned',
        'icon': Icons.person,
      },
      {
        'title': 'Driver Arriving',
        'status': 'arriving',
        'icon': AppIcons.markerIcon,
      },
      {
        'title': 'Driver Arrived',
        'status': 'arrived',
        'icon': AppIcons.oneIcon,
      },
      {
        'title': 'Item Picked Up',
        'status': 'picked_up',
        'icon': AppIcons.twoIcon,
      },
      {
        'title': 'In Transit',
        'status': 'in_transit',
        'icon': AppIcons.threeIcon,
      },
      {
        'title': 'Delivered',
        'status': 'delivered',
        'icon': Icons.check_circle,
      },
    ];

    return Obx(() {
      final currentStatus = trackingService.currentStatus.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Delivery Timeline',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 20.h),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final stepStatus = step['status'] as String;
              final stepTitle = step['title'] as String;
              final stepIcon = step['icon'];
              final normalizedCurrent = _normalizeStatus(currentStatus);
              final normalizedStep = _normalizeStatus(stepStatus);

              final isCompleted = _isStepCompleted(stepStatus, currentStatus);
              final isCurrent = normalizedCurrent == normalizedStep;
              final isLast = index == steps.length - 1;

              return _buildTimelineStep(
                title: stepTitle,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: isLast,
                icon: stepIcon,
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildTimelineStep({
    required String title,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required dynamic icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? AppColors.primaryColor
                    : AppColors.greyColor.withValues(alpha: 0.2),
                border: isCurrent
                    ? Border.all(color: AppColors.primaryColor, width: 2)
                    : null,
              ),
              child: icon is String
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SvgPicture.asset(
                        icon,
                        colorFilter: ColorFilter.mode(
                          isCompleted || isCurrent
                              ? AppColors.whiteColor
                              : AppColors.greyTextColor,
                          BlendMode.srcIn,
                        ),
                        height: 18.h,
                        width: 18.w,
                      ),
                    )
                  : Icon(
                      icon,
                      color: isCompleted || isCurrent
                          ? AppColors.whiteColor
                          : AppColors.greyTextColor,
                      size: 18.sp,
                    ),
            ),
            // Connecting line (extends to bottom for all steps, including last)
            Container(
              width: 2.w,
              height: 50.h,
              color: isCompleted
                  ? AppColors.primaryColor
                  : AppColors.greyColor.withValues(alpha: 0.3),
            ),
          ],
        ),

        SizedBox(width: 16.w),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  fontSize: 14.sp,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted || isCurrent
                      ? AppColors.blackColor
                      : AppColors.greyTextColor,
                ),
                if (isCurrent)
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          TextWidget(
                            text: trackingService.subStatusMessage.value,
                            fontSize: 12.sp,
                            color: AppColors.greyTextColor,
                          ),
                        ],
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDetailsCard() {
    final delivery = trackingService.deliveryData;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Delivery Details',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Pickup Address',
            value: delivery['pickup_address'] ?? 'N/A',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Dropoff Address',
            value: delivery['dropoff_address'] ?? 'N/A',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.inventory,
            label: 'Item',
            value: delivery['item_name'] ?? 'N/A',
          ),
          if (delivery['tracking_number'] != null) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.confirmation_number,
              label: 'Tracking Number',
              value: delivery['tracking_number'],
            ),
          ],
          if (delivery['estimated_fare'] != null || delivery['estimated_cost'] != null) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Total Fare',
              value: '\$${(delivery['estimated_fare'] ?? delivery['estimated_cost']).toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 16.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: label,
                fontSize: 12.sp,
                color: AppColors.greyTextColor,
              ),
              SizedBox(height: 2.h),
              TextWidget(
                text: value,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final status = trackingService.currentStatus.value.toLowerCase();
      print('🔍 DEBUG: Current status in _buildActionButtons: "$status"');
      print('🔍 DEBUG: Is pending_payment: ${status == 'pending_payment'}');
      
      final isPendingPayment = status == 'pending_payment' || status == 'pending payment';
      
      if (!isPendingPayment) {
        print('🔍 DEBUG: Status is not pending_payment, not showing button');
        return SizedBox.shrink();
      }

      print('🔍 DEBUG: Showing Pay Now button for pending_payment');
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Payment Pending',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
            SizedBox(height: 8.h),
            TextWidget(
              text: 'This delivery is awaiting payment. Please complete the payment to make it visible to drivers.',
              fontSize: 13.sp,
              color: AppColors.greyTextColor,
            ),
            SizedBox(height: 16.h),
            // Pay Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  _navigateToPayment();
                },
                child: TextWidget(
                  text: 'Pay Now',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _navigateToPayment() {
    final delivery = trackingService.deliveryData;
    final deliveryId = delivery['id'];
    final fare = delivery['estimated_fare'] ?? delivery['estimated_cost'] ?? 0.0;

    if (deliveryId == null) {
      Get.snackbar(
        'Error',
        'Delivery ID not found',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
      return;
    }

    // Navigate to payment screen with delivery data
    Get.to(
      () => PaymentMethodScreen(),
      transition: Transition.cupertino,
    );
  }

  String _formatVehicleType(String vehicleType) {
    // Convert snake_case to Title Case (e.g., "cargo_van" -> "Cargo Van")
    return vehicleType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  IconData _getStatusIcon() {
    final status = trackingService.currentStatus.value.toLowerCase();
    switch (status) {
      case 'confirmed':
      case 'pending':
        return Icons.search;
      case 'assigned':
      case 'accepted':
        return Icons.person;
      case 'picked_up':
      case 'pickedup':
        return Icons.inventory;
      case 'in_transit':
      case 'in-transit':
      case 'intransit':
        return Icons.local_shipping;
      case 'delivered':
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor() {
    final status = trackingService.currentStatus.value.toLowerCase();
    switch (status) {
      case 'confirmed':
      case 'pending':
        return Colors.orange;
      case 'assigned':
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
      case 'pickedup':
        return Colors.purple;
      case 'in_transit':
      case 'in-transit':
      case 'intransit':
        return Colors.indigo;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return AppColors.greyColor;
    }
  }

  bool _isStepCompleted(String stepStatus, String currentStatus) {
    final statusOrder = [
      'confirmed',
      'pending',
      'assigned',
      'accepted',
      'arriving',
      'arrived',
      'picked_up',
      'pickedup',
      'in_transit',
      'in-transit',
      'intransit',
      'delivered',
      'completed'
    ];

    // Map current status to standard format for comparison
    String normalizedCurrent = _normalizeStatus(currentStatus);
    String normalizedStep = _normalizeStatus(stepStatus);

    final currentIndex = statusOrder.indexOf(normalizedCurrent);
    final stepIndex = statusOrder.indexOf(normalizedStep);

    // If current status is not in the order, return false
    if (currentIndex == -1) {
      // Try to map to standard status
      if (normalizedCurrent == 'assigned') {
        return normalizedStep == 'confirmed' || normalizedStep == 'accepted';
      }
      return false;
    }

    // Step is completed if its index is less than or equal to current status index
    return stepIndex != -1 && stepIndex <= currentIndex;
  }

  /// Normalize status to standard format
  String _normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pickedup':
      case 'picked_up':
        return 'picked_up';
      case 'in-transit':
      case 'intransit':
      case 'in_transit':
        return 'in_transit';
      case 'completed':
        return 'delivered';
      case 'canceled':
        return 'cancelled';
      case 'arriving':
        return 'arriving';
      case 'arrived':
        return 'arrived';
      case 'assigned':
        return 'assigned';
      default:
        return status.toLowerCase();
    }
  }

  void _showDeliveryDetails() {
    // Show detailed delivery information
    Get.dialog(
      AlertDialog(
        title: TextWidget(
          text: 'Delivery Information',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                icon: Icons.confirmation_number,
                label: 'Delivery ID',
                value: widget.deliveryId.toString(),
              ),
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: Icons.access_time,
                label: 'Status',
                value: trackingService.currentStatus.value.toUpperCase(),
              ),
              if (trackingService.deliveryData['created_at'] != null) ...[
                SizedBox(height: 12.h),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Order Date',
                  value: trackingService.deliveryData['created_at'],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextWidget(
              text: 'Close',
              fontSize: 14.sp,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _callDriver() async {
    // Try to get phone from multiple sources
    String? phone = trackingService.driverPhone.value;

    // If not in service, try from driver data
    if ((phone ?? '').isEmpty && trackingService.driverData.isNotEmpty) {
      phone = trackingService.driverData['phone']?.toString() ??
          trackingService.driverData['phone_number']?.toString() ??
          '';
    }

    // If still empty, try from delivery data
    if ((phone ?? '').isEmpty && trackingService.deliveryData['driver'] != null) {
      final driver =
          trackingService.deliveryData['driver'] as Map<String, dynamic>;
      phone = driver['phone']?.toString() ??
          driver['phone_number']?.toString() ??
          '';
    }

    if ((phone ?? '').isNotEmpty) {
      try {
        String finalPhone = phone!;
        // Ensure phone number has + prefix for international format
        if (!finalPhone.startsWith('+')) {
          finalPhone = '+$finalPhone';
        }

        final Uri phoneUri = Uri(scheme: 'tel', path: finalPhone);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          Get.snackbar(
            'Error',
            'Cannot make phone calls on this device',
            backgroundColor: AppColors.redColor,
            colorText: AppColors.whiteColor,
          );
        }
      } catch (e) {
        print('❌ Error launching phone dialer: $e');
        Get.snackbar(
          'Error',
          'Failed to open phone dialer',
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
        );
      }
    } else {
      Get.snackbar(
        'Phone Not Available',
        'Driver phone number is not available',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  void _showDeliveryCompletedDialog() {
    // Prevent multiple dialogs
    if (Get.isDialogOpen ?? false) return;

    // Get driver proof photo URL if available
    final driverPhotoUrl =
        trackingService.deliveryData['driver_item_photo_url'];
    final deliveryId = trackingService.deliveryData['id'];

    Future.delayed(Duration(seconds: 1), () {
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: 'Delivery Completed!',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  text:
                      'Your Item has been successfully delivered. Thank you for using our service!',
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                  textAlign: TextAlign.center,
                ),
                // Show proof photo if available
                if (driverPhotoUrl != null &&
                    driverPhotoUrl.toString().isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  TextWidget(
                    text: 'Delivery Proof Photo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () {
                      // Open full-screen image viewer
                      if (deliveryId != null) {
                        final photoUrl =
                            'https://backend-deliver-me-ulz6fdmofq-uc.a.run.app/api/deliveries/driver-item-photo/$deliveryId/view';
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: Stack(
                              children: [
                                Center(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.whiteColor,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                            size: 48.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40.h,
                                  right: 20.w,
                                  child: IconButton(
                                    onPressed: () => Get.back(),
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 150.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.greyTextColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          'https://backend-deliver-me-ulz6fdmofq-uc.a.run.app/api/deliveries/driver-item-photo/$deliveryId/view',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.greyTextColor,
                                    size: 32.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  TextWidget(
                                    text: 'Photo not available',
                                    fontSize: 12.sp,
                                    color: AppColors.greyTextColor,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextWidget(
                    text: 'Tap to view full size',
                    fontSize: 12.sp,
                    color: AppColors.greyTextColor,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.until(
                        (route) => route.isFirst); // Go back to home/first page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: TextWidget(
                    text: 'Go to Home',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    });
  }

  /// Refresh delivery status manually
  Future<void> _refreshStatus() async {
    try {
      print('🔄 User triggered manual refresh');

      // Show loading indicator
      trackingService.isLoading.value = true;

      // Refresh the status
      await trackingService.refreshStatus(widget.deliveryId);

      // Show success message
      Get.snackbar(
        'Refreshed',
        'Delivery status updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('❌ Error refreshing status: $e');

      // Show error message
      Get.snackbar(
        'Refresh Failed',
        'Failed to refresh delivery status. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      trackingService.isLoading.value = false;
    }
  }
}
