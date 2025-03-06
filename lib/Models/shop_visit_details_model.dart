import 'package:intl/intl.dart';

class ShopVisitDetailsModel {
  String? shop_visit_details_id;
  String? product;
  String? quantity;
  String? user_id;
  DateTime? shop_visit_details_date;
  DateTime? shop_visit_details_time;
  String? shop_visit_master_id;
  int posted;

  ShopVisitDetailsModel({
    this.shop_visit_details_id,
    this.product,
    this.quantity,
    this.user_id,
    this.shop_visit_details_date,
    this.shop_visit_details_time,
    this.shop_visit_master_id,
    this.posted = 0,
  });

  factory ShopVisitDetailsModel.fromMap(Map<dynamic, dynamic> json){
    return ShopVisitDetailsModel(
      shop_visit_details_id: json['shop_visit_details_id'],
      product: json['product'],
      quantity: json['quantity'],
      shop_visit_details_date: DateTime.now(),
      // Always set live date
      shop_visit_details_time: DateTime.now(),
      // Always set live time
      posted: json['posted'] ?? 0,

      user_id: json['user_id'],
      shop_visit_master_id: json['shop_visit_master_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shop_visit_details_id': shop_visit_details_id,
      'product': product,
      'quantity': quantity,
      'user_id': user_id,
      'posted': posted,
      'shop_visit_details_date': DateFormat('dd-MMM-yyyy')
          .format(shop_visit_details_date ?? DateTime.now()).toString(), // Always set live date
      'shop_visit_details_time': DateFormat('HH:mm:ss')
          .format(shop_visit_details_time ?? DateTime.now()).toString(), // Always set live time
      'shop_visit_master_id': shop_visit_master_id,

    };
  }
}