import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewScreen extends StatelessWidget {
  final String username;
  final String img;
  const ProfileViewScreen({super.key, required this.username, required this.img});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: username, leading: true),
      body: Container(
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        child: Center(
          child: Image.asset(
            img,
            fit: BoxFit.contain,
            height: 400.h,
            width: ScreenUtil().screenWidth,
          ),
        ),
      ),
    );
  }
}
