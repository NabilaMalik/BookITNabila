import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Repositories/ScreenRepositories/products_repository.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
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
  var phone_no = ''.obs;
  GlobalKey<FormState> get formKey => _formKey;
  final _formKey = GlobalKey<FormState>();

  int orderMasterSerialCounter = 1;
  String orderMasterCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentUserId = '';

  var credit_limit = ''.obs;
  var requiredDelivery = ''.obs;
  final List<String> credits = ['7 days', '15 days', 'On Cash'];
  @override
  void onInit() {
    super.onInit();
    fetchAllConfirmOrder();
    _loadCounter();
  }
  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    orderMasterSerialCounter = (prefs.getInt('orderMasterSerialCounter') ?? 1);
    orderMasterCurrentMonth = prefs.getString('orderMasterCurrentMonth') ?? currentMonth;
    currentUserId = prefs.getString('currentUserId') ?? '';

    if (orderMasterCurrentMonth != currentMonth) {
      orderMasterSerialCounter = 1;
      orderMasterCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      print('SR: $orderMasterSerialCounter');
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('orderMasterSerialCounter', orderMasterSerialCounter);
    await prefs.setString('orderMasterCurrentMonth', orderMasterCurrentMonth);
    await prefs.setString('currentUserId', currentUserId);
  }

  String generateNewOrderId(String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentUserId != userId) {
      orderMasterSerialCounter = 1;
      currentUserId = userId;
    }

    if (orderMasterCurrentMonth != currentMonth) {
      orderMasterSerialCounter = 1;
      orderMasterCurrentMonth = currentMonth;
    }

    String orderId = "OM-$userId-$currentMonth-${orderMasterSerialCounter.toString().padLeft(3, '0')}";
    return orderId; // Increment yahan nahi ho raha
  }

  Future<String> generateAndSaveOrderId(String userId) async {
    await _loadCounter(); // Load last saved value
    String orderId = generateNewOrderId(userId);

    // Increment aur save ka kaam yahan ho raha hai
    orderMasterSerialCounter++;
    await _saveCounter();
    return orderId;
  }


  Future<void> submitForm(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final orderSerial = generateNewOrderId(userId); // Sirf serial generate hoga
      order_master_id = orderSerial;
      print("Saving filtered products...");
      await orderDetailsViewModel.saveFilteredProducts();
    }
  }

  Future<void> confirmSubmitForm() async {

    // if (validateForm()) {
    if (shopVisitViewModel.selectedShop.value.isNotEmpty) {
      final orderSerial = await generateAndSaveOrderId(userId); // Generate aur save dono yahan
      order_master_id = orderSerial;
      OrderMasterModel orderMasterModel = OrderMasterModel(
          shop_name: shopVisitViewModel.selectedShop.value,
          owner_name: shopVisitViewModel.selectedBrand.value,
          phone_no: phone_no.value,
          brand: shopVisitViewModel.selectedBrand.value,
          total: orderDetailsViewModel.total.value.toString(),
          credit_limit: credit_limit.value,
          requiredDelivery: requiredDelivery.value,
          order_master_id: order_master_id
      );

      print("Submitting OrderMasterModel: ${orderMasterModel.toMap()}");
      await addConfirmOrder(orderMasterModel);

      print("Saving filtered products...");
      await orderDetailsViewModel.confirmFilteredProducts();

      print("Fetching all re-confirmed orders...");
      await orderDetailsViewModel.fetchAllReConfirmOrder();
    }
  }
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
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
