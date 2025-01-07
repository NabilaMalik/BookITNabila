import 'dart:convert';
import 'dart:typed_data';
class ShopVisitModel{

  int? shopVisitMasterId;
  String? brand;
  String? shopName;
  String? shopAddress;
  String? shopOwner;
  String? bookerName;
  dynamic? walkthrough;
  dynamic? planogram;
  dynamic? signage;
  dynamic? productReviewed;
  String? addPhoto;
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


  factory ShopVisitModel.fromMap(Map<dynamic,dynamic> json){
    return ShopVisitModel(
      shopVisitMasterId: json['shopVisitMasterId'],
        brand: json['brand'],
        shopName: json['shopName'],
        shopAddress: json['shopAddress'],
        shopOwner: json['ShopOwner'],
        bookerName: json['bookerName'],
      walkthrough: json['walkthrough'] == 1 || json['walkthrough'] == 'true' || json['walkthrough'] == true,
      planogram: json['planogram'] == 1 || json['planogram'] == 'true' || json['planogram'] == true,
      signage: json['signage'] == 1 || json['signage'] == 'true' || json['signage'] == true,
      productReviewed: json['productReviewed'] == 1 || json['productReviewed'] == 'true' || json['productReviewed'] == true,

        addPhoto: json['body'] ,
      //   != null && json['body'].toString().isNotEmpty
      //     ? Uint8List.fromList(base64Decode(json['body'].toString()))
      //     : null,
      // addPhoto: json['body'] != null && json['body'].toString().isNotEmpty
      //     ? Uint8List.fromList(base64Decode(json['body'].toString()))
      //     : null,
        feedback: json['feedback'],

    );
  }

  Map<String, dynamic> toMap(){
    return{

      'shopVisitMasterId':shopVisitMasterId,
      'brand':brand,
      'shopName':shopName,
      'shopAddress':shopAddress,
      'ShopOwner':shopOwner,
      'bookerName':bookerName,
      'walkthrough':walkthrough,
      'planogram':planogram,
      'signage':signage,
      'productReviewed':productReviewed,
      // 'body': addPhoto != null ? base64Encode(addPhoto!) : null,
      'body': addPhoto,
      'feedback':feedback,
    };
  }
}
