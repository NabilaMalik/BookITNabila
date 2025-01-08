import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/Databases/dp_helper.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Models/ScreenModels/products_model.dart';
import 'package:order_booking_app/Repositories/ScreenRepositories/products_repository.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import '../../Services/ApiServices/api_service.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class OrderBookingViewModel extends GetxController {
  DBHelper dbHelper = Get.put(DBHelper());
  ProductsRepository productsRepository = Get.put(ProductsRepository());
  final ImagePicker picker = ImagePicker();
  ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());

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
  final List<String> credits = ['7 days', '15 days', 'On Cash'];
  final List<String> shops = ['Shop X', 'Shop Y', 'Shop Z'];

  @override
  void onInit() {
    super.onInit();
    _initializeProductData();
  }

  Future<void> fetchAndSaveProducts() async {
    try {
      List<dynamic> data = await ApiService.getData(Config.getApiUrlProducts);
      var dbClient = await dbHelper.db;

      // Save data to database
      for (var item in data) {
        item['posted'] = 1; // Set posted to 1
        ProductsModel model = ProductsModel.fromMap(item);
        await dbClient.insert(productsTableName, model.toMap());
      }
    } catch (e) {
      print("Error fetching and saving products: $e");
    }
  }

  Future<void> _initializeProductData() async {
    try {
      List<ProductsModel> products = await productsRepository.getProductsModel();
      final productData = products.map((product) {
        final quantity = num.tryParse(product.quantity.toString()) ?? 0;
        final price = num.tryParse(product.price.toString()) ?? 0.0;
        return {
          'Product': product.product_name,
          // 'Enter Quantity': quantity,
          // 'In Stock': quantity,
          'Rate': price,
          'Amount': quantity * price,
          'Brand': product.brand
        };
      }).toList();

      // Filter by selected brand
      filteredRows.value = productData.where((row) {
        return row['Brand'].toString().toLowerCase() == shopVisitViewModel.selectedBrand.value.toLowerCase();
      }).toList();

      rowsNotifier.value = filteredRows.value; // Show only filtered products

      print("Initialized Product Data: $productData");
      updateTotal(); // Update total after initializing product data
    } catch (e) {
      print("Error initializing product data: $e");
    }
  }


  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final tempList = rowsNotifier.value.where((row) {
      final matchesBrand = row['Brand'].toString().toLowerCase() == shopVisitViewModel.selectedBrand.value.toLowerCase();
      final matchesQuery = row.values.any((value) =>
          value.toString().toLowerCase().contains(lowerCaseQuery));
      return matchesBrand && matchesQuery;
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
