// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:deliver_mee/src/common/constant/app_images.dart';

class RequestModel {
  final String image;
  final String addressOne;
  final String addressTwo;
  final String price;
  final String totalItemCount;
  final String smallItemCount;
  final String lbItemCount;
  final String boxImage;
  RequestModel({
    required this.image,
    required this.addressOne,
    required this.addressTwo,
    required this.price,
    required this.totalItemCount,
    required this.smallItemCount,
    required this.lbItemCount,
    required this.boxImage,
  });
}

List<RequestModel> requestDataList = [
  RequestModel(
      image: AppImages.profileimage,
      addressOne: 'Building 8, 77 N WASHINGTON ST, USA',
      addressTwo: '18 PHILLIPS, ST APT 1, BOSTON, USA',
      price: '30',
      totalItemCount: '2',
      smallItemCount: '12',
      lbItemCount: '5.5',
      boxImage: AppImages.boxImage),
  RequestModel(
      image: AppImages.profileimage,
      addressOne: 'Building 8, 77 N WASHINGTON ST, USA',
      addressTwo: '18 PHILLIPS, ST APT 1, BOSTON, USA',
      price: '30',
      totalItemCount: '2',
      smallItemCount: '12',
      lbItemCount: '5.5',
      boxImage: AppImages.boxImage)
];
