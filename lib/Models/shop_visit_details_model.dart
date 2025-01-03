class ShopVisitDetailsModel {
  int? id;
  String? product;
  String? quantity;
  int? shopVisitMasterId;

  ShopVisitDetailsModel({
    this.id,
    this.product,
    this.quantity,
    this.shopVisitMasterId,
  });
  factory ShopVisitDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return ShopVisitDetailsModel(
      id: json['id'],
      product: json['product'],
      quantity: json['quantity'],
      shopVisitMasterId: json['shopVisitMasterId'],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'product':product,
      'quantity':quantity,
      'shopVisitMasterId':shopVisitMasterId,
    };
  }}