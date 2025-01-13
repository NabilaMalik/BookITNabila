import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/Repositories/ScreenRepositories/products_repository.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import '../Databases/dp_helper.dart';
import '../Models/order_master_model.dart';
import '../Repositories/order_master_repository.dart';
import 'ProductsViewModel.dart';

class OrderMasterViewModel extends GetxController {
  DBHelper dbHelper = Get.put(DBHelper());
  final ImagePicker picker = ImagePicker();
  ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  var allOrderMaster = <OrderMasterModel>[].obs;
  ProductsRepository productsRepository = Get.put(ProductsRepository());
  ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
   OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  OrderMasterRepository orderMasterRepository = Get.put(OrderMasterRepository());
  var phoneNumber = ''.obs;
  var ownerName = ''.obs;
  var bookerName = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var creditLimit = ''.obs;
  var requiredDelivery = ''.obs;
  // var filteredRows = <Map<String, dynamic>>[].obs;
  // var rows = <DataRow>[].obs;
  // ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
  // ValueNotifier<List<Map<String, dynamic>>>([]);
  final List<String> credits = ['7 days', '15 days', 'On Cash'];
  final List<String> shops = ['Shop X', 'Shop Y', 'Shop Z'];

  @override
  void onInit() {
    super.onInit();
    fetchAllConfirmOrder();
  }

  Future<void> submitForm(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      OrderMasterModel orderMasterModel = OrderMasterModel(
          shopName: shopVisitViewModel.selectedShop.value,
          ownerName: shopVisitViewModel.selectedBrand.value,
          phoneNumber: phoneNumber.value,
          brand: shopVisitViewModel.selectedBrand.value,
          total: orderDetailsViewModel.total.value.toString(),
          creditLimit: creditLimit.value,
          requiredDelivery: requiredDelivery.value
      );

      print("Submitting OrderMasterModel: ${orderMasterModel.toMap()}");
      await orderMasterRepository.submitForm(orderMasterModel);

      print("Saving filtered products...");
      await orderDetailsViewModel.saveFilteredProducts();

      print("Fetching all re-confirmed orders...");
      await orderDetailsViewModel.fetchAllReConfirmOrder();

      Get.snackbar(
        "Success",
        "Form submitted successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  fetchAllConfirmOrder() async {
    var confirmorder = await orderMasterRepository.getConfirmOrder();
    allOrderMaster.value = confirmorder;
  }

  addConfirmOrder(OrderMasterModel orderMasterModel) {
    orderMasterRepository.add(orderMasterModel);
    fetchAllConfirmOrder();
  }

  updateConfirmOrder(OrderMasterModel orderMasterModel) {
    orderMasterRepository.update(orderMasterModel);
    fetchAllConfirmOrder();
  }

  deleteConfirmOrder(int id) {
    orderMasterRepository.delete(id);
    fetchAllConfirmOrder();
  }
}
