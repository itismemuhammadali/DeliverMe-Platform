// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:my_glocose_app/src/common/constant/app_color.dart';
// import 'package:my_glocose_app/src/common/utils/custom_container.dart';
// import 'package:my_glocose_app/src/common/utils/text_widget.dart';

// class ShowadowAppbar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final VoidCallback? onBack;
//   final Widget? lastWidget;

//   const ShowadowAppbar({
//     Key? key,
//     required this.title,
//     this.onBack,
//     this.lastWidget,
//   }) : super(key: key);

//   @override
//   Size get preferredSize => Size.fromHeight(80.h);

//   @override
//   Widget build(BuildContext context) {
//     return PreferredSize(
//       preferredSize: preferredSize,
//       child: Center(
//         child: CustomContainer(
//           height: 60.h,
//           onTap: onBack ??
//               () {
//                 Get.back();
//               },
//           color: AppColors.whiteColor,
//           boxShadow: [
//             BoxShadow(
//                 offset: Offset(0, 2),
//                 blurRadius: 8,
//                 color: AppColors.blackColor.withValues(alpha: .1))
//           ],
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15.w),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.arrow_back,
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 TextWidget(
//                   text: title,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.blackColor,
//                 ),
//                 Spacer(),
//                 lastWidget ?? SizedBox()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
