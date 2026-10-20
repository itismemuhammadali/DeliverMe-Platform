import 'dart:async';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/ios_time_pick_bottom_sheet.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/deliveries/controller.dart';
import 'package:deliver_mee/src/feature/user/delivery/controller.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/feature/user/payment/payment.dart';
import 'package:deliver_mee/src/common/services/pricing_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ScheduleDeliveryScreen extends StatefulWidget {
  const ScheduleDeliveryScreen({super.key});

  @override
  State<ScheduleDeliveryScreen> createState() => _ScheduleDeliveryScreenState();
}

class _ScheduleDeliveryScreenState extends State<ScheduleDeliveryScreen> {
  TextEditingController timeController = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();

  // Debouncing for pricing calculations
  Timer? _pricingTimer;
  bool _isCalculatingPricing = false;

  @override
  void initState() {
    super.initState();

    // Calculate pricing when screen loads
    _calculatePricing();

    // Listen to vehicle type changes and recalculate pricing with debouncing
    final homeController = Get.find<HomeController>();
    homeController.selectedVehicleType
        .listen((_) => _debouncedCalculatePricing());

    // Listen to location changes and recalculate pricing with debouncing
    homeController.fromlocation.listen((_) => _debouncedCalculatePricing());
    homeController.tolocation.listen((_) => _debouncedCalculatePricing());
  }

  @override
  void dispose() {
    _pricingTimer?.cancel();
    super.dispose();
  }

  /// Debounced pricing calculation to prevent excessive API calls
  void _debouncedCalculatePricing() {
    _pricingTimer?.cancel();
    _pricingTimer = Timer(Duration(milliseconds: 500), () {
      _calculatePricing();
    });
  }

  /// Calculate pricing for the delivery
  Future<void> _calculatePricing() async {
    // Prevent duplicate calculations
    if (_isCalculatingPricing) {
      print('⏳ Pricing calculation already in progress, skipping...');
      return;
    }

    try {
      _isCalculatingPricing = true;
      final homeController = Get.find<HomeController>();
      final pricingService = Get.find<PricingService>();

      // Only calculate if we have valid coordinates
      if (homeController.pickupLatitude.value > 0 &&
          homeController.pickupLongitude.value > 0 &&
          homeController.dropoffLatitude.value > 0 &&
          homeController.dropoffLongitude.value > 0) {
        print('💰 Calculating pricing for scheduled delivery...');

        await pricingService.calculateFare(
          pickupLatitude: homeController.pickupLatitude.value,
          pickupLongitude: homeController.pickupLongitude.value,
          dropoffLatitude: homeController.dropoffLatitude.value,
          dropoffLongitude: homeController.dropoffLongitude.value,
          vehicleType: homeController.selectedVehicleType.value,
        );
      } else {
        print('⚠️ Invalid coordinates, using default pricing');
        pricingService.setDefaultPricing();
      }
    } catch (e) {
      print('❌ Error calculating pricing: $e');
      final pricingService = Get.find<PricingService>();
      pricingService.setDefaultPricing();
    } finally {
      _isCalculatingPricing = false;
    }
  }

