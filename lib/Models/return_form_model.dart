class ReturnFormModel{
  int? return_master_id;
  String? select_shop;


  ReturnFormModel({
    this.return_master_id,
    this.select_shop,

  });

  factory ReturnFormModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormModel(
      return_master_id: json['return_master_id'],
      select_shop: json['select_shop'],

    );
  }

  Map<String, dynamic> toMap(){
    return{
      'return_master_id':return_master_id,
      'select_shop':select_shop,

    };
  }
}
