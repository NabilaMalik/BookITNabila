import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/order_details_repository.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Models/order_details_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';
import 'ProductsViewModel.dart';

class OrderDetailsViewModel extends GetxController {
  final ProductsRepository productsRepository = Get.put(ProductsRepository());
  final OrderDetailsRepository orderDetailsRepository = Get.put(OrderDetailsRepository());
  final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  // final OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  var total = ''.obs;
  var allReConfirmOrder = <OrderDetailsModel>[].obs;
  var filteredRows = <Map<String, dynamic>>[].obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  @override
  void onInit() {
    super.onInit();
    fetchAllReConfirmOrder();
    _initializeProductData();
  }

  Future<void> _initializeProductData() async {
    try {
      // Fetching products
      List<ProductsModel> products = productsViewModel.allProducts;

      // Ensure products are available
      if (products.isEmpty) {
        print("No products available");
        return;
      }

      final productData = products.map((product) {
        final quantity = num.tryParse(product.quantity?.toString() ?? '0') ?? 0;
        final inStock = num.tryParse(product.inStock.toString());
        final price = num.tryParse(product.price.toString()) ?? 0.0;
        return {
          'Product': product.product_name,
          'In Stock': inStock,
          'Rate': price,
          'Amount': quantity * price,
          'Brand': product.brand,
          'Quantity': product.quantity, // Add quantity for filtering
        };
      }).toList();

      // Print fetched product data
      print("Fetched Product Data: $productData");

      // Filter by selected brand
      filteredRows.value = productData.where((row) {
        return row['Brand'].toString().toLowerCase() ==
            shopVisitViewModel.selectedBrand.value.toLowerCase();
      }).toList();

      // Print filtered rows
      print("Filtered Rows After Initialization: ${filteredRows.value}");

      rowsNotifier.value = filteredRows.value; // Show only filtered products

      // Debugging output to verify the initialization
      filteredRows.forEach((row) {
        if (kDebugMode) {
          print("Product: ${row['Product']}, In Stock: ${row['In Stock']}, Rate: ${row['Rate']}, Amount: ${row['Amount']}, Brand: ${row['Brand']}");
        }
      });

      updateTotalAmount(); // Update total after initializing product data
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing product data: $e");
      }
    }
  }

  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final tempList = rowsNotifier.value.where((row) {
      final matchesBrand = row['Brand'].toString().toLowerCase() ==
          shopVisitViewModel.selectedBrand.value.toLowerCase();
      final matchesQuery = row.values.any(
              (value) => value.toString().toLowerCase().contains(lowerCaseQuery));
      return matchesBrand && matchesQuery;
    }).toList();
    filteredRows.value = tempList;
    updateTotalAmount();
  }

  void updateTotalAmount() {
    double totalAmount = 0;
    for (var row in filteredRows) {
      totalAmount += row['Amount'] ?? 0.0;
    }
    total.value = totalAmount.toStringAsFixed(2);
  }


  Future<void> saveFilteredProducts() async {

    print("Running saveFilteredProducts...");
    final productsToSave = filteredRows.where((row) {
      final quantity = row['Enter Qty'];
      // final quantity = row['Quantity'];
      return quantity != null && quantity != 0;
    }).toList();

    for (var product in productsToSave) {
      final orderDetailsModel = OrderDetailsModel(
        rate: product['Rate'].toString(),
        inStock: product['In Stock'].toString(),
        amount: product['Amount'].toString(),
        product: product['Product'],
        quantity: product['Enter Qty'].toString(),
      );
     // print("Saving OrderDetailsModel in saveFilteredProducts: ${orderDetailsModel.toMap()}");

      try {

        await orderDetailsRepository.add(orderDetailsModel);
      } catch (e) {
        print("Error saving OrderDetailsModel: $e");
      }
    }
  }


  Future<void> fetchAllReConfirmOrder() async {
    var reconfirmorder = await orderDetailsRepository.getReConfirmOrder();
    allReConfirmOrder.value = reconfirmorder;
  }

addReConfirmOrder(OrderDetailsModel reconfirmorderModel) {
    orderDetailsRepository.add(reconfirmorderModel);
    fetchAllReConfirmOrder();
  }

  void updateReConfirmOrder(OrderDetailsModel reconfirmorderModel) {
    orderDetailsRepository.update(reconfirmorderModel);
    fetchAllReConfirmOrder();
  }

  void deleteReConfirmOrder(int id) {
    orderDetailsRepository.delete(id);
    fetchAllReConfirmOrder();
  }
}

