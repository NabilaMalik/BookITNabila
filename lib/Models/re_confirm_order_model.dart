
class ReConfirmOrderModel{
  int? id;
  String? product;
  String? quantity;
  String? inStock;
  String? rate;
  String? amount;
  int? orderMasterId;

  ReConfirmOrderModel({
    this.id,
    this.product,
    this.quantity,
    this.inStock,
    this.rate,
    this.amount,
    this.orderMasterId
  });
  factory ReConfirmOrderModel.fromMap(Map<dynamic,dynamic> json){
    return ReConfirmOrderModel(
      id: json['id'],
      product: json['product'],
      quantity: json['quantity'],
      inStock: json['inStock'],
      rate:json['rate'],
      amount:json['amount'],
      orderMasterId: json['orderMasterId']

    );}
  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'product':product,
      'quantity':quantity,
      'inStock':inStock,
      'rate':rate,
      'amount':amount,
      'orderMasterId':orderMasterId,
    };
  }
}
