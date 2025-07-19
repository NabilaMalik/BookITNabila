

class NsmSmOrderDetailsModel{
  String? order_master_id;
  String? order_status;
  String? shop_name;
  int? total;
  String? user_id;
  String? user_name;
  String? order_master_date;

  NsmSmOrderDetailsModel({
    this.order_master_id,
    this.shop_name,
    this.order_status,
    this.user_name,
    this.user_id,
    this.total,
    this.order_master_date,


  });
  factory NsmSmOrderDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return NsmSmOrderDetailsModel(
      order_master_id: json['order_master_id']??"",
      shop_name: json['shop_name']??"",
      order_status: json['order_status']??"",
      user_name: json['user_name']??"",

      user_id: json['user_id']??"",
      total: json['total'],
      order_master_date: json['order_master_date']??"",
      // Always set live date
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'order_master_id':order_master_id,
      'shop_name':shop_name,
      'order_status':order_status,
      'user_name':user_name,
      'user_id':user_id,
      'total':total,
      'order_master_date': order_master_date
    };
  }
}
