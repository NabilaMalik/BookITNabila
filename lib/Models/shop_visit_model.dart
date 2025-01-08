import 'dart:typed_data';

class ShopVisitModel {
  int? shopVisitMasterId;
  String? brand;
  String? shopName;
  String? shopAddress;
  String? shopOwner;
  String? bookerName;
  bool? walkthrough;
  bool? planogram;
  bool? signage;
  bool? productReviewed;
  Uint8List? addPhoto;  // Store image as Uint8List
  String? feedback;

  ShopVisitModel({
    this.shopVisitMasterId,
    this.brand,
    this.shopName,
    this.shopAddress,
    this.shopOwner,
    this.bookerName,
    this.walkthrough,
    this.planogram,
    this.signage,
    this.productReviewed,
    this.addPhoto,
    this.feedback,
  });

  factory ShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    return ShopVisitModel(
      shopVisitMasterId: json['shopVisitMasterId'],
      brand: json['brand'],
      shopName: json['shopName'],
      shopAddress: json['shopAddress'],
      shopOwner: json['ShopOwner'],
      bookerName: json['bookerName'],
      walkthrough: json['walkthrough'] == 1,
      planogram: json['planogram'] == 1,
      signage: json['signage'] == 1,
      productReviewed: json['productReviewed'] == 1,
      addPhoto: json['body'] != null ? Uint8List.fromList(List<int>.from(json['body'])) : null,
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopVisitMasterId': shopVisitMasterId,
      'brand': brand,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'ShopOwner': shopOwner,
      'bookerName': bookerName,
      'walkthrough': walkthrough == true ? 1 : 0,
      'planogram': planogram == true ? 1 : 0,
      'signage': signage == true ? 1 : 0,
      'productReviewed': productReviewed == true ? 1 : 0,
      'body': addPhoto,
      'feedback': feedback,
    };
  }
}
