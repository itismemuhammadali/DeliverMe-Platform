import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ScheduleDeliveryDialog extends StatefulWidget {
  final Function(DateTime date, String timeSlot) onScheduled;

  const ScheduleDeliveryDialog({
    super.key,
    required this.onScheduled,
  });

  @override
  State<ScheduleDeliveryDialog> createState() => _ScheduleDeliveryDialogState();
}

class _ScheduleDeliveryDialogState extends State<ScheduleDeliveryDialog> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  List<String> availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    // Set default date to tomorrow
    selectedDate = DateTime.now().add(Duration(days: 1));
    _updateAvailableTimeSlots();
  }

  /// Get available time slots based on selected day
  /// Backend accepts: 08:00-10:00, 10:00-12:00, 12:00-14:00, 14:00-16:00, 16:00-18:00, 18:00-20:00
  void _updateAvailableTimeSlots() {
    if (selectedDate == null) return;

    final dayOfWeek = selectedDate!.weekday; // 1=Monday, 7=Sunday

    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      // Monday to Friday: 4PM to 8PM
      availableTimeSlots = [
        '16:00-18:00', // 4PM-6PM
        '18:00-20:00', // 6PM-8PM
      ];
    } else {
      // Saturday & Sunday: 8AM to 8PM
      availableTimeSlots = [
        '08:00-10:00',
        '10:00-12:00',
        '12:00-14:00',
        '14:00-16:00',
        '16:00-18:00',
        '18:00-20:00',
      ];
    }

    // Reset selected time slot if it's not available for the new date
    if (selectedTimeSlot != null &&
        !availableTimeSlots.contains(selectedTimeSlot)) {
      selectedTimeSlot = null;
    }

    setState(() {});
  }

  /// Show calendar to select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              onSurface: AppColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateAvailableTimeSlots();
      });
    }
  }

  /// Get formatted date string
  String _getFormattedDate() {
    if (selectedDate == null) return 'Select Date';
    return DateFormat('EEEE, MMM d, yyyy').format(selectedDate!);
  }

  /// Get day type description
  String _getDayTypeDescription() {
    if (selectedDate == null) return '';
    final dayOfWeek = selectedDate!.weekday;
    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      return 'Weekday (4PM - 8PM)';
    } else {
      return 'Weekend (8AM - 8PM)';
    }
  }

  /// Convert 24-hour time slot to 12-hour format with AM/PM
  String _formatTimeSlot(String timeSlot) {
    final parts = timeSlot.split('-');
    final start = parts[0];
    final end = parts[1];

    String formatTime(String time24) {
      final hour = int.parse(time24.split(':')[0]);
      if (hour == 0) return '12:00 AM';
      if (hour < 12) return '$hour:00 AM';
      if (hour == 12) return '12:00 PM';
      return '${hour - 12}:00 PM';
    }

    return '${formatTime(start)} - ${formatTime(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Schedule Delivery',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                        SizedBox(height: 4.h),
                        TextWidget(
                          text: 'Pick your preferred date & time',
                          fontSize: 13.sp,
                          color: AppColors.whiteColor.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.whiteColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Date Selection
                    TextWidget(
                      text: 'Select Date',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryColor,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: _getFormattedDate(),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackColor,
                                  ),
                                  if (selectedDate != null) ...[
                                    SizedBox(height: 4.h),
                                    TextWidget(
                                      text: _getDayTypeDescription(),
                                      fontSize: 12.sp,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryColor,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Time Slot Selection
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        TextWidget(
                          text: 'Select Time Slot',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Time Slots Grid
                    if (availableTimeSlots.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxHeight: 280.h),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: availableTimeSlots.map((timeSlot) {
                              final isSelected = selectedTimeSlot == timeSlot;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTimeSlot = timeSlot;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 14.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              AppColors.primaryColor,
                                              AppColors.primaryColor.withValues(alpha: 0.8),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : AppColors.greyTextColor.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: isSelected
                                            ? AppColors.whiteColor
                                            : AppColors.primaryColor,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      TextWidget(
                                        text: _formatTimeSlot(timeSlot),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.whiteColor
                                            : AppColors.blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.tabColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.greyTextColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.greyTextColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            TextWidget(
                              text: 'Please select a date first',
                              fontSize: 14.sp,
                              color: AppColors.greyTextColor,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 24.h),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedDate != null && selectedTimeSlot != null)
                            ? () {
                                widget.onScheduled(selectedDate!, selectedTimeSlot!);
                                Navigator.of(context).pop();
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                                        SizedBox(width: 8.w),
                                        Text('Please select both date and time slot'),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (selectedDate != null && selectedTimeSlot != null)
                              ? AppColors.primaryColor
                              : AppColors.greyTextColor.withValues(alpha: 0.4),
                          foregroundColor: AppColors.whiteColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: (selectedDate != null && selectedTimeSlot != null) ? 4 : 0,
                          shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.whiteColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            TextWidget(
                              text: 'Confirm Schedule',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


