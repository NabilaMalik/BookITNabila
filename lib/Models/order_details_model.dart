
class OrderDetailsModel{
  String? orderDetailsId;
  String? product;
  String? quantity;
  String? inStock;
  String? rate;
  String? amount;
  String? orderMasterId;

  OrderDetailsModel({
    this.orderDetailsId,
    this.product,
    this.quantity,
    this.inStock,
    this.rate,
    this.amount,
    this.orderMasterId
  });
  factory OrderDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return OrderDetailsModel(
      orderDetailsId: json['orderDetailsId'],
      product: json['product'],
      quantity: json['quantity'],
      inStock: json['inStock'],
      rate:json['rate'],
      amount:json['amount'],
      orderMasterId: json['orderMasterId']

    );}
  Map<String, dynamic> toMap(){
    return{
      'orderDetailsId':orderDetailsId,
      'product':product,
      'quantity':quantity,
      'inStock':inStock,
      'rate':rate,
      'amount':amount,
      'orderMasterId':orderMasterId,
    };
  }
}
