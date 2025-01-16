
import 'package:flutter/cupertino.dart';

class ReturnFormDetailsModel{
  int? id;
  String? item;
  String? qty;
  String? reason;
  int? return_master_id;
  ReturnFormDetailsModel({
    this.id,
    this.item,
    this.qty,
    this.reason,
    this.return_master_id,
  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormDetailsModel(
      id: json['id'],
      item: json['item'],
      qty: json['qty'],
      reason: json['reason'],
      return_master_id: json['return_master_id'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'item':item,
      'qty':qty,
      'reason':reason,
      'return_master_id':return_master_id,
    };
  }
}
