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
  String currentuser_id = '';
  var order_status = 'Pending'.obs;

  var credit_limit = ''.obs;
  var required_delivery_date = ''.obs;
  final List<String> credits = ['7 days', '15 days', 'On Cash'];

  @override
  Future<void> onInit() async {
  super.onInit();
    await fetchAllOrderMaster();
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    orderMasterSerialCounter = (prefs.getInt('orderMasterSerialCounter')  ?? orderMasterHighestSerial ?? 1);
    orderMasterCurrentMonth = prefs.getString('orderMasterCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (orderMasterCurrentMonth != currentMonth) {
      orderMasterSerialCounter = 1;
      orderMasterCurrentMonth = currentMonth;
    }
    debugPrint('SR: $orderMasterSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('orderMasterSerialCounter', orderMasterSerialCounter);
    await prefs.setString('orderMasterCurrentMonth', orderMasterCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      orderMasterSerialCounter = orderMasterHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (orderMasterCurrentMonth != currentMonth) {
      orderMasterSerialCounter = 1;
      orderMasterCurrentMonth = currentMonth;
    }

    String orderId = "OM-$user_id-$currentMonth-${orderMasterSerialCounter.toString().padLeft(3, '0')}";
    return orderId;
  }

  Future<String> generateAndSaveOrderId(String user_id) async {
    await _loadCounter(); // Load last saved value
    String orderId = generateNewOrderId(user_id);

    // Increment and save
    orderMasterSerialCounter++;
    await _saveCounter();
    return orderId;
  }

  Future<void> submitForm(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()&& required_delivery_date.value.isNotEmpty ) {
      final orderSerial = generateNewOrderId(user_id); // Generate serial
      order_master_id = orderSerial;
      debugPrint("Saving filtered products...");
      await orderDetailsViewModel.saveFilteredProducts();
    }else{
      Get.snackbar(
              "Error",
              "Please fill in the required delivery field.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
    }
  }

  Future<void> confirmSubmitForm() async {
    if (shopVisitViewModel.selectedShop.value.isNotEmpty) {
      // await orderMasterSerial();
      await _loadCounter();
      final orderSerial = await generateAndSaveOrderId(user_id); // Generate and save
      order_master_id = orderSerial;
      OrderMasterModel orderMasterModel = OrderMasterModel(
        shop_name: shopVisitViewModel.selectedShop.value,
        owner_name: shopVisitViewModel.selectedBrand.value,
        phone_no: shopVisitViewModel.phone_number.value,
        brand: shopVisitViewModel.selectedBrand.value,
        total: orderDetailsViewModel.total.value.toString(),
        credit_limit: credit_limit.value,
        nsm_id: userNSM,
        rsm_id: userRSM,
        sm_id: userSM,
        sm: userNameSM,
        rsm: userNameRSM,
        nsm: userNameNSM,
        order_status: order_status.value,
        user_id: user_id.toString(),
        required_delivery_date: required_delivery_date.value,
        order_master_id: order_master_id.toString(),
       );
        debugPrint("Submitting OrderMasterModel: ${orderMasterModel.toMap()}");
        await addConfirmOrder(orderMasterModel);

        debugPrint("Saving filtered products...");
        await orderDetailsViewModel.confirmFilteredProducts();

        debugPrint("Fetching all re-confirmed orders...");
        await orderDetailsViewModel.fetchAllReConfirmOrder();
        await orderMasterRepository.postDataFromDatabaseToAPI();
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> fetchAllOrderMaster() async {
    var confirmorder = await orderMasterRepository.getConfirmOrder();
    allOrderMaster.value = confirmorder;
  }

 fetchAndSaveOrderMaster() async {
    await orderMasterRepository.fetchAndSaveOrderMaster();
    await fetchAllOrderMaster();
  }

  Future<void> addConfirmOrder(OrderMasterModel orderMasterModel) async {
    await orderMasterRepository.add(orderMasterModel);
    await fetchAllOrderMaster();
  }

  Future<void> updateConfirmOrder(OrderMasterModel orderMasterModel) async {
    await orderMasterRepository.update(orderMasterModel);
    await fetchAllOrderMaster();
  }

  Future<void> deleteConfirmOrder(int id) async {
    await orderMasterRepository.delete(id);
    await fetchAllOrderMaster();
  }
  // Future<void>orderMasterSerial()async{
  //   await orderMasterRepository.getHighestSerialNo();
  // }
  serialCounterGet()async{
    await orderMasterRepository.serialNumberGeneratorApi();
  }
}
