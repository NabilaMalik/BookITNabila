import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/ProductsViewModel.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import '../Databases/dp_helper.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Models/shop_visit_details_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';
import '../Repositories/shop_visit_details_repository.dart';

class ShopVisitDetailsViewModel extends GetxController {
  var allShopVisitDetails = <ShopVisitDetailsModel>[].obs;
  ShopVisitDetailsRepository shopvisitDetailsRepository =
      Get.put(ShopVisitDetailsRepository());
  ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  var filteredRows = <Map<String, dynamic>>[].obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  final _shopVisitDetails = ShopVisitDetailsModel().obs;
  ShopVisitDetailsModel get shopVisitDetails => _shopVisitDetails.value;
  DBHelper dbHelper = Get.put(DBHelper());
  GlobalKey<FormState> get formKey => _formKey;
  final _formKey = GlobalKey<FormState>();
  ProductsRepository productsRepository = Get.put(ProductsRepository());

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initializeProductData();
    fetchAllShopVisitDetails();
  }

  Future<void> _initializeProductData() async {
    try {
      // Fetch all products before accessing them
      await productsViewModel.fetchAllProductsModel();

      List<ProductsModel> products = productsViewModel.allProducts;

      final productData = products.map((product) {
        final quantity = num.tryParse(product.quantity.toString()) ?? 0;
        return {
          'Product': product.product_name,
          'Enter Quantity': quantity,
          'Brand': product.brand,
        };
      }).toList();

      rowsNotifier.value = productData;

      // Apply brand filter initially
      filterProductsByBrand(shopVisitViewModel.selectedBrand.value);

      print("Initialized Product Data: $productData");
    } catch (e) {
      print("Error initializing product data: $e");
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
  }

  void clearFilters() {
    _shopVisitDetails.value = ShopVisitDetailsModel();
    _formKey.currentState?.reset();
  }

  void filterProductsByBrand(String selectedBrand) {
    final filtered = rowsNotifier.value.where((product) {
      return product['Brand'].toString().toLowerCase() ==
          selectedBrand.toLowerCase();
    }).toList();
    filteredRows.value = filtered;
  }

  fetchAllShopVisitDetails() async {
    var shopvisitdetails =
        await shopvisitDetailsRepository.getShopVisitDetails();
    allShopVisitDetails.value = shopvisitdetails;
  }
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
  // Method to save all shop visit details
  Future<void> saveAllShopVisitDetails() async {
    for (var detail in allShopVisitDetails) {
      await shopvisitDetailsRepository.add(detail);
    }
  }
  void addOrUpdateShopVisitDetails(Map<String, dynamic> row) {
    // Create a ShopVisitDetailsModel object from the row data
  addShopVisitDetails(ShopVisitDetailsModel(
    // id: ,
      product: row['Product'],
      quantity: row['Enter Quantity'],
    // shopVisitMasterId: ,
  ));

    // Check if the product already exists in the shop visit details
    int existingIndex = allShopVisitDetails.indexWhere((detail) => detail.product == shopVisitDetails.product);

    if (existingIndex >= 0 && existingIndex != isNullOrBlank) {
      // If it exists, update it
      allShopVisitDetails[existingIndex] = shopVisitDetails;
      updateShopVisitDetails(shopVisitDetails);
    } else {
      // If it does not exist, add it
      addShopVisitDetails(shopVisitDetails);
    }
  }


  addShopVisitDetails(ShopVisitDetailsModel shopvisitdetailsModel) {
    shopvisitDetailsRepository.add(shopvisitdetailsModel);
    fetchAllShopVisitDetails();
  }

  updateShopVisitDetails(ShopVisitDetailsModel shopvisitdetailsModel) {
    shopvisitDetailsRepository.update(shopvisitdetailsModel);
    fetchAllShopVisitDetails();
  }

  deleteShopVisitDetails(int id) {
    shopvisitDetailsRepository.delete(id);
    fetchAllShopVisitDetails();
  }
}
