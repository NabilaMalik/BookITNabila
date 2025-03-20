import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/add_shop_model.dart';
import '../../Repositories/add_shop_repository.dart';
import '../Databases/util.dart';

class AddShopViewModel extends GetxController {
  final AddShopRepository _shopRepository = Get.put(AddShopRepository());
  final _shop = AddShopModel().obs;
  var allAddShop = <AddShopModel>[].obs;

  final _formKey = GlobalKey<FormState>();

  void clearFormFields() {
    _shop.value = AddShopModel();
    selectedCity.value = '';
    _formKey.currentState?.reset();
  }


  AddShopModel get shop => _shop.value;
  GlobalKey<FormState> get formKey => _formKey;
  var cities = <String>[].obs;
  int shopSerialCounter = 1;
  String shopCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  Future<void> onInit() async {
    super.onInit();
    // fetchAndSaveShop();
    fetchCities();
  }

  void fetchCities() async {
    try {
      var fetchedCities = await _shopRepository.fetchCities();
      cities.value = fetchedCities;
    } catch (e) {

      debugPrint('Failed to fetch cities: $e');

    }
  }

  var selectedCity = ''.obs;

  void setShopField(String field, dynamic value) {
    switch (field) {
      case 'shop_name':
        _shop.update((shop) {
          shop!.shop_name = value;
        });
        break;
      case 'shop_address':
        _shop.update((shop) {
          shop!.shop_address = value;
        });
        break;
      case 'owner_name':
        _shop.update((shop) {
          shop!.owner_name = value;
        });
        break;
      case 'owner_cnic':
        _shop.update((shop) {
          shop!.owner_cnic = value;
        });
        break;
      case 'phone_no':
        _shop.update((shop) {
          shop!.phone_no = value;
        });
        break;
      case 'alternative_phone_no':
        _shop.update((shop) {
          shop!.alternative_phone_no = value;
        });
        break;
      case 'city':
        _shop.update((shop) {
          selectedCity.value = value;
          shop!.city = value;
        });
        break;
      case 'isGPSEnabled':
        _shop.update((shop) {
          shop!.isGPSEnabled = value;
        });
        break;
      default:
        break;
    }
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopSerialCounter = (prefs.getInt('shopSerialCounter') ??shopHighestSerial?? 1);
    shopCurrentMonth = prefs.getString('shopCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (shopCurrentMonth != currentMonth) {
      shopSerialCounter = 1;
      shopCurrentMonth = currentMonth;
    }

    debugPrint('SR: $shopSerialCounter');

  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shopSerialCounter', shopSerialCounter);
    await prefs.setString('shopCurrentMonth', shopCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      shopSerialCounter = shopHighestSerial??1;
      currentuser_id = user_id;
    }

    if (shopCurrentMonth != currentMonth) {
      shopSerialCounter = 1;
      shopCurrentMonth = currentMonth;
    }

    String orderId = "S-$user_id-$currentMonth-${shopSerialCounter.toString().padLeft(3, '0')}";
    shopSerialCounter++;
    _saveCounter();
    return orderId;
  }

  // Clear filters
  void clearFilters() {
    _shop.value = AddShopModel();
    selectedCity.value = ''; // Reset selected city
    _formKey.currentState?.reset();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() async {
    if (validateForm()) {
      await _loadCounter();
      final shopSerial = await generateNewOrderId(user_id);

      await _shopRepository.addAddShop(AddShopModel(
        shop_id: shopSerial,
        shop_name: _shop.value.shop_name,
        shop_address: _shop.value.shop_address,
        owner_name: _shop.value.owner_name,
        owner_cnic: _shop.value.owner_cnic,
        phone_no: _shop.value.phone_no,
        alternative_phone_no: _shop.value.alternative_phone_no,
        city: _shop.value.city,
        user_id: user_id.toString(),
        isGPSEnabled: _shop.value.isGPSEnabled,
      ),
          allAddShop);

      // ✅ Show success snackbar
      Get.snackbar(
        'Success',
        'Shop saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      );

      // 👉 Clear the form fields after saving
      clearFormFields();

    } else {
      // ❌ Show error
      Get.snackbar(
        'Error',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      );
    }
  }



  fetchAllAddShop() async {
    var addShop = await _shopRepository.getAddShop();
    allAddShop.value = addShop;
  }
  fetchAndSaveShop() async {
    await _shopRepository.fetchAndSaveShops();
    // await fetchAllAddShop();
  }
  fetchAndSaveHeadsShop() async {
    await _shopRepository.fetchAndSaveShopsForHeads();
    // await fetchAllAddShop();
  }

  addAddShop(AddShopModel addShopModel) async {
    await _shopRepository.addAddShop(addShopModel, allAddShop);
  }

  updateAddShop(AddShopModel addShopModel) async {
    await _shopRepository.updateAddShop(addShopModel, allAddShop);
  }

  deleteAddShop(String? id) async {
    await _shopRepository.deleteAddShop(id, allAddShop);
  }
  serialCounterGet()async{
    await _shopRepository.serialNumberGeneratorApi();
  }
}