// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../Models/ScreenModels/recovery_form_models.dart';
//
// class RecoveryFormViewModel extends GetxController {
//   var selectedShop = ''.obs;
//   var shops = <Shop>[].obs;
//   var paymentHistory = <PaymentHistory>[].obs;
//   var filteredRows = <PaymentHistory>[].obs;
//   var current_balance = 0.0.obs; // Current balance of selected shop
//   var cash_recovery = 0.0.obs; // Amount entered by the user for recovery
//   var net_balance = 0.0.obs; // Updated balance after cash recovery
//   var areFieldsEnabled = false.obs; // Add this line
//
//   final TextEditingController startDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeData();
//   }
//
//   void _initializeData() {
//     // Initialize shops
//     shops.value = [
//       Shop(name: "Shop 1", current_balance: 1000.0),
//       Shop(name: "Shop 2", current_balance: 2000.0),
//       Shop(name: "Shop 3", current_balance: 3000.0),
//       Shop(name: "Shop 4", current_balance: 4000.0),
//     ];
//
//     // Initialize payment history
//     paymentHistory.value = [
//       PaymentHistory(date: '2024-12-01', shop: 'Shop 1', amount: 100),
//       PaymentHistory(date: '2024-12-05', shop: 'Shop 2', amount: 50),
//       PaymentHistory(date: '2024-12-10', shop: 'Shop 3', amount: 200),
//     ];
//
//     filteredRows.value = paymentHistory.value;
//   }
//
//   void filterData(String query) {
//     final lowerCaseQuery = query.toLowerCase();
//
//     // Check if any shop is selected
//     if (selectedShop.value.isNotEmpty) {
//       // Filter data based on selected shop
//       filteredRows.value = paymentHistory.value.where((row) {
//         return row.shop == selectedShop.value &&
//             (row.date.toLowerCase().contains(lowerCaseQuery) ||
//                 row.shop.toLowerCase().contains(lowerCaseQuery) ||
//                 row.amount.toString().contains(lowerCaseQuery));
//       }).toList();
//     } else {
//       // Filter data from all data
//       filteredRows.value = paymentHistory.value.where((row) {
//         return row.date.toLowerCase().contains(lowerCaseQuery) ||
//             row.shop.toLowerCase().contains(lowerCaseQuery) ||
//             row.amount.toString().contains(lowerCaseQuery);
//       }).toList();
//     }
//   }
//
//
//   void updatecurrent_balance(String shop_name) {
//     final selectedShop = shops.firstWhere((shop) => shop.name == shop_name);
//     current_balance.value = selectedShop.current_balance;
//     net_balance.value = selectedShop.current_balance - cash_recovery.value;
//     areFieldsEnabled.value = true;
//
//     // Filter payment history based on selected shop
//     filteredRows.value = paymentHistory.value.where((payment) {
//       return payment.shop == shop_name;
//     }).toList();
//   }
//
//   void updatecash_recovery(String value) {
//     final recoveryAmount = double.tryParse(value) ?? 0.0;
//     if (recoveryAmount <= current_balance.value) {
//       cash_recovery.value = recoveryAmount;
//       net_balance.value = current_balance.value - cash_recovery.value;
//     } else {
//       // Handle invalid input
//       Get.snackbar(
//           "Error", "Recovery amount cannot be more than current balance!");
//     }
//   }
//
//   List<Map<String, dynamic>> get paymentHistoryAsMapList {
//     return paymentHistory.value.map((payment) {
//       return {
//         'Date': payment.date,
//         'Amount': payment.amount,
//         'Shop': payment.shop,
//       };
//     }).toList();
//   }
//
//   void submitForm() {
//     addRecoveryForm(RecoveryFormModel(
//       shopName: selectedShop.value,
//       currentBalance: currentBalance.value,
//       cashRecovery: cashRecovery.value,
//       newBalance: newBalance.value,
//     ));
//     // Implement your form submission logic here
//     Get.snackbar("Success", "Form submitted successfully!");
//   }