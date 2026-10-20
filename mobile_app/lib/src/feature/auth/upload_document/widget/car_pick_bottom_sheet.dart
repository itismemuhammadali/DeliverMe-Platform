import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void carPickerBottomSheet(
  BuildContext context, {
  required String initialCar,
  required Function(String selectedCar) onCarPicked,
}) {
  final controller = AuthController.to;

  final cars = [
    'Toyota',
    'Ford',
    'Honda',
    'Chevrolet',
    'Volkswagen',
    'Nissan',
    'Hyundai',
    'Chrysler',
    'General Motors',
    'Subaru',
    'Mercedes-Benz',
    'Mazda',
    'Buick',
    'Kia',
    'BMW',
    'Audi',
    'Acura',
    'Dodge',
    'Lexus',
    'Other'
  ];

  final selectedIndex = cars.indexOf(initialCar);
  final scrollController =
      FixedExtentScrollController(initialItem: selectedIndex);

  showModalBottomSheet(
    backgroundColor: const Color(0xff1c1c1e),
    context: context,
    builder: (_) {
      return SizedBox(
        height: 300,
        child: Column(
          children: [
            // Top Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton(
                    onPressed: () {
                      controller
                          .saveTextOfCar(AuthController.to.selectedCar.value);
                      Navigator.pop(context);
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            // Wheel Picker
            Expanded(
              child: GetBuilder<AuthController>(
                id: 'index',
                builder: (_) {
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CustomContainer(
                          color: AppColors.greyTextColor,
                          borderRadius: 12.r,
                          height: 50,
                          width: ScreenUtil().screenWidth - 30.w,
                        ),
                      ),
                      ListWheelScrollView.useDelegate(
                        controller: scrollController,
                        itemExtent: 50,
                        perspective: 0.005,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          controller.selectCar(cars[index], index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            if (index < 0 || index >= cars.length) return null;
                            final isSelected =
                                controller.textIndex.value == index;

                            return Center(
                              child: Text(
                                cars[index],
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white54,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                          childCount: cars.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
