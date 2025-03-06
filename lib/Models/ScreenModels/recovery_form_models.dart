class Shop {
  final String name;
  final double? current_balance;

  Shop({required this.name, this.current_balance});
}


class PaymentHistory {
  final String date;
  final double amount;
  final String shop;

  PaymentHistory(
      {required this.date, required this.amount, required this.shop});
}
