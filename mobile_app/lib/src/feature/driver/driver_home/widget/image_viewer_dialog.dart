import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/constant/app_colors.dart';
import '../../../../common/utils/text_widget.dart';

class ImageViewerDialog extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(8.w),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextWidget(
                      text: title ?? 'Item Photo',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.whiteColor,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Image content - Takes up most of the space
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 20.h),
                            TextWidget(
                              text: 'Loading image...',
                              fontSize: 16.sp,
                              color: AppColors.greyTextColor,
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 56.sp,
                              color: AppColors.redColor,
                            ),
                            SizedBox(height: 20.h),
                            TextWidget(
                              text: 'Failed to load image',
                              fontSize: 16.sp,
                              color: AppColors.redColor,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 10.h),
                            TextWidget(
                              text: 'Please try again',
                              fontSize: 14.sp,
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
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String imageUrl, {String? title}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ImageViewerDialog(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }
}
