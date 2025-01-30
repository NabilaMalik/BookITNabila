
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Models/returnform_details_model.dart';
import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/recovery_form_models.dart';
import '../Models/recovery_form_model.dart';
import '../Repositories/recovery_form_repository.dart';

class RecoveryFormViewModel extends GetxController{
  var selectedShop = ''.obs;
  var shops = <Shop>[].obs;
  var paymentHistory = <PaymentHistory>[].obs;
  var filteredRows = <PaymentHistory>[].obs;
  var current_balance = 0.0.obs; // Current balance of selected shop
  var cash_recovery = 0.0.obs; // Amount entered by the user for recovery
  var net_balance = 0.0.obs; // Updated balance after cash recovery
  var areFieldsEnabled = false.obs; // Add this line
  var allRecoveryForm = <RecoveryFormModel>[].obs;
  RecoveryFormRepository recoveryformRepository = RecoveryFormRepository();
  int recoverySerialCounter = 1;
  String recoveryCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _loadCounter();
    fetchAllRecoveryForm();
  }

  void _initializeData() {
    // Initialize shops
    shops.value = [
      Shop(name: "Shop 1", current_balance: 1000.0),
      Shop(name: "Shop 2", current_balance: 2000.0),
      Shop(name: "Shop 3", current_balance: 3000.0),
      Shop(name: "Shop 4", current_balance: 4000.0),
    ];

    // Initialize payment history
    paymentHistory.value = [
      PaymentHistory(date: '2024-12-01', shop: 'Shop 1', amount: 100),
      PaymentHistory(date: '2024-12-05', shop: 'Shop 2', amount: 50),
      PaymentHistory(date: '2024-12-10', shop: 'Shop 3', amount: 200),
    ];

    filteredRows.value = paymentHistory.value;
  }

  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();

    // Check if any shop is selected
    if (selectedShop.value.isNotEmpty) {
      // Filter data based on selected shop
      filteredRows.value = paymentHistory.value.where((row) {
        return row.shop == selectedShop.value &&
            (row.date.toLowerCase().contains(lowerCaseQuery) ||
                row.shop.toLowerCase().contains(lowerCaseQuery) ||
                row.amount.toString().contains(lowerCaseQuery));
      }).toList();
    } else {
      // Filter data from all data
      filteredRows.value = paymentHistory.value.where((row) {
        return row.date.toLowerCase().contains(lowerCaseQuery) ||
            row.shop.toLowerCase().contains(lowerCaseQuery) ||
            row.amount.toString().contains(lowerCaseQuery);
      }).toList();
    }
  }


  void updatecurrent_balance(String shop_name) {
    final selectedShop = shops.firstWhere((shop) => shop.name == shop_name);
    current_balance.value = selectedShop.current_balance;
    net_balance.value = selectedShop.current_balance - cash_recovery.value;
    areFieldsEnabled.value = true;

    // Filter payment history based on selected shop
    filteredRows.value = paymentHistory.value.where((payment) {
      return payment.shop == shop_name;
    }).toList();
  }

  void updatecash_recovery(String value) {
    final recoveryAmount = double.tryParse(value) ?? 0.0;
    if (recoveryAmount <= current_balance.value) {
      cash_recovery.value = recoveryAmount;
      net_balance.value = current_balance.value - cash_recovery.value;
    } else {
      // Handle invalid input
      Get.snackbar(
          "Error", "Recovery amount cannot be more than current balance!");
    }
  }

  List<Map<String, dynamic>> get paymentHistoryAsMapList {
    return paymentHistory.value.map((payment) {
      return {
        'Date': payment.date,
        'Amount': payment.amount,
        'Shop': payment.shop,
      };
    }).toList();
  }

  Future<void> submitForm() async {
    final recoverySerial = generateNewOrderId(user_id);
    // shop_visit_master_id = orderSerial;
   await  addRecoveryForm(RecoveryFormModel(
      recovery_id: recoverySerial,
      shop_name: selectedShop.value,
      current_balance: current_balance.value!.toString(),
      cash_recovery: cash_recovery.value,
      net_balance: net_balance.value,
    ));
    await recoveryformRepository.postDataFromDatabaseToAPI();
    // Implement your form submission logic here
    Get.snackbar("Success", "Form submitted successfully!");
  }




  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    if (recoveryCurrentMonth != currentMonth) {
      recoverySerialCounter = 1;
      recoveryCurrentMonth = currentMonth;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recoverySerialCounter = (prefs.getInt('recoverySerialCounter') ?? recoveryHighestSerial ?? 1);
    recoveryCurrentMonth = prefs.getString('recoveryCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (kDebugMode) {
      print('SR: $recoverySerialCounter');
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recoverySerialCounter', recoverySerialCounter);
    await prefs.setString('recoveryCurrentMonth', recoveryCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      recoverySerialCounter = 1;
      currentuser_id = user_id;
    }

    if (recoveryCurrentMonth != currentMonth) {
      recoverySerialCounter = 1;
      recoveryCurrentMonth = currentMonth;
    }

    String orderId =
        "SV-$user_id-$currentMonth-${recoverySerialCounter.toString().padLeft(3, '0')}";
    recoverySerialCounter++;
    _saveCounter();
    return orderId;
  }

  fetchAllRecoveryForm() async{
    var recoveryform = await recoveryformRepository.getRecoveryForm();
    allRecoveryForm.value = recoveryform;
  }

  addRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.add(recoveryformModel);
    fetchAllRecoveryForm();
  }

  updateRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.update(recoveryformModel);
    fetchAllRecoveryForm();
  }

  deleteRecoveryForm(int id){
    recoveryformRepository.delete(id);
    fetchAllRecoveryForm();
  }

}