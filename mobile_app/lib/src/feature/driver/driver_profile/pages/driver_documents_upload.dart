import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/profile/controller/driver_documents_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverDocumentsUpload extends StatefulWidget {
  const DriverDocumentsUpload({super.key});

  @override
  State<DriverDocumentsUpload> createState() => _DriverDocumentsUploadState();
}

class _DriverDocumentsUploadState extends State<DriverDocumentsUpload> {
  late DriverDocumentsController controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Register controller if not already registered
    if (!Get.isRegistered<DriverDocumentsController>()) {
      Get.put(DriverDocumentsController());
    }
    controller = Get.find<DriverDocumentsController>();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      await controller.loadDocuments();
      setState(() {});
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Manage Documents", leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              TextWidget(
                text: 'Manage Documents',
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.naveBlue,
              ),
              SizedBox(height: 8.h),
              TextWidget(
                text: 'Upload and manage your driver documents',
                fontSize: 14.sp,
                color: AppColors.greyColor,
              ),
              SizedBox(height: 32.h),
              
              // Driver License Section
              _buildDocumentSection(
                title: 'Driver License',
                docType: 'driver_license',
                subtitle: 'Upload your driver license document',
              ),
              SizedBox(height: 24.h),
              
              // ID Card Section
              _buildDocumentSection(
                title: 'ID Card',
                docType: 'id_card',
                subtitle: 'Upload your national ID card',
              ),
              SizedBox(height: 24.h),
              
              // Insurance Document Section
              _buildDocumentSection(
                title: 'Insurance Document',
                docType: 'insurance',
                subtitle: 'Upload your vehicle insurance document',
              ),
              SizedBox(height: 40.h),
              
              // Upload All Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: isLoading ? null : _uploadAllDocuments,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteColor,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : TextWidget(
                              text: 'Upload All Documents',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String docType,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 4.h),
          TextWidget(
            text: subtitle,
            fontSize: 12.sp,
            color: AppColors.greyColor,
          ),
          SizedBox(height: 16.h),
          
          // Document Upload Area
          _buildUploadButton(docType),
        ],
      ),
    );
  }

  Widget _buildUploadButton(String docType) {
    return Obx(() {
      final isUploaded = controller.isDocumentUploaded(docType);
      final fileName = controller.getDocumentFileName(docType);
      
      return GestureDetector(
        onTap: isUploaded ? null : () => controller.pickDocument(docType),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isUploaded ? AppColors.greenColor : AppColors.primaryColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8.r),
            color: isUploaded
                ? AppColors.greenColor.withValues(alpha: 0.1)
                : AppColors.primaryColor.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.cloud_upload,
                color: isUploaded ? AppColors.greenColor : AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: isUploaded ? 'Document Uploaded' : 'Select Document',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isUploaded ? AppColors.greenColor : AppColors.primaryColor,
                    ),
                    if (fileName.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      TextWidget(
                        text: fileName,
                        fontSize: 12.sp,
                        color: AppColors.greyColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (isUploaded)
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(docType),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20.sp,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.greyColor,
                  size: 16.sp,
                ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeleteConfirmation(String docType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete this $docType?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDocument(docType);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDocument(String docType) async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await controller.deleteDocument(docType);

      setState(() {
        isLoading = false;
      });

      if (result) {
        Get.snackbar(
          'Success',
          'Document deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          controller.error.value.isNotEmpty
              ? controller.error.value
              : 'Failed to delete document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadAllDocuments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await controller.uploadAllDocuments();

      setState(() {
        isLoading = false;
      });

      if (result) {
        Get.snackbar(
          'Success',
          'All documents uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        Get.snackbar(
          'Error',
          controller.error.value.isNotEmpty 
              ? controller.error.value 
              : 'Failed to upload documents',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
