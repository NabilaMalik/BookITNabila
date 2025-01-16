import 'dart:typed_data';

class ShopVisitModel {
  String? shopVisitMasterId;
  String? brand;
  String? shop_name;
  String? shop_address;
  String? owner_name;
  String? booker_name;
  bool? walkthrough;
  bool? planogram;
  bool? signage;
  bool? productReviewed;
  Uint8List? addPhoto;  // Store image as Uint8List
  String? feedback;

  ShopVisitModel({
    this.shopVisitMasterId,
    this.brand,
    this.shop_name,
    this.shop_address,
    this.owner_name,
    this.booker_name,
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
      shop_name: json['shop_name'],
      shop_address: json['shop_address'],
      owner_name: json['owner_name'],
      booker_name: json['booker_name'],
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
      'shop_name': shop_name,
      'shop_address': shop_address,
      'owner_name': owner_name,
      'booker_name': booker_name,
      'walkthrough': walkthrough == true ? 1 : 0,
      'planogram': planogram == true ? 1 : 0,
      'signage': signage == true ? 1 : 0,
      'productReviewed': productReviewed == true ? 1 : 0,
      'body': addPhoto,
      'feedback': feedback,
    };
  }
}
