class ProductsModel {
  int? id;
  dynamic product_code;
  String? product_name;
  String? uom;
  dynamic price;
  String? brand;
  String? quantity; // Existing quantity field
  String? in_stock;  // New in_stock field

  ProductsModel({
    this.id,
    this.product_code,
    this.product_name,
    this.uom,
    this.price,
    this.brand,
    this.quantity,
    this.in_stock,  // Initialize in_stock
  });

  // Create a factory constructor to create a Product instance from a map
  factory ProductsModel.fromMap(Map<dynamic, dynamic> json) {
    return ProductsModel(
      id: json['id'],
      product_code: json['product_code'],
      product_name: json['product_name'],
      uom: json['uom'],
      price: json['price'],
      brand: json['brand'],
      quantity: json['quantity'],
      in_stock: json['in_stock'],  // Map in_stock
    );
  }

  // Create a method to convert a Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_code': product_code,
      'product_name': product_name,
      'uom': uom,
      'price': price,
      'brand': brand,
      'quantity': quantity,
      'in_stock': in_stock,  // Convert in_stock to map
    };
  }
}
