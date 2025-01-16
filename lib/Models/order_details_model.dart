
class OrderDetailsModel{
  String? order_details_id;
  String? product;
  String? quantity;
  String? in_stock;
  String? rate;
  String? amount;
  String? order_master_id;

  OrderDetailsModel({
    this.order_details_id,
    this.product,
    this.quantity,
    this.in_stock,
    this.rate,
    this.amount,
    this.order_master_id
  });
  factory OrderDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return OrderDetailsModel(
      order_details_id: json['order_details_id'],
      product: json['product'],
      quantity: json['quantity'],
      in_stock: json['in_stock'],
      rate:json['rate'],
      amount:json['amount'],
      order_master_id: json['order_master_id']

    );}
  Map<String, dynamic> toMap(){
    return{
      'order_details_id':order_details_id,
      'product':product,
      'quantity':quantity,
      'in_stock':in_stock,
      'rate':rate,
      'amount':amount,
      'order_master_id':order_master_id,
    };
  }
}
