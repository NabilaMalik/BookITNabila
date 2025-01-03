class Shop {
  final String name;
  final double currentBalance;

  Shop({required this.name, required this.currentBalance});
}


class PaymentHistory {
  final String date;
  final double amount;
  final String shop;

  PaymentHistory(
      {required this.date, required this.amount, required this.shop});
}
