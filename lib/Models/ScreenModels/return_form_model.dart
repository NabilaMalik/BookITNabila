class Item {
  final String name;
  final double rate;
  final double maxQuantity;

  Item(this.name, {this.rate = 0.0, this.maxQuantity = 0.0});
}
class ReturnForm {
  String quantity;
  String reason;
  String items;
  Item? selectedItem;
  double? rate;  // New field
  double? maxQuantity; // New field

  ReturnForm({
    required this.quantity,
    required this.reason,
    required this.items,
    this.selectedItem,
    this.rate,
    this.maxQuantity,
  });
}
