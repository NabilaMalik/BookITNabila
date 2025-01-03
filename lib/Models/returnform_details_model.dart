
import 'package:flutter/cupertino.dart';

class ReturnFormDetailsModel{
  int? id;
  String? item;
  String? qty;
  String? reason;
  int? returnMasterId;
  ReturnFormDetailsModel({
    this.id,
    this.item,
    this.qty,
    this.reason,
    this.returnMasterId,
  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormDetailsModel(
      id: json['id'],
      item: json['item'],
      qty: json['qty'],
      reason: json['reason'],
      returnMasterId: json['returnMasterId'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'item':item,
      'qty':qty,
      'reason':reason,
      'returnMasterId':returnMasterId,
    };
  }
}
