// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../Models/ScreenModels/return_form_model.dart';
//
// class ReturnFormViewModel extends GetxController {
//   final List<String> shops = ["Shop 1", "Shop 2", "Shop 3", "Shop 4"];
//   var selectedShop = ''.obs;  // Ensure this is initialized as an RxString
//   var items = <Item>[Item('Item 1'), Item('Item 2'), Item('Item 3')].obs;
//   var reasons = <String>["Reason 1", "Reason 2", "Reason 3"].obs;
//
//   var formRows = <ReturnForm>[
//     ReturnForm(quantity: '', reason: '', shop: '')
//   ].obs; // Initialize with one row
//
//   void addRow() {
//     formRows.add(ReturnForm(quantity: '', reason: '', shop: selectedShop.value));
//   }
//
//   void removeRow(int index) {
//     if (formRows.length > 1) {
//       formRows.removeAt(index);
//     }
//   }
//
//   void submitForm() {
//     bool isValid = true;
//     for (var row in formRows) {
//       if (row.selectedItem == null || row.quantity.isEmpty || row.reason.isEmpty || selectedShop.value.isEmpty) {
//         isValid = false;
//         break;
//       }
//     }
//     if (isValid) {
//       Get.snackbar("Success", "Form Submitted!", snackPosition: SnackPosition.BOTTOM);
//     } else {
//       Get.snackbar("Error", "Please fill all fields before submitting.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }
// }
