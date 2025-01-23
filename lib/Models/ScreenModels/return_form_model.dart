class Item {
  String name;
  Item(this.name);
}

class ReturnForm {
  Item? selectedItem;
  String quantity;
  String reason;
  String items;

  ReturnForm(
      {this.selectedItem,
      required this.quantity,
      required this.reason,
      required this.items});
}
