import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Repositories/order_details_repository.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Models/order_details_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';
import '../Screens/reconfirm_order_screen.dart';
import 'ProductsViewModel.dart';

class OrderDetailsViewModel extends GetxController {
  final ProductsRepository productsRepository = Get.put(ProductsRepository());
  final OrderDetailsRepository orderDetailsRepository =
      Get.put(OrderDetailsRepository());
  final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  var total = ''.obs;
  var allReConfirmOrder = <OrderDetailsModel>[].obs;
  var filteredRows = <Map<String, dynamic>>[].obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  int orderDetailsSerialCounter = 1;
  String orderDetailsCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  //
  @override
  void onInit() {
    super.onInit();
    fetchAllReConfirmOrder();
    initializeProductData();
  }
_loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    orderDetailsSerialCounter = (prefs.getInt('orderDetailsSerialCounter')?? orderDetailsHighestSerial ?? 1);
    orderDetailsCurrentMonth = prefs.getString('orderDetailsCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (orderDetailsCurrentMonth != currentMonth) {
      orderDetailsSerialCounter = 1;
      orderDetailsCurrentMonth = currentMonth;
    }

      debugPrint('orderDetailsSerialCounter: $orderDetailsSerialCounter');

  }

 _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('orderDetailsSerialCounter', orderDetailsSerialCounter);
    await prefs.setString('orderDetailsCurrentMonth', orderDetailsCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      orderDetailsSerialCounter = orderDetailsHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (orderDetailsCurrentMonth != currentMonth) {
      orderDetailsSerialCounter = 1;
      orderDetailsCurrentMonth = currentMonth;
    }

    String orderId = "OD-$user_id-$currentMonth-${orderDetailsSerialCounter.toString().padLeft(3, '0')}";
    orderDetailsSerialCounter++;
    _saveCounter();
    return orderId;
  }
  fetchAndSaveOrderDetails() async {
    await orderDetailsRepository.fetchAndSaveOrderDetails();
    await fetchAllReConfirmOrder();
  }

  initializeProductData() async {
    try {
      // Fetching products
      List<ProductsModel> products = productsViewModel.allProducts;

      // Ensure products are available
      if (products.isEmpty) {
        debugPrint("No products available");
        return;
      }

      final productData = products.map((product) {
        final quantity = num.tryParse(product.quantity?.toString() ?? '0') ?? 0;
        final in_stock = num.tryParse(product.in_stock.toString());
        final price = num.tryParse(product.price.toString()) ?? 0.0;
        return {
          'Product': product.product_name,
          'In Stock': in_stock,
          'Rate': price,
          'Amount': quantity * price,
          'Brand': product.brand,
          'Quantity': product.quantity, // Add quantity for filtering
        };
      }).toList();

      // debugPrint fetched product data
      // debugPrint("Fetched Product Data: $productData");

      // Filter by selected brand
      filteredRows.value = productData.where((row) {
        return row['Brand'].toString().toLowerCase() ==
            shopVisitViewModel.selectedBrand.value.toLowerCase();
      }).toList();

      // debugPrint filtered rows
      debugPrint("Filtered Rows After Initialization: ${filteredRows.value}");

      rowsNotifier.value = filteredRows.value; // Show only filtered products

      // Debugging output to verify the initialization
      filteredRows.forEach((row) {

          debugPrint(
              "Product: ${row['Product']}, In Stock: ${row['In Stock']}, Rate: ${row['Rate']}, Amount: ${row['Amount']}, Brand: ${row['Brand']}");

      });

      updateTotalAmount(); // Update total after initializing product data
    } catch (e) {

        debugPrint("Error initializing product data: $e");

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
    debugPrint("Running saveFilteredProducts...");
    final productsToSave = filteredRows.where((row) {
      final quantity = row['Enter Qty'];
      return quantity != null && quantity != 0;
    }).toList();

    // Check if there are any products to save
    if (productsToSave.isEmpty) {
      debugPrint("No products to save. Navigation not performed.");
      Get.snackbar(
        "Error",
        "No products to save. Please enter quantities.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return; // Do not navigate if no products to save
    }
    Get.to(() =>  ReconfirmOrderScreen(rows: productsToSave));
  }

  Future<void> confirmFilteredProducts() async {
    debugPrint("Running saveFilteredProducts...");
    final productsToSave = filteredRows.where((row) {
      final quantity = row['Enter Qty'];
      return quantity != null && quantity != 0;
    }).toList();

    // Check if there are any products to save
    if (productsToSave.isEmpty) {
      debugPrint("No products to save. Navigation not performed.");
      Get.snackbar(
        "Error",
        "No products to save. Please enter quantities.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return; // Do not navigate if no products to save
    }

    for (var product in productsToSave) {
      await orderDetailsSerial();
      await _loadCounter();
      dynamic orderSerial = await generateNewOrderId(user_id);
      final orderDetailsModel = OrderDetailsModel(
          order_details_id: orderSerial,
          rate: product['Rate'].toString(),
          in_stock: product['In Stock'].toString(),
          amount: product['Amount'].toString(),
          product: product['Product'],
          user_id: user_id.toString(),
          quantity: product['Enter Qty'].toString(),
          order_master_id: order_master_id
      );
      try {
        await addReConfirmOrder(orderDetailsModel);
        await orderDetailsRepository.postDataFromDatabaseToAPI();
        Get.snackbar(
          "Success",
          "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        debugPrint("Error saving OrderDetailsModel: $e");
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
  Future<void>orderDetailsSerial()async{
    await orderDetailsRepository.getHighestSerialNo();
  }
}
