import 'dart:developer';

import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/dialog.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/independent_contractor_agrement/independent_contractor_agrement.dart';
import 'package:deliver_mee/src/feature/auth/sign_in/sign_in_page.dart';
import 'package:deliver_mee/src/feature/auth/upload_document/banking_information_page.dart';
import 'package:deliver_mee/src/feature/auth/upload_document/controller.dart';
import 'package:deliver_mee/src/feature/auth/upload_document/widget/car_pick_bottom_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({super.key});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController numberCtrl = TextEditingController();
  TextEditingController yearCtrl = TextEditingController();
  TextEditingController modelCtrl = TextEditingController();

  final List<String> carBrands = [
    'Aston Martin',
    'Chevrolet',
    'BMW',
    'Audi'
        'Bentley',
  ];
  final List<String> vehicletypelist = [
    'Car',
    'SUV',
    'Pick Up Truck',
    'Cargo Van',
  ];
  final _formkey = GlobalKey<FormState>();
  String? selectedBrand;
  String? selectedvehicletype;
  Widget build(BuildContext context) {
    final PaymentController ctrl = Get.find<PaymentController>();
    return Scaffold(
      appBar: CustomAppBar(
        text: 'Upload Documents',
        leading: true,
      ),
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15.h,
                ),
                TextWidget(
                  text: 'Register as a Driver',
                  fontSize: 20.sp,
                  color: AppColors.naveBlue,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text:
                      "Upload the required documents for verification, and you'll receive an email notification within 24 hours.",
                  fontSize: 10.sp,
                  color: Color(0xff607080),
                ),
                SizedBox(
                  height: 20.h,
                ),
                TextWidget(
                  text: 'Full Name',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: 'ex.Jonathan Paul Ive',
                  controller: nameCtrl,
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
                  text: 'Vehicle Registration Number',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: 'BRD 4310',
                  controller: numberCtrl,
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
                  text: 'Select your vehicle type',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                DropdownButtonFormField<String>(
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Input is Required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 18.h),
                      filled: true,
                      fillColor: AppColors.textfieldColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide(
                            width: 1.w,
                            color: AppColors.blackColor.withValues(alpha: .7)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide(
                            width: 1.w, color: AppColors.textfieldColor),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide:
                            BorderSide(width: 1.w, color: AppColors.redColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide:
                            BorderSide(width: 1.w, color: AppColors.redColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide(
                            width: 1.w, color: AppColors.textfieldColor),
                      )),
                  initialValue: selectedvehicletype,
                  hint: TextWidget(
                    text: "Select vehicle type",
                    color: AppColors.hintTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  items: vehicletypelist.map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: TextWidget(
                        text: brand,
                        color: AppColors.blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedvehicletype = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Make',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                // DropdownButtonFormField<String>(
                //   validator: (val) {
                //     if (val == null || val.isEmpty) {
                //       return 'Input is Required';
                //     }
                //     return null;
                //   },
                //   decoration: InputDecoration(
                //       filled: true,
                //       fillColor: AppColors.textfieldColor,
                //       focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(6.r),
                //         borderSide: BorderSide(
                //             width: 1.w,
                //             color: AppColors.blackColor.withValues(alpha: .7)),
                //       ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(6.r),
                //         borderSide: BorderSide(
                //             width: 1.w, color: AppColors.textfieldColor),
                //       ),
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(6.r),
                //         borderSide: BorderSide(
                //             width: 1.w, color: AppColors.textfieldColor),
                //       )),
                //   value: selectedBrand,
                //   hint: TextWidget(
                //     text: "Select Car",
                //     color: AppColors.hintTextColor,
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w500,
                //   ),
                //   items: carBrands.map((brand) {
                //     final isSelected = brand == selectedBrand;
                //     return DropdownMenuItem<String>(
                //       value: brand,
                //       child: TextWidget(
                //         text: brand,
                //         color: AppColors.blackColor,
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedBrand = value;
                //     });
                //   },
                // ),
                GetBuilder<AuthController>(
                    id: 'getCarName',
                    builder: (scontext) {
                      return CustomTextFormField(
                          readOnly: true,
                          onTap: () {
                            carPickerBottomSheet(
                              context,
                              initialCar: AuthController.to.selectedCar.value,
                              onCarPicked: (selected) {
                                print("Selected Car: $selected");
                              },
                            );
                          },
                          hint: 'Select Car',
                          controller: AuthController.to.selectedCarCtrl,
                          validator: (validator) {
                            if (validator!.isEmpty) {
                              return 'Please Select any One';
                            } else {
                              return null;
                            }
                          });
                    }),
                // (child: TextWidget(text: 'text')),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Year',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: '2004',
                  keyboardType: TextInputType.number,
                  controller: yearCtrl,
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
                  text: 'Model',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  hint: 'Station wagon',
                  controller: modelCtrl,
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
                  text: 'Upload Driver License',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 15.h,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: DottedBorder(
                      radius: Radius.circular(12.r),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      borderPadding: EdgeInsets.symmetric(horizontal: 5),
                      borderType: BorderType.RRect,
                      dashPattern: [7],
                      strokeWidth: 2,
                      stackFit: StackFit.loose,
                      color: AppColors.richTextColor,
                      child: Padding(
                        padding: EdgeInsets.all(7.h),
                        child: CustomContainer(
                          onTap: () {
                            showImagePickBottomSheet(cameraOnTap: () async {
                              Get.back();
                              await AuthController.to
                                  .pickImage(ImageSource.camera);
                            }, GalleryOnTap: () async {
                              Get.back();
                              await AuthController.to
                                  .pickImage(ImageSource.gallery);
                            });
                          },
                          borderRadius: 12.r,
                          width: double.infinity,
                          color: AppColors.whiteColor,
                          height: 160.h,
                          child: GetBuilder<AuthController>(
                              id: 'imagepick',
                              builder: (csontext) {
                                return AuthController.to.image != null
                                    ? Padding(
                                        padding: EdgeInsets.all(0.h),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: Image.file(
                                            AuthController.to.image!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // color: AppColors.whiteColor,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.galleryIcon,
                                              height: 35.h,
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextWidget(
                                                  text: 'Click to upload ',
                                                  fontSize: 13.sp,
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                TextWidget(
                                                  text: 'or drag and drop',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            TextWidget(
                                              text:
                                                  'JPG, JPEG, PNG less than 1MB',
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w400,
                                            )
                                          ],
                                        ),
                                      );
                              }),
                        ),
                      )),
                ),
                SizedBox(
                  height: 20.h,
                ),
                TextWidget(
                  text: 'Upload Your ID',
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 15.h,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: DottedBorder(
                      radius: Radius.circular(12.r),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      borderPadding: EdgeInsets.symmetric(horizontal: 5),
                      borderType: BorderType.RRect,
                      dashPattern: [7],
                      strokeWidth: 2,
                      stackFit: StackFit.loose,
                      color: AppColors.richTextColor,
                      child: Padding(
                        padding: EdgeInsets.all(7.h),
                        child: CustomContainer(
                          onTap: () {
                            showImagePickBottomSheet(cameraOnTap: () async {
                              Get.back();
                              await AuthController.to
                                  .pickImageTwo(ImageSource.camera);
                            }, GalleryOnTap: () async {
                              Get.back();
                              await AuthController.to
                                  .pickImageTwo(ImageSource.gallery);
                            });
                          },
                          borderRadius: 12.r,
                          width: double.infinity,
                          color: AppColors.whiteColor,
                          height: 160.h,
                          child: GetBuilder<AuthController>(
                              id: 'imagepicktwo',
                              builder: (csontext) {
                                return AuthController.to.imageTwo != null
                                    ? Padding(
                                        padding: EdgeInsets.all(0.h),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: Image.file(
                                            AuthController.to.imageTwo!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // color: AppColors.whiteColor,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.galleryIcon,
                                              height: 35.h,
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextWidget(
                                                  text: 'Click to upload ',
                                                  fontSize: 13.sp,
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                TextWidget(
                                                  text: 'or drag and drop',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            TextWidget(
                                              text:
                                                  'JPG, JPEG, PNG less than 1MB',
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w400,
                                            )
                                          ],
                                        ),
                                      );
                              }),
                        ),
                      )),
                ),
                SizedBox(
                  height: 30.h,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(BankingInformationPage(),
                        transition: Transition.cupertino);
                  },
                  child: Row(
                    children: [
                      TextWidget(
                        text: 'Add Payment Details',
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                      TextWidget(
                        text: ' *',
                        color: AppColors.redColor,
                        fontWeight: FontWeight.w600,
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.richTextColor,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                buildBackgroundCheckOption(),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r)),
                        checkColor: AppColors.whiteColor,
                        fillColor: WidgetStatePropertyAll(ctrl.ischecked.value
                            ? AppColors.primaryColor
                            : AppColors.whiteColor),
                        side: BorderSide(color: AppColors.blackColor),
                        value: ctrl.ischecked.value,
                        onChanged: (_) =>
                            ctrl.ischecked.value = !ctrl.ischecked.value,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'I read and agree to the '),
                            TextSpan(
                              text: 'Independent Contractor Agreement',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(IndependentContractScreen(),
                                      transition: Transition.cupertino);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
                CustomButton(
                  text: 'Submit for Review',
                  ontap: () {
                    if (_formkey.currentState!.validate() &&
                        ctrl.ischecked.value) {
                      if (AuthController.to.image == null ||
                          AuthController.to.imageTwo == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Image is Required'),
                          backgroundColor: AppColors.redColor,
                        ));
                      } else if (!ctrl.ispaid.value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please add a payment method'),
                          backgroundColor: AppColors.redColor,
                        ));
                      } else {
                        Get.dialog(
                          ConfirmationDialog(
                            aspectRatio: 1 / 0.6,
                            onYesBtnClick: () {
                              ctrl.ispaid.value = false;
                              Get.back();
                              Get.offAll(SignInPage(),
                                  transition: Transition.cupertino);
                            },
                            subDescription:
                                "Your application is submitted successfully. We’ll review and verify within 24 hours.",
                            heading: "Submitted",
                          ),
                        );

                        log('------You can login now');
                      }
                    }
                  },
                  width: double.infinity,
                ),

                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showImagePickBottomSheet({
    required void Function()? cameraOnTap,
    required void Function()? GalleryOnTap,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (contsssext) {
        return Container(
          height: 200.h,
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              TextWidget(
                text: 'Choose Image',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(
                height: 10.h,
              ),
              ListTile(
                onTap: cameraOnTap,
                leading: Icon(Icons.camera_alt_outlined),
                title: TextWidget(
                  text: 'Camera',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              ListTile(
                onTap: GalleryOnTap,
                leading: Icon(Icons.photo_library_outlined),
                title: TextWidget(
                  text: 'Gallery',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildBackgroundCheckOption() {
    final controller = Get.find<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ignore: deprecated_member_use
            Obx(() => Radio<bool>(
                  value: true,
                  groupValue: controller.isSelected.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.isSelected.value = value;
                    }
                  },
                  activeColor: AppColors.primaryColor,
                )),
            TextWidget(
              text: "Generate background check with ",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            SizedBox(width: 4.w),
            Image.asset(
              AppImages.checkerimg,
              height: 20.h,
              width: 20.w,
            ),
            TextWidget(
              text: " Checkr",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 15.w),
            Icon(Icons.info_outline, color: Colors.amber, size: 16.sp),
            SizedBox(width: 6.w),
            Flexible(
              child: TextWidget(
                text: "We use Checkr for secure driver background checks.",
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
