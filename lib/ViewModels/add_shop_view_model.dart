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

  AddShopModel get shop => _shop.value;
  GlobalKey<FormState> get formKey => _formKey;
  var cities = <String>[].obs;
  int shopSerialCounter = 1;
  String shopCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    fetchCities();
    _loadCounter();
  }

  void fetchCities() async {
    try {
      var fetchedCities = await _shopRepository.fetchCities();
      cities.value = fetchedCities;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch cities: $e');
      }
    }
  }

  var selectedCity = ''.obs;

  void setShopField(String field, dynamic value) {
    switch (field) {
      case 'shopName':
        _shop.update((shop) {
          shop!.shopName = value;
        });
        break;
      case 'shopAddress':
        _shop.update((shop) {
          shop!.shopAddress = value;
        });
        break;
      case 'ownerName':
        _shop.update((shop) {
          shop!.ownerName = value;
        });
        break;
      case 'ownerCNIC':
        _shop.update((shop) {
          shop!.ownerCNIC = value;
        });
        break;
      case 'phoneNumber':
        _shop.update((shop) {
          shop!.phoneNumber = value;
        });
        break;
      case 'alterPhoneNumber':
        _shop.update((shop) {
          shop!.alterPhoneNumber = value;
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
    shopSerialCounter = (prefs.getInt('shopSerialCounter') ?? 1);
    shopCurrentMonth = prefs.getString('shopCurrentMonth') ?? currentMonth;
    currentUserId = prefs.getString('currentUserId') ?? '';

    if (shopCurrentMonth != currentMonth) {
      shopSerialCounter = 1;
      shopCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      print('SR: $shopSerialCounter');
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shopSerialCounter', shopSerialCounter);
    await prefs.setString('shopCurrentMonth', shopCurrentMonth);
    await prefs.setString('currentUserId', currentUserId);
  }

  String generateNewOrderId(String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentUserId != userId) {
      shopSerialCounter = 1;
      currentUserId = userId;
    }

    if (shopCurrentMonth != currentMonth) {
      shopSerialCounter = 1;
      shopCurrentMonth = currentMonth;
    }

    String orderId = "S-$userId-$currentMonth-${shopSerialCounter.toString().padLeft(3, '0')}";
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
      final shopSerial = generateNewOrderId(userId);

      await _shopRepository.addAddShop(AddShopModel(
        shopId: shopSerial,
        shopName: _shop.value.shopName,
        shopAddress: _shop.value.shopAddress,
        ownerName: _shop.value.ownerName,
        ownerCNIC: _shop.value.ownerCNIC,
        phoneNumber: _shop.value.phoneNumber,
        alterPhoneNumber: _shop.value.alterPhoneNumber,
        city: _shop.value.city,
        isGPSEnabled: _shop.value.isGPSEnabled,
      ), allAddShop);

      await fetchAllAddShop();
      // await clearFilters();
      // Navigate to another screen if needed
      // Get.to(() => HomeScreen());
    }
  }

  fetchAllAddShop() async {
    var addShop = await _shopRepository.getAddShop();
    allAddShop.value = addShop;
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
}