  /// Get estimated price for display
  double _getEstimatedPrice() {
    final homeController = Get.find<HomeController>();
    final pricingService = Get.find<PricingService>();

    // Use delivery price if available (from delivery response)
    if (homeController.deliveryPrice.value > 0) {
      return homeController.deliveryPrice.value;
    }
    // Fallback to pricing service
    else if (pricingService.totalFare.value > 0) {
      return pricingService.totalFare.value;
    }
    // Return 0 if no price available
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliverController>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
          text: controller.scheduleDelivery.value
              ? "Schedule Delivery"
              : "Immediate Delivery",
          leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address info
              locationSelectorRow(),
              SizedBox(height: 16.h),

              // Item details summary - Use data from HomeController
              Obx(() {
                final homeController = Get.find<HomeController>();
                return Row(
                  children: [
                    _summaryBox("Item", homeController.itemName.value),
                    _summaryBox("${homeController.itemWeight.value}", "LB"),
                  ],
                );
              }),

              SizedBox(height: 16.h),

              // Item details - Show item name and description from HomeController
              Obx(() {
                final homeController = Get.find<HomeController>();
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: "Item Details",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      TextWidget(
                        text:
                            "Item: ${homeController.itemName.value.isNotEmpty ? homeController.itemName.value : 'Item'}",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      if (homeController.itemDescription.value.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        TextWidget(
                          text:
                              "Description: ${homeController.itemDescription.value}",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          TextWidget(
                            text: "Vehicle: ",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          TextWidget(
                            text: homeController.selectedVehicleType.value
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 16.h),

              // Images
              SizedBox(
                height: 100.h,
                child: Row(
                  children: [
                    Expanded(
                      child: _imageBox(
                        AppImages.boxone,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(child: _imageBox(AppImages.boxtwo)),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Only Schedule delivery (Immediate removed)
              Obx(() => Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        child: CustomContainer(
                          borderRadius: 10.r,
                          color: AppColors.primaryColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: true,
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              fillColor: WidgetStatePropertyAll(Colors.white),
                              side: BorderSide(color: Colors.white),
                              onChanged: null, // Always true
                              title: TextWidget(
                                text: "Schedule Delivery",
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              subtitle: TextWidget(
                                text:
                                    "Schedule your delivery from 60 minutes in advance",
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 16.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery date
                    TextWidget(
                      text: "When do you want the delivery?",
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                        SizedBox(height: 10.h),
                        // TextWidget(
                        //   text: "Select Date",
                        //   fontSize: 14.sp,
                        //   fontWeight: FontWeight.w500,
                        // ),

                        CustomTextFormField(
                          hint: 'Select Date',
                          hintTextColor: AppColors.greyTextColor,
                          controller: dateCtrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a date";
                            }
                            return null;
                          },
                          suffixIcon: InkWell(
                            onTap: () {
                              iosDatePickerBottomSheet(
                                context,
                                initialDate: DateTime.now(),
                                onTimePicked: (DateTime pickedDate) {
                                  DeliveresController.to.setDate(pickedDate);
                                  dateCtrl.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  // Pre-calculate pricing when date is selected
                                  _debouncedCalculatePricing();
                                },
                              );
                            },
                            child: Icon(
                              Icons.calendar_month,
                              size: 30.h,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Obx(() => Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: List.generate(controller.dates.length,
                        //           (index) {
                        //         bool selected =
                        //             controller.selectedDateIndex.value == index;
                        //         return GestureDetector(
                        //           onTap: () => controller
                        //               .selectedDateIndex.value = index,
                        //           child: Container(
                        //             width: 56.w,
                        //             padding:
                        //                 EdgeInsets.symmetric(vertical: 8.h),
                        //             decoration: BoxDecoration(
                        //               border: Border.all(
                        //                   color: selected
                        //                       ? AppColors.primaryColor
                        //                       : Colors.grey),
                        //               borderRadius: BorderRadius.circular(10.r),
                        //               color: selected
                        //                   ? AppColors.primaryColor
                        //                       .withValues(alpha: 0.1)
                        //                   : Colors.white,
                        //             ),
                        //             child: Center(
                        //               child: TextWidget(
                        //                 text: controller.dates[index],
                        //                 color: selected
                        //                     ? AppColors.primaryColor
                        //                     : Colors.black,
                        //                 fontWeight: FontWeight.w500,
                        //                 fontSize: 14.sp,
                        //                 textAlign: TextAlign.center,
                        //               ),
                        //             ),
                        //           ),
                        //         );
                        //       }),
                        //     )),
                        SizedBox(height: 16.h),

                        CustomTextFormField(
                          controller: timeController,
                          hint: 'Select Time',
                          hintTextColor: AppColors.greyTextColor,
                          validator: (validator) => null,
                          suffixIcon: InkWell(
                            onTap: () {
                              iosTimePickerBottomSheet(
                                context,
                                initialTime: TimeOfDay.now(),
                                onTimePicked: (pickedTime) {
                                  DeliveresController.to.setTime(pickedTime);

                                  timeController.text = formatTimeOfDay(
                                      DeliveresController
                                          .to.selectedTime.value!);
                                  print(
                                      'Picked time: ${pickedTime.format(context)}');
                                  // Pre-calculate pricing when time is selected
                                  _debouncedCalculatePricing();
                                },
                              );
                            },
                            child: Icon(
                              Icons.watch_later_outlined,
                              size: 30.h,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Obx(() => Wrap(
                        //       spacing: 8.w,
                        //       runSpacing: 10.h,
                        //       children: List.generate(
                        //           controller.timeSlots.length, (index) {
                        //         bool selected =
                        //             controller.selectedTimeSlotIndex.value ==
                        //                 index;
                        //         return GestureDetector(
                        //           onTap: () => controller
                        //               .selectedTimeSlotIndex.value = index,
                        //           child: Container(
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 16.w, vertical: 8.h),
                        //             decoration: BoxDecoration(
                        //               border: Border.all(
                        //                   color: selected
                        //                       ? AppColors.primaryColor
                        //                       : Colors.grey),
                        //               borderRadius: BorderRadius.circular(10.r),
                        //               color: selected
                        //                   ? AppColors.primaryColor
                        //                       .withValues(alpha: 0.1)
                        //                   : Colors.white,
                        //             ),
                        //             child: TextWidget(
                        //               text: controller.timeSlots[index],
                        //               fontWeight: FontWeight.w500,
                        //               fontSize: 14.sp,
                        //               color: selected
                        //                   ? AppColors.primaryColor
                        //                   : Colors.black,
                        //             ),
                        //           ),
                        //         );
                        //       }),
                        //     )),
                      ],
                    ),

              SizedBox(height: 16.h),

              // Extra delivery notes
              TextWidget(
                text: "Extra Delivery Notes",
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade100,
                ),
                child: TextField(
                  onChanged: (val) => controller.deliveryNote.value = val,
                  decoration: InputDecoration.collapsed(
                    hintText: "Add Delivery Notes",
                    hintStyle: TextStyle(
                      color: AppColors.hintTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  maxLines: 4,
                ),
              ),
              SizedBox(height: 16.h),

              // Preference
              Row(
                children: [
                  TextWidget(
                    text: "Select Preference ",
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  TextWidget(
                    text: "*",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ],
              ),
              Obx(() => Column(
                    children: [
                      // ignore: deprecated_member_use
                      RadioListTile<int>(
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                        value: 0,
                        groupValue: controller.selectedPreference.value,
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedPreference.value = val;
                          }
                        },
                        title: TextWidget(
                          text:
                              "Recipient Available: someone will be present to receive the delivery at the location.",
                          color: Color(0xff5B5B5B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // ignore: deprecated_member_use
                      RadioListTile<int>(
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                        value: 1,
                        groupValue: controller.selectedPreference.value,
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedPreference.value = val;
                          }
                        },
                        title: TextWidget(
                          text:
                              "Leave at Residence/Location: permission is granted for the driver to leave the Item at the residence/location.",
                          color: Color(0xff5B5B5B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 16.h),

              // Payment - Price will be set from API response on next page
              SizedBox(height: 16.h),

              // Proceed to Payment - Show actual price from delivery response
              Obx(() {
                final pricingService = Get.find<PricingService>();
                final estimatedPrice = _getEstimatedPrice();

                String buttonText = "Proceed to Payment";

                // Show loading state if pricing is being calculated
                if (pricingService.isLoadingPricing.value) {
                  buttonText = "Calculating Price...";
                }
                // Show price if available
                else if (estimatedPrice > 0) {
                  buttonText = "Proceed to Payment";
                }
                // Default text if no price available
                else {
                  buttonText = "Proceed to Payment";
                }

                return CustomButton(
                  text: buttonText,
                  buttonColor: AppColors.primaryColor,
                  ontap: () {
                    _scheduleDelivery();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Schedule delivery and navigate to payment screen
  Future<void> _scheduleDelivery() async {
    try {
      // Set schedule type to 'scheduled' and create delivery
      final homeController = Get.find<HomeController>();
      homeController.setScheduleType('scheduled');

      // Set scheduled date and time if available
      if (dateCtrl.text.isNotEmpty) {
        try {
          // Parse the selected date (assuming format like "Mon 21" or similar)
          final now = DateTime.now();
          final dateText = dateCtrl.text.trim();

          // Extract day number from date text (e.g., "Mon 21" -> 21)
          final dayMatch = RegExp(r'\d+').firstMatch(dateText);
          if (dayMatch != null) {
            final day = int.parse(dayMatch.group(0)!);
            final scheduledDate = DateTime(now.year, now.month, day);
            homeController.setScheduledDate(scheduledDate);
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      // Set time slot if available
      if (timeController.text.isNotEmpty) {
        // Map the selected time to backend time slot format
        final timeSlot = _mapTimeToSlot(timeController.text);
        homeController.setTimeSlot(timeSlot);
        print('⏰ Mapped time "${timeController.text}" to slot "$timeSlot"');
        print(
            '🔍 HomeController timeSlot value: ${homeController.timeSlot.value}');
      } else {
        print('⚠️ Time controller is empty, using default time slot');
        homeController.setTimeSlot('16:00-18:00');
      }

      // Create delivery with scheduled type
      final deliveryId = await homeController.createDelivery();

      if (deliveryId != null) {
        // Show a brief success message before navigating
        Get.snackbar(
          'Delivery Created',
          'Your delivery has been scheduled successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          icon: Icon(Icons.check_circle, color: Colors.white),
        );

        // Navigate to payment screen immediately
        // The Obx widgets will automatically update with the new delivery data
        Get.to(PaymentMethodScreen(), transition: Transition.cupertino);
      }
      // If delivery creation fails, error message is already shown by createDelivery
    } catch (e) {
      print('❌ Error during delivery scheduling: $e');
      Get.snackbar(
        'Error',
        'Failed to schedule delivery. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _summaryBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            TextWidget(
                text: "${label} ${value}",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _imageBox(String img) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10.r),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            img,
          ),
        ),
      ),
    );
  }

  /// Map selected time to backend time slot format
  String _mapTimeToSlot(String timeText) {
    print('🕐 Mapping time: "$timeText"');
    try {
      // Parse the time text (e.g., "07:59 PM" or "19:59")
      TimeOfDay time;

      if (timeText.contains('AM') || timeText.contains('PM')) {
        // 12-hour format
        final parts = timeText.split(' ');
        final timePart = parts[0];
        final period = parts[1];
        final timeSplit = timePart.split(':');
        int hour = int.parse(timeSplit[0]);
        int minute = int.parse(timeSplit[1]);

        print('🕐 Parsed 12-hour: hour=$hour, minute=$minute, period=$period');

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        print('🕐 Converted to 24-hour: hour=$hour, minute=$minute');

        time = TimeOfDay(hour: hour, minute: minute);
      } else {
        // 24-hour format
        final timeSplit = timeText.split(':');
        int hour = int.parse(timeSplit[0]);
        int minute = int.parse(timeSplit[1]);
        time = TimeOfDay(hour: hour, minute: minute);
        print('🕐 Parsed 24-hour: hour=$hour, minute=$minute');
      }

      final homeController = Get.find<HomeController>();
      final date = homeController.scheduledDate.value ?? DateTime.now();
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final hour = time.hour;
      print('🕐 Final hour for mapping: $hour, isWeekend: $isWeekend');

      if (isWeekend) {
        // Weekend slots: 8am-8pm
        if (hour < 10) return '08:00-10:00';
        if (hour < 12) return '10:00-12:00';
        if (hour < 14) return '12:00-14:00';
        if (hour < 16) return '14:00-16:00';
        if (hour < 18) return '16:00-18:00';
        return '18:00-20:00';
      } else {
        // Weekday slots: 4pm-8pm
        if (hour < 18) {
          print('🕐 Mapped to: 16:00-18:00');
          return '16:00-18:00';
        } else {
          print('🕐 Mapped to: 18:00-20:00');
          return '18:00-20:00';
        }
      }
    } catch (e) {
      print('❌ Error parsing time "$timeText": $e');
      return '16:00-18:00'; // Default fallback
    }
  }

  Widget locationSelectorRow() {
    return Obx(() {
      final homeController = Get.find<HomeController>();
      return Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_checked,
                          color: AppColors.primaryColor, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextWidget(
                          text: homeController.fromlocation.value.isNotEmpty
                              ? homeController.fromlocation.value
                              : 'Please select pickup location',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: homeController.fromlocation.value.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationIcon,
                        height: 15.h,
                        width: 15.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextWidget(
                          text: homeController.tolocation.value.isNotEmpty
                              ? homeController.tolocation.value
                              : 'Please select dropoff location',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: homeController.tolocation.value.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 36.w,
            width: 36.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.arrowleftrightIcon,
                height: 15.h,
                width: 15.w,
              ),
            ),
          ),
        ],
      );
    });
  }
}
