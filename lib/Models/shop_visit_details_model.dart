class ShopVisitDetailsModel {
  String? shopVisitDetailsId;
  String? product;
  String? quantity;
  String? shopVisitMasterId;

  ShopVisitDetailsModel({
    this.shopVisitDetailsId,
    this.product,
    this.quantity,
    this.shopVisitMasterId,
  });
  factory ShopVisitDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return ShopVisitDetailsModel(
      shopVisitDetailsId: json['shopVisitDetailsId'],
      product: json['product'],
      quantity: json['quantity'],
      shopVisitMasterId: json['shopVisitMasterId'],
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'shopVisitDetailsId':shopVisitDetailsId,
      'product':product,
      'quantity':quantity,
      'shopVisitMasterId':shopVisitMasterId,
    };
  }}