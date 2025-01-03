class RecoveryFormModel{
  int? id;
  String? shopName;
  String? currentBalance;
  String? date;
  String? cashRecovery;
  String? newBalance;

  RecoveryFormModel({
    this.id,
    this.shopName,
    this.currentBalance,
    this.cashRecovery,
    this.newBalance,
    this.date,
  });

  factory RecoveryFormModel.fromMap(Map<dynamic,dynamic> json){
    return RecoveryFormModel(
      id: json['id'],
      shopName: json['shopName'],
      currentBalance: json['currentBalance'],
        cashRecovery: json['cashRecovery'],
        newBalance: json['newBalance'],
        date: json['date'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'shopName':shopName,
      'currentBalance':currentBalance,
      'cashRecovery':cashRecovery,
      'newBalance':newBalance,
      'date':date,

    };
  }
}