import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
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
  late ShopVisitViewModel shopVisitViewModel; // remove direct dependency here
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
    // Initialize shopVisitViewModel here after initial dependencies are ready
    shopVisitViewModel = Get.find<ShopVisitViewModel>();
    super.onInit();
    _initializeProductData();
    fetchAllShopVisitDetails();
  }

  Future<void> _initializeProductData() async {
    try {
      // // Fetch all products before accessing them
      // await productsViewModel.fetchAllProductsModel();

      List<ProductsModel> products =
          await productsRepository.getProductsModel();

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

  clearFilters() {
    _shopVisitDetails.value = ShopVisitDetailsModel();
    _formKey.currentState?.reset();
    filteredRows.clear(); // Clear the filtered rows
    rowsNotifier.value = []; // Clear the notifier
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

  saveFilteredProducts() async {
    final productsToSave = filteredRows.where((row) {
      final quantity = row['Quantity'];
      return quantity != null && quantity != 0;
    }).toList();

    for (var product in productsToSave) {
      final shopVisitDetailsModel = ShopVisitDetailsModel(
        product: product['Product'],
        quantity: product['Quantity'].toString(), // Convert quantity to string
        //shopVisitMasterId: /* Provide appropriate master ID */,
      );
      await shopvisitDetailsRepository.add(shopVisitDetailsModel);

      // Map the quantity to the ProductsModel here
      final products = productsViewModel.allProducts
          .where((p) => p.product_name == product['Product'])
          .toList();
      if (products.isNotEmpty) {
        products[0].inStock = product['Quantity'].toString();
        // Debugging print statement
        print("Updated ${products[0].product_name} quantity to: ${products[0].inStock}");
      }
    }

    // fetchAllShopVisitDetails(); // Refresh the data
   // await clearFilters();
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
