
import 'package:intl/intl.dart';

class OrderDetailsModel{
  String? order_details_id;
  String? product;
  String? quantity;
  String? in_stock;
  String? rate;
  String? amount;
  String? order_master_id;
  DateTime? order_details_date;
  DateTime? order_details_time;
  int posted;
  OrderDetailsModel({
    this.order_details_id,
    this.product,
    this.quantity,
    this.in_stock,
    this.rate,
    this.amount,
    this.order_details_date,
    this.order_details_time,
    this.posted = 0,
    this.order_master_id
  });
  factory OrderDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return OrderDetailsModel(
      order_details_id: json['order_details_id'],
      product: json['product'],
      quantity: json['quantity'],
      in_stock: json['in_stock'],
      rate:json['rate'],
      amount:json['amount'],
        order_details_date: DateTime.now(),
        // Always set live date
        order_details_time: DateTime.now(),
        posted: json['posted'] ?? 0,
        // Always set live time
      order_master_id: json['order_master_id']

    );}
  Map<String, dynamic> toMap(){
    return{
      'order_details_id':order_details_id,
      'product':product,
      'quantity':quantity,
      'in_stock':in_stock,
      'rate':rate,
      'amount':amount,
      'posted': posted,
      'order_details_date': DateFormat('dd-MMM-yyyy').format(order_details_date ?? DateTime.now()), // Always set live date
      'order_details_time': DateFormat('HH:mm:ss').format(order_details_time ?? DateTime.now()), // Always set live time
      'order_master_id':order_master_id,
    };
  }
}
