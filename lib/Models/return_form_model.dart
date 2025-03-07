import 'package:intl/intl.dart';

class ReturnFormModel{
  String? return_master_id;
  String? select_shop;
String? return_amount;
  DateTime? return_master_date;
  DateTime? return_master_time;
  String? user_id;
  int posted;
  ReturnFormModel({
    this.return_master_id,
    this.select_shop,
    this.return_amount,
    this.user_id,
    this.return_master_date,
    this.return_master_time,
    this.posted = 0,
  });

  factory ReturnFormModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormModel(
      return_master_id: json['return_master_id'],
      select_shop: json['select_shop'],
      user_id: json['user_id'],
      return_amount: json['return_amount'],
      return_master_date: DateTime.now(),
      // Always set live date
      return_master_time: DateTime.now(),
      // Always set live time
      posted: json['posted'] ?? 0,

    );
  }

  Map<String, dynamic> toMap(){
    return{
      'return_master_id':return_master_id,
      'select_shop':select_shop,
      'user_id':user_id,
      'return_amount':return_amount,
      'return_master_date': DateFormat('dd-MMM-yyyy')
          .format(return_master_date ?? DateTime.now()), // Always set live date
      'return_master_time': DateFormat('HH:mm:ss')
          .format(return_master_time ?? DateTime.now()), // Always set live time
      'posted': posted,
    };
  }
}
