import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/return_form_model.dart';
import '../Repositories/return_form_repository.dart';

class ReturnFormViewModel extends GetxController {
  var allReturnForm = <ReturnFormModel>[].obs;
  var selectedShop = ''.obs;  // Ensure this is initialized as an RxString
  final List<String> shops = ["Shop 1", "Shop 2", "Shop 3", "Shop 4"];
  ReturnFormDetailsViewModel returnFormDetailsViewModel =Get.put(ReturnFormDetailsViewModel());
  ReturnFormRepository returnFormRepository = ReturnFormRepository();
  int returnFormSerialCounter = 1;
  String returnFormCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadCounter();
    fetchAllReturnForm();
  }

  Future<void> submitForm() async {
    bool isValid = true;

      if (selectedShop.value.isEmpty) {
        isValid = false;

    }
    if (isValid) {
      final returnFormSerial = generateNewOrderId(user_id);
      returnMasterId = returnFormSerial;
      await addReturnForm(ReturnFormModel(
        return_master_id: returnMasterId,
        select_shop: selectedShop.value,
      ));
      // fetchAllReturnForm();
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
    returnFormCurrentMonth =
        prefs.getString('returnFormCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (returnFormCurrentMonth != currentMonth) {
      returnFormSerialCounter = 1;
      returnFormCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      print('SR: $returnFormSerialCounter');
    }
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

    String orderId =
        "RF-$user_id-$currentMonth-${returnFormSerialCounter.toString().padLeft(3, '0')}";
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

  deleteReturnForm(int id) {
    returnFormRepository.delete(id);
    fetchAllReturnForm();
  }
}
