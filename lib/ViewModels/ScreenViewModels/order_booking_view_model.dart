import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OrderBookingViewModel extends GetxController {
  final ImagePicker picker = ImagePicker();

  var phoneNumber = ''.obs;
  var ownerName = ''.obs;
  var bookerName = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var creditLimit = ''.obs;
  var total = ''.obs;
  var requiredDelivery = ''.obs;
  var filteredRows = <Map<String, dynamic>>[].obs;

  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
  ValueNotifier<List<Map<String, dynamic>>>([]);
  final List<String>credits = ['7 days', '15 days', 'On Cash'];
  final List<String> shops = ['Shop X', 'Shop Y', 'Shop Z'];

  @override
  void onInit() {
    super.onInit();
    _initializeProductData();
  }

  void _initializeProductData() {
    final productData = [
      {'Product': 'Shampoo', 'Quantity': 20, 'In Stock': 100, 'Rate': 2.5, 'Amount': 50.0},
      {'Product': 'Soap', 'Quantity': 35, 'In Stock': 200, 'Rate': 1.0, 'Amount': 35.0},
      {'Product': 'Cookies', 'Quantity': 50, 'In Stock': 150, 'Rate': 0.5, 'Amount': 25.0},
      {'Product': 'Milk', 'Quantity': 15, 'In Stock': 80, 'Rate': 1.5, 'Amount': 22.5},
      {'Product': 'Shampoo', 'Quantity': 20, 'In Stock': 100, 'Rate': 2.5, 'Amount': 50.0},
      {'Product': 'Soap', 'Quantity': 35, 'In Stock': 200, 'Rate': 1.0, 'Amount': 35.0},
      {'Product': 'Cookies', 'Quantity': 50, 'In Stock': 150, 'Rate': 0.5, 'Amount': 25.0},
      {'Product': 'Milk', 'Quantity': 15, 'In Stock': 80, 'Rate': 1.5, 'Amount': 22.5},
    ];

    rowsNotifier.value = productData;
    filteredRows.value = productData;

    print("Initialized Product Data: $productData");
    updateTotal(); // Update total after initializing product data
  }

  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final tempList = rowsNotifier.value.where((row) {
      return row.values.any((value) =>
          value.toString().toLowerCase().contains(lowerCaseQuery));
    }).toList();
    filteredRows.value = tempList;
    updateTotal(); // Update total after filtering data
  }

  void submitForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      rowsNotifier.value = filteredRows.value;
      Get.snackbar(
        "Success",
        "Form submitted successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateTotal() {
    double totalAmount = 0;
    for (var row in filteredRows) {
      totalAmount += row['Amount'] ?? 0.0;
    }
    total.value = totalAmount.toStringAsFixed(2); // Update total with 2 decimal places
  }

  void _updateAmount(Map<String, dynamic> row) {
    final quantity = row['Quantity'] ?? 0;
    final rate = row['Rate'] ?? 0.0;
    final amount = quantity * rate;
    row['Amount'] = amount;
  }
}
