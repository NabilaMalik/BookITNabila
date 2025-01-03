class ReturnFormModel{
  int? returnMasterId;
  String? selectShop;


  ReturnFormModel({
    this.returnMasterId,
    this.selectShop,

  });

  factory ReturnFormModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormModel(
      returnMasterId: json['returnMasterId'],
      selectShop: json['selectShop'],

    );
  }

  Map<String, dynamic> toMap(){
    return{
      'returnMasterId':returnMasterId,
      'selectShop':selectShop,

    };
  }
}
