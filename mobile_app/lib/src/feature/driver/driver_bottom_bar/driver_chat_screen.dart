import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/chat/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverChatScreen extends StatefulWidget {
  const DriverChatScreen({super.key});

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final ChatController controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Chat", leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundImage: AssetImage(AppImages.profileimage),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: "Naxient",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        TextWidget(
                          text: "Online",
                          fontSize: 11.sp,
                          color: Colors.grey,
                        )
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
                      child: Icon(Icons.call,
                          color: AppColors.primaryColor, size: 26.sp),
                    ),
                  ],
                ),
              ),
            ),
            CustomContainer(
              color: Colors.grey.shade300,
              height: 2.h,
            ),

            // Messages
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      width: 234.w,
                      AppImages.splashlogo,
                    ),
                  ),
                  Obx(
                    () => Container(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];
                          final isMe = msg['isMe'] as bool;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 10.h),
                              margin: EdgeInsets.only(
                                top: 8.h,
                                left: isMe ? 60.w : 0,
                                right: isMe ? 0 : 60.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: TextWidget(
                                text: msg['text'],
                                fontSize: 13.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomContainer(
              color: Colors.white,
              height: 2.h,
            ),
            // Message Input
            Container(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        hintText: "Send message...",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 13.sp),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => controller
                        .sendMessage(controller.messageController.text),
                    child: SvgPicture.asset(AppIcons.sendIcon),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
