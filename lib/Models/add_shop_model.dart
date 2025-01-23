import 'package:intl/intl.dart';

class AddShopModel {
  String? shop_id;
  String? shop_name;
  String? city;
  String? shop_address;
  String? owner_name;
  String? owner_cnic;
  String? phone_no;
  String? alternative_phone_no;
  bool isGPSEnabled;
  DateTime? shop_date;
  DateTime? shop_time;
  int posted;
  String? user_id;

  AddShopModel(
      {this.shop_id,
      this.shop_name,
      this.city,
      this.shop_address,
      this.owner_name,
      this.owner_cnic,
      this.phone_no,
      this.alternative_phone_no,
      this.isGPSEnabled = false,
      this.shop_date,
      this.shop_time,
      this.posted = 0,
      this.user_id});

  factory AddShopModel.fromMap(Map<dynamic, dynamic> json) {
    return AddShopModel(
      shop_id: json['shop_id'],
      shop_name: json['shop_name'],
      city: json['city'],
      shop_address: json['shop_address'],
      owner_name: json['owner_name'],
      owner_cnic: json['owner_cnic'],
      phone_no: json['phone_no'],
      alternative_phone_no: json['alternative_phone_no'],
      posted: json['posted'] ?? 0,
      shop_date: DateTime.now(),
      // Always set live date
      shop_time: DateTime.now(),
      // Always set live time
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shop_id': shop_id,
      'shop_name': shop_name,
      'city': city,
      'shop_address': shop_address,
      'owner_name': owner_name,
      'owner_cnic': owner_cnic,
      'phone_no': phone_no,
      'alternative_phone_no': alternative_phone_no,
      'posted': posted,
      'shop_date': DateFormat('dd-MMM-yyyy')
          .format(shop_date ?? DateTime.now()), // Always set live date
      'shop_time': DateFormat('HH:mm:ss')
          .format(shop_time ?? DateTime.now()), // Always set live time
      'user_id': user_id,
    };
  }
}
