import 'package:intl/intl.dart';

class HeadsShopVisitModel {
  dynamic city;
  dynamic booker_id;
  String? shop_visit_heads_id;
  String? brand;
  String? user_id;
  String? shop_name;
  String? shop_address;
  DateTime? shop_visit_heads_date;
  DateTime? shop_visit_heads_time;
  String? booker_name;
  String? feedback;
  int posted;

  HeadsShopVisitModel(
      {this.shop_visit_heads_id,
      this.brand,
      this.user_id,
      this.shop_name,
      this.shop_address,
      this.booker_name,
      this.shop_visit_heads_date,
      this.shop_visit_heads_time,
      this.feedback,
      this.city,
      this.booker_id,
      this.posted=0});

  factory HeadsShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    return HeadsShopVisitModel(
      shop_visit_heads_id: json['shop_visit_heads_id'].toString(),
      brand: json['brand'].toString(),
      shop_name: json['shop_name'].toString(),
      shop_address: json['shop_address'].toString(),
      booker_name: json['booker_name'].toString(),
      user_id: json['user_id'].toString(),

      shop_visit_heads_date: DateTime.now(),
      // Always set live date
      shop_visit_heads_time: DateTime.now(),

      booker_id: json['booker_id'],

      city: json['city'],

      feedback: json['feedback'],
      posted: json['posted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shop_visit_heads_id': shop_visit_heads_id,
      'brand': brand,
      'shop_name': shop_name,
      'shop_address': shop_address,

      'booker_name': booker_name,
      'user_id': user_id,
      'feedback': feedback,
      'shop_visit_heads_date': DateFormat('dd-MMM-yyyy').format(
          shop_visit_heads_date ?? DateTime.now()), // Always set live date
      'shop_visit_heads_time': DateFormat('HH:mm:ss').format(
          shop_visit_heads_time ?? DateTime.now()), // Always set live time
      'booker_id': booker_id,

      'city': city,
      'posted': posted,
    };
  }
}
