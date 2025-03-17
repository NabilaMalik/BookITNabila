import 'package:intl/intl.dart';

class OrderMasterModel{
  String? order_master_id;
  String? order_status;
  String? shop_name;
  String? owner_name;
  String? phone_no;
  String? brand;
  String? total;
  String? user_id;
  String? credit_limit;
  String? rsm_id;
  String? sm_id;
  String? nsm_id;
  String? rsm;
  String? sm;
  String? nsm;
  String? required_delivery_date;
  DateTime? order_master_date;
  DateTime? order_master_time;
  int posted;
  
  OrderMasterModel({
    this.order_master_id,
    this.shop_name,
    this.order_status,
    this.owner_name,
    this.phone_no,
    this.brand,
    this.user_id,
    this.total,
    this.credit_limit,
    this.rsm_id,
    this.sm_id,
    this.nsm_id,
    this.rsm,
    this.sm,
    this.nsm,
    this.required_delivery_date,
    this.order_master_date,
    this.order_master_time,
    this.posted = 0,
  });
  factory OrderMasterModel.fromMap(Map<dynamic,dynamic> json){
    return OrderMasterModel(
      order_master_id: json['order_master_id'],
      shop_name: json['shop_name'],
      owner_name: json['owner_name'],
      phone_no: json['phone_no'],
      order_status: json['order_status'],
      brand:json['brand'],
      user_id: json['user_id'],
      total:json['total'].toString(),
      credit_limit:json['credit_limit'],
      rsm_id:json['rsm_id'],
      sm_id:json['sm_id'],
      nsm_id:json['nsm_id'],
      rsm:json['rsm'],
      sm:json['sm'],
      nsm:json['nsm'],
      required_delivery_date:json['required_delivery_date'],
      order_master_date: DateTime.now(),
      // Always set live date
      order_master_time: DateTime.now(),
      posted: json['posted'] ?? 0,
      // Always set live time
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'order_master_id':order_master_id,
      'shop_name':shop_name,
      'owner_name':owner_name,
      'phone_no':phone_no,
      'brand':brand,
      'total':total,
      'user_id':user_id,
      'credit_limit':credit_limit,
      'order_status':order_status,
      'required_delivery_date':required_delivery_date,
      'rsm_id':rsm_id,
      'sm_id':sm_id,
      'nsm_id':nsm_id,
      'rsm':rsm,
      'sm':sm,
      'nsm':nsm,
      'order_master_date': DateFormat('dd-MMM-yyyy')
          .format(order_master_date ?? DateTime.now()), // Always set live date
      'order_master_time': DateFormat('HH:mm:ss')
          .format(order_master_time ?? DateTime.now()), // Always set live time
      'posted': posted,
    };
  }
}
