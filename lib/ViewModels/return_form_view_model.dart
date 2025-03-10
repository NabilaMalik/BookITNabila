import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/recovery_form_models.dart';
import '../Models/order_master_model.dart';
import '../Models/return_form_model.dart';
import '../Repositories/return_form_repository.dart';
import 'order_details_view_model.dart';
import 'order_master_view_model.dart';

class ReturnFormViewModel extends GetxController {
  var allReturnForm = <ReturnFormModel>[].obs;
  var selectedShop = ''.obs;
  var shops = <Shop>[].obs;
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  ReturnFormDetailsViewModel returnFormDetailsViewModel = Get.put(ReturnFormDetailsViewModel());
  ReturnFormRepository returnFormRepository = ReturnFormRepository();
  int returnFormSerialCounter = 1;
  String returnFormCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  void onInit() {
    super.onInit();

    fetchAllReturnForm();
    initializeData();
    orderMasterViewModel.fetchAllOrderMaster();
    orderDetailsViewModel.fetchAllReConfirmOrder();
  }

  Future<void> initializeData() async {
    await Future.delayed(Duration.zero);

    Map<String, double> shopBalances = {};

    List<OrderMasterModel> dispatchedOrders = orderMasterViewModel.allOrderMaster
        .where((order) => order.order_status == "DISPATCHED")
        .toList();

    for (var order in dispatchedOrders) {
      String shopName = order.shop_name ?? "Unknown Shop";
      double orderAmount = double.tryParse(order.total ?? '0') ?? 0.0;

      shopBalances[shopName] = (shopBalances[shopName] ?? 0.0) + orderAmount;
    }

    shops.value = shopBalances.entries.map((entry) {
      return Shop(
        name: entry.key,
      );
    }).toList();

    shops.refresh();
  }

  Future<void> submitForm() async {
    bool isValid = true;

    if (selectedShop.value.isEmpty) {
      isValid = false;
    }

    if (isValid) {
      await _loadCounter();
      final returnFormSerial = generateNewOrderId(user_id);
      returnMasterId = returnFormSerial;
      await addReturnForm(ReturnFormModel(
        return_master_id: returnMasterId,
        select_shop: selectedShop.value,
        user_id: user_id,
        // return_amount:
      ));
      await returnFormDetailsViewModel.submitForm();
      await returnFormDetailsViewModel.fetchAllReturnFormDetails();
      await returnFormRepository.postDataFromDatabaseToAPI();
      Get.snackbar("Success", "Form Submitted!",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error", "Please fill all fields before submitting.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    returnFormSerialCounter = (prefs.getInt('returnFormSerialCounter') ?? 1);
    returnFormCurrentMonth = prefs.getString('returnFormCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (returnFormCurrentMonth != currentMonth) {
      returnFormSerialCounter = 1;
      returnFormCurrentMonth = currentMonth;
    }

      debugPrint('SR: $returnFormSerialCounter');

  }


  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('returnFormSerialCounter', returnFormSerialCounter);
    await prefs.setString('returnFormCurrentMonth', returnFormCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      returnFormSerialCounter = 1;
      currentuser_id = user_id;
    }

    if (returnFormCurrentMonth != currentMonth) {
      returnFormSerialCounter = 1;
      returnFormCurrentMonth = currentMonth;
    }

    String orderId = "RF-$user_id-$currentMonth-${returnFormSerialCounter.toString().padLeft(3, '0')}";
    returnFormSerialCounter++;
    _saveCounter();
    return orderId;
  }

  fetchAllReturnForm() async {
    var returnform = await returnFormRepository.getReturnForm();
    allReturnForm.value = returnform;
  }

  addReturnForm(ReturnFormModel returnFormModel) {
    returnFormRepository.add(returnFormModel);
    fetchAllReturnForm();
  }

  updateReturnForm(ReturnFormModel returnFormModel) {
    returnFormRepository.update(returnFormModel);
    fetchAllReturnForm();
  }

  deleteReturnForm(String id) {
    returnFormRepository.delete(id);
    fetchAllReturnForm();
  }
}