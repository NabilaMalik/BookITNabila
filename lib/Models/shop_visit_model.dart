// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:intl/intl.dart';
//
// class ShopVisitModel {
//   String? shop_visit_master_id;
//   String? brand;
//   String? user_id;
//   String? shop_name;
//   String? shop_address;
//   String? address;
//   String? owner_name;
//   String? booker_name;
//   bool? walk_through;
//   bool? planogram;
//   bool? signage;
//   bool? product_reviewed;
//   Uint8List? body;
//   String? feedback;
//   DateTime? shop_visit_date;
//   DateTime? shop_visit_time;
//   dynamic latitude;
//   dynamic longitude;
//   String? city;
//   int posted;
//
//
//   ShopVisitModel({
//     this.shop_visit_master_id,
//     this.brand,
//     this.user_id,
//     this.shop_name,
//     this.shop_address,
//     this.address,
//     this.owner_name,
//     this.booker_name,
//     this.walk_through,
//     this.planogram,
//     this.signage,
//     this.product_reviewed,
//     this.body,
//     this.feedback,
//     this.shop_visit_date,
//     this.shop_visit_time,
//     this.latitude,
//     this.longitude,
//     this.city,
//     this.posted = 0,
//   });
//
//   factory ShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
//     return ShopVisitModel(
//       shop_visit_master_id: json['shop_visit_master_id'].toString(),
//       brand: json['brand'].toString(),
//       shop_name: json['shop_name'].toString(),
//       shop_address: json['shop_address'].toString(),
//       address: json['address'].toString(),
//       owner_name: json['owner_name'].toString(),
//       booker_name: json['booker_name'].toString(),
//       walk_through: json['walk_through'] == 1.toString(),
//       planogram: json['planogram'] == 1.toString(),
//       signage: json['signage'] == 1.toString(),
//       user_id: json['user_id'].toString(),
//       product_reviewed: json['product_reviewed'] == 1.toString(),
//       body: json['body'] != null && json['body'].toString().isNotEmpty
//           ? Uint8List.fromList(base64Decode(json['body'].toString()))
//           : null,
//       feedback: json['feedback'],
//       shop_visit_date: DateTime.now(),
//       // Always set live date
//       shop_visit_time: DateTime.now(),
//       // Always set live time
//       latitude: json['latitude'],
//       longitude: json['longitude'],
//       city: json['city'],
//       posted: json['posted'] ?? 0,
//
//       // Always set live time
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'shop_visit_master_id': shop_visit_master_id,
//       'brand': brand,
//       'shop_name': shop_name,
//       'shop_address': shop_address,
//       'address': address,
//       'owner_name': owner_name,
//       'booker_name': booker_name,
//       'user_id': user_id,
//       'walk_through': walk_through == true ? 1 : 0,
//       'planogram': planogram == true ? 1 : 0,
//       'signage': signage == true ? 1 : 0,
//       'product_reviewed': product_reviewed == true ? 1 : 0,
//       'body':  body != null ? base64Encode(body!) : null,
//       'feedback': feedback,
//       'shop_visit_date': DateFormat('dd-MMM-yyyy')
//           .format(shop_visit_date ?? DateTime.now()), // Always set live date
//       'shop_visit_time': DateFormat('HH:mm:ss')
//           .format(shop_visit_time ?? DateTime.now()),
//       'latitude': latitude,// Always set live time
//       'longitude': longitude,// Always set live time
//       'city': city,
//       'posted': posted,
//     };
//   }
// }

// shop_visit_model.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

class ShopVisitModel {
  String? shop_visit_master_id;
  String? brand;
  String? user_id;
  String? shop_name;
  String? shop_address;
  String? address;
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
  dynamic latitude;
  dynamic longitude;
  String? city;
  int posted;

  ShopVisitModel({
    this.shop_visit_master_id,
    this.brand,
    this.user_id,
    this.shop_name,
    this.shop_address,
    this.address,
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
    this.latitude,
    this.longitude,
    this.city,
    this.posted = 0,
  });

  factory ShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    // --- FIX START: Parse the stored date/time instead of using DateTime.now() ---
    DateTime? parsedDate;
    DateTime? parsedTime;

    // Check if the date field exists and is a non-empty string
    if (json['shop_visit_date'] is String && json['shop_visit_date'].isNotEmpty) {
      try {
        // Use the format that was used to save the date in toMap (dd-MMM-yyyy)
        parsedDate = DateFormat('dd-MMM-yyyy').parse(json['shop_visit_date']);
      } catch (e) {
        // Log error or handle failure, fall back to current time if parsing fails
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now(); // Fallback if data is missing
    }

    // Check if the time field exists and is a non-empty string
    if (json['shop_visit_time'] is String && json['shop_visit_time'].isNotEmpty) {
      try {
        // Use the format that was used to save the time in toMap (HH:mm:ss)
        // Note: Parsing only time will default the date part, but the time is correct.
        parsedTime = DateFormat('HH:mm:ss').parse(json['shop_visit_time']);
      } catch (e) {
        parsedTime = DateTime.now();
      }
    } else {
      parsedTime = DateTime.now();
    }
    // --- FIX END ---

    return ShopVisitModel(
      shop_visit_master_id: json['shop_visit_master_id'].toString(),
      brand: json['brand'].toString(),
      shop_name: json['shop_name'].toString(),
      shop_address: json['shop_address'].toString(),
      address: json['address'].toString(),
      owner_name: json['owner_name'].toString(),
      booker_name: json['booker_name'].toString(),
      // Note: Comparing equality with '1.toString()' (which is '1') seems unusual
      // If the database stores 1/0 as integers, you might need to change '== 1.toString()' to '== 1' or '== 1.toString()'
      walk_through: json['walk_through'].toString() == '1',
      planogram: json['planogram'].toString() == '1',
      signage: json['signage'].toString() == '1',
      user_id: json['user_id'].toString(),
      product_reviewed: json['product_reviewed'].toString() == '1',
      body: json['body'] != null && json['body'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['body'].toString()))
          : null,
      feedback: json['feedback'],

      // *** Use the parsed, original offline time ***
      shop_visit_date: parsedDate,
      shop_visit_time: parsedTime,

      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      posted: json['posted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shop_visit_master_id': shop_visit_master_id,
      'brand': brand,
      'shop_name': shop_name,
      'shop_address': shop_address,
      'address': address,
      'owner_name': owner_name,
      'booker_name': booker_name,
      'user_id': user_id,
      'walk_through': walk_through == true ? 1 : 0,
      'planogram': planogram == true ? 1 : 0,
      'signage': signage == true ? 1 : 0,
      'product_reviewed': product_reviewed == true ? 1 : 0,
      'body': body != null ? base64Encode(body!) : null,
      'feedback': feedback,
      // When saving to DB, use the original date/time stored in the model
      'shop_visit_date': DateFormat('dd-MMM-yyyy')
          .format(shop_visit_date ?? DateTime.now()),
      'shop_visit_time': DateFormat('HH:mm:ss')
          .format(shop_visit_time ?? DateTime.now()),
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'posted': posted,
    };
  }
}