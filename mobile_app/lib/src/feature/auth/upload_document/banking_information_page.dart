import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/upload_document/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BankingInformationPage extends StatelessWidget {
  late final TextEditingController holderNameCtrl;
  late final TextEditingController bankNameCtrl;
  late final TextEditingController transmitNumCtrl;
  late final TextEditingController institutionCtrl;
  late final TextEditingController accountNumberCtrl;
  final _fomkey = GlobalKey<FormState>();
  
  BankingInformationPage({super.key}) {
    holderNameCtrl = TextEditingController();
    bankNameCtrl = TextEditingController();
    transmitNumCtrl = TextEditingController();
    institutionCtrl = TextEditingController();
    accountNumberCtrl = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    final PaymentController ctrl = Get.find<PaymentController>();
    return Scaffold(
      appBar: CustomAppBar(
        text: 'Banking Information',
        leading: true,
      ),
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Form(
          key: _fomkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                TextWidget(
                  text: 'Bank Account Holder Name',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: 'ex.Jonathan Paul Ive',
                  controller: holderNameCtrl,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Input is Required';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Bank Name',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: 'TD Bank',
                  controller: bankNameCtrl,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Input is Required';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        text: 'Bank Transit Number',
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: TextWidget(
                        text: 'Institution Number',
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(
                        child: CustomTextFormField(
                      hint: '00000',
                      controller: transmitNumCtrl,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Input is Required';
                        } else if (val.length != 4) {
                          return 'Max length is 4';
                        } else {
                          return null;
                        }
                      },
                    )),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                        child: CustomTextFormField(
                      hint: '6 - 7 digit',
                      controller: institutionCtrl,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Input is Required';
                        } else if (val.length != 6 && val.length != 7) {
                          return 'Max length is 6 or 7';
                        } else {
                          return null;
                        }
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Account Number',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: '0000 0000 0000 0000',
                  controller: accountNumberCtrl,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Input is Required';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 50.h,
                ),
                CustomButton(
                    text: 'Save',
                    ontap: () {
                      if (_fomkey.currentState!.validate()) {
                        ctrl.ispaid.value = true;
                        Get.back();
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
