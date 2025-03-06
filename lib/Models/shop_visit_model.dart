import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

class ShopVisitModel {
  String? shop_visit_master_id;
  String? brand;
  String? user_id;
  String? shop_name;
  String? shop_address;
  String? owner_name;
  String? booker_name;
  bool? walk_through;
  bool? planogram;
  bool? signage;
  bool? product_reviewed;
  Uint8List? body;
  String? feedback;
  DateTime? shop_visit_date;
  DateTime? shop_visit_time;
  int posted;


  ShopVisitModel({
    this.shop_visit_master_id,
    this.brand,
    this.user_id,
    this.shop_name,
    this.shop_address,
    this.owner_name,
    this.booker_name,
    this.walk_through,
    this.planogram,
    this.signage,
    this.product_reviewed,
    this.body,
    this.feedback,
    this.shop_visit_date,
    this.shop_visit_time,
    this.posted = 0,
  });

  factory ShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    return ShopVisitModel(
      shop_visit_master_id: json['shop_visit_master_id'].toString(),
      brand: json['brand'].toString(),
      shop_name: json['shop_name'].toString(),
      shop_address: json['shop_address'].toString(),
      owner_name: json['owner_name'].toString(),
      booker_name: json['booker_name'].toString(),
      walk_through: json['walk_through'] == 1.toString(),
      planogram: json['planogram'] == 1.toString(),
      signage: json['signage'] == 1.toString(),
      user_id: json['user_id'].toString(),
      product_reviewed: json['product_reviewed'] == 1.toString(),
      body: json['body'] != null && json['body'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['body'].toString()))
          : null,
      feedback: json['feedback'],
      shop_visit_date: DateTime.now(),
      // Always set live date
      shop_visit_time: DateTime.now(),
      posted: json['posted'] ?? 0,

      // Always set live time
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shop_visit_master_id': shop_visit_master_id,
      'brand': brand,
      'shop_name': shop_name,
      'shop_address': shop_address,
      'owner_name': owner_name,
      'booker_name': booker_name,
      'user_id': user_id,
      'walk_through': walk_through == true ? 1 : 0,
      'planogram': planogram == true ? 1 : 0,
      'signage': signage == true ? 1 : 0,
      'product_reviewed': product_reviewed == true ? 1 : 0,
      'body':  body != null ? base64Encode(body!) : null,
      'feedback': feedback,
      'shop_visit_date': DateFormat('dd-MMM-yyyy')
          .format(shop_visit_date ?? DateTime.now()), // Always set live date
      'shop_visit_time': DateFormat('HH:mm:ss')
          .format(shop_visit_time ?? DateTime.now()), // Always set live time
      'posted': posted,
    };
  }
}
