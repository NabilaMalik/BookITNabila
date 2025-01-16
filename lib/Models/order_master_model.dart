class OrderMasterModel{
  String? order_master_id;
  String? shop_name;
  String? owner_name;
  String? phone_no;
  String? brand;
  String? total;
  String? credit_limit;
  String? requiredDelivery;

  OrderMasterModel({
    this.order_master_id,
    this.shop_name,
    this.owner_name,
    this.phone_no,
    this.brand,
    this.total,
    this.credit_limit,
    this.requiredDelivery,
  });
  factory OrderMasterModel.fromMap(Map<dynamic,dynamic> json){
    return OrderMasterModel(
      order_master_id: json['order_master_id'],
      shop_name: json['shop_name'],
      owner_name: json['owner_name'],
      phone_no: json['phone_no'],
      brand:json['brand'],
      total:json['total'],
      credit_limit:json['credit_limit'],
      requiredDelivery:json['requiredDelivery'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'order_master_id':order_master_id,
      'shop_name':shop_name,
      'owner_name':owner_name,
      'phone_no':phone_no,
      'brand':brand,
      'total':total,
      'credit_limit':credit_limit,
      'requiredDelivery':requiredDelivery,
    };
  }

}
