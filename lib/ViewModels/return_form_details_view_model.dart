
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/return_form_model.dart';
import '../Models/returnform_details_model.dart';
import '../Repositories/return_form_details_repository.dart';
class ReturnFormDetailsViewModel extends GetxController{

  var allReturnFormDetails = <ReturnFormDetailsModel>[].obs;
  ReturnFormDetailsRepository returnformdetailsRepository = ReturnFormDetailsRepository();
  int returnFormDetailsSerialCounter = 1;
  String returnFormDetailsCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  var items = <Item>[].obs;
  var reasons = <String>["Expire", "Business","Damage","Cancel"].obs;
  //var quantity = ''.obs;
  var formRows = <ReturnForm>[ReturnForm(quantity: '', reason: '', items: '')]
      .obs; // Initialize with one row

  void addRow() {
    formRows
        .add(ReturnForm(quantity: '', reason: '',items: '' ));
  }

  void removeRow(int index) {
    if (formRows.length > 1) {
      formRows.removeAt(index);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    fetchAllReturnFormDetails();
  }
  Future<void>submitForm() async {
    bool isValid = true;
    for (var row in formRows) {
      if (row.selectedItem == null || row.quantity.isEmpty || row.reason.isEmpty) {
        isValid = false;
        break;
      }
    }
    if (isValid) {
      for (var row in formRows) {
        await _loadCounter();
        final returnFormSerial = generateNewOrderId(user_id);
        await addReturnFormDetails(ReturnFormDetailsModel(
            return_details_id: returnFormSerial,
            item: row.selectedItem?.name,   // Use the selectedItem of the row
            reason: row.reason,   // Use the reason of the row
            quantity: row.quantity,
            user_id: user_id.toString(),
// Use the quantity of the row
            return_master_id: returnMasterId
        ));
        await returnformdetailsRepository.postDataFromDatabaseToAPI();
      }

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
    returnFormDetailsSerialCounter = (prefs.getInt('returnFormDetailsSerialCounter') ?? returnDetailsHighestSerial?? 1);
    returnFormDetailsCurrentMonth = prefs.getString('returnFormDetailsCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (returnFormDetailsCurrentMonth != currentMonth) {
      returnFormDetailsSerialCounter = 1;
      returnFormDetailsCurrentMonth = currentMonth;
    }

      debugPrint('returnFormDetailsSerialCounter: $returnFormDetailsSerialCounter');

  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('returnFormDetailsSerialCounter', returnFormDetailsSerialCounter);
    await prefs.setString('returnFormDetailsCurrentMonth', returnFormDetailsCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      returnFormDetailsSerialCounter = returnDetailsHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (returnFormDetailsCurrentMonth != currentMonth) {
      returnFormDetailsSerialCounter = 1;
      returnFormDetailsCurrentMonth = currentMonth;
    }

    String orderId = "RD-$user_id-$currentMonth-${returnFormDetailsSerialCounter.toString().padLeft(3, '0')}";
    returnFormDetailsSerialCounter++;
    _saveCounter();
    return orderId;
  }
  fetchAllReturnFormDetails() async{
    var returnformdetails = await returnformdetailsRepository.getReturnFormDetails();
    allReturnFormDetails.value = returnformdetails;
  }

  addReturnFormDetails(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.add(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  updateReturnFormDetails(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.update(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  deleteReturnFormDetails(int id){
    returnformdetailsRepository.delete(id);
    fetchAllReturnFormDetails();
  }
  serialCounterGet()async{
    await returnformdetailsRepository.serialNumberGeneratorApi();
  }
}