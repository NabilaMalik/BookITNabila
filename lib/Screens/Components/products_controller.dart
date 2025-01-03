import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Databases/util.dart';
import '../../ViewModels/ScreenViewModels/ProductsViewModel.dart';

class Products extends GetxController {
  final productsViewModel = ProductsViewModel();
  List<DataRow> rows = <DataRow>[].obs;  // Observable list of DataRow
  List<TextEditingController> controllers = [];  // List of controllers for text fields
  ValueNotifier<List<DataRow>> rowsNotifier = ValueNotifier<List<DataRow>>([]);  // Notifier for rows

  // Method to update rowsNotifier with new rows
  void updateRows(List<DataRow> newRows) {
    rowsNotifier.value = newRows;
  }

  // Method to fetch products based on selected brand
  Future<void> fetchProducts() async {
    await productsViewModel.fetchProductsByBrands(globalselectedbrand);
    var products = productsViewModel.allProducts;

    // Clear existing rows and controllers before adding new ones
    rows.clear();
    controllers.clear();

    for (var product in products) {
      var controller = TextEditingController(text: '0'); // Set default value to '0'
      controllers.add(controller);

      FocusNode focusNode = FocusNode();

      // Listener for focus changes
      focusNode.addListener(() {
        if (!focusNode.hasFocus && controller.text.isEmpty) {
          controller.text = '0'; // Restore '0' when losing focus and text is empty
        }
      });

      // Adding a text listener to handle clear on focus
      controller.addListener(() {
        if (focusNode.hasFocus && controller.text == '0') {
          controller.clear();
        }
      });

      rows.add(DataRow(cells: [
        DataCell(Text(product.product_name ?? '')),  // Display product name
        DataCell(TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          onTap: () {
            if (controller.text == '0') {
              controller.clear();
            }
          },
          onChanged: (value) {
            if (value == '0') {
              controller.clear();
            }
          },
        )),
      ]));
    }

    // Update rowsNotifier with the new rows
    updateRows(List<DataRow>.from(rows));
  }
}
