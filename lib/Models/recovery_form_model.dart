import 'package:intl/intl.dart';

class RecoveryFormModel{
  String? recovery_id;
  String? shop_name;
  dynamic? current_balance;
  String? date;  dynamic? cash_recovery;
  dynamic? net_balance;
  DateTime? recovery_date;
  DateTime? recovery_time;

  RecoveryFormModel({
    this.recovery_id,
    this.shop_name,
    this.current_balance,
    this.cash_recovery,
    this.net_balance,
    this.date,
    this.recovery_date,
    this.recovery_time,
  });

  factory RecoveryFormModel.fromMap(Map<dynamic,dynamic> json){
    return RecoveryFormModel(
      recovery_id: json['recovery_id'],
      shop_name: json['shop_name'],
      current_balance: json['current_balance'],
        cash_recovery: json['cash_recovery'],
        net_balance: json['net_balance'],
      recovery_date: DateTime.now(),
      // Always set live date
      recovery_time: DateTime.now(),
      // Always set live time
      
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'recovery_id':recovery_id,
      'shop_name':shop_name,
      'current_balance':current_balance,
      'cash_recovery':cash_recovery,
      'net_balance':net_balance,

      'recovery_date': DateFormat('dd-MMM-yyyy')
          .format(recovery_date ?? DateTime.now()), // Always set live date
      'recovery_time': DateFormat('HH:mm:ss')
          .format(recovery_time ?? DateTime.now()), // Always set live time


    };
  }
}