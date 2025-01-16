class RecoveryFormModel{
  int? id;
  String? shop_name;
  String? current_balance;
  String? date;
  String? cash_recovery;
  String? new_balance;

  RecoveryFormModel({
    this.id,
    this.shop_name,
    this.current_balance,
    this.cash_recovery,
    this.new_balance,
    this.date,
  });

  factory RecoveryFormModel.fromMap(Map<dynamic,dynamic> json){
    return RecoveryFormModel(
      id: json['id'],
      shop_name: json['shop_name'],
      current_balance: json['current_balance'],
        cash_recovery: json['cash_recovery'],
        new_balance: json['new_balance'],
        date: json['date'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'shop_name':shop_name,
      'current_balance':current_balance,
      'cash_recovery':cash_recovery,
      'new_balance':new_balance,
      'date':date,

    };
  }
}