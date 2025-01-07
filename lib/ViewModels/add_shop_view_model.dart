import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/add_shop_model.dart';
import '../../Repositories/add_shop_repository.dart';

class AddShopViewModel extends GetxController {
  final AddShopRepository _shopRepository = Get.put(AddShopRepository());
  final _shop = AddShopModel().obs;
  var allAddShop = <AddShopModel>[].obs;

  final _formKey = GlobalKey<FormState>();

  AddShopModel get shop => _shop.value;
  GlobalKey<FormState> get formKey => _formKey;
  var cities = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCities();
  }

  void fetchCities() async {
    try {
      var fetchedCities = await _shopRepository.fetchCities();
      cities.value = fetchedCities;
    } catch (e) {
      // Handle error
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

  // Clear filters
  clearFilters() {
    _shop.value = AddShopModel();
    selectedCity.value = ''; // Reset selected city
    _formKey.currentState?.reset();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() async {
    if (validateForm()) {
      await _shopRepository.add(shop);
      await _shopRepository.getAddShop();
      await clearFilters();
      // Navigate to another screen if needed
      // Get.to(() => HomeScreen());
    }
  }

  fetchAllAddShop() async {
    var addShop = await _shopRepository.getAddShop();
    allAddShop.value = addShop;
  }

  addAddShop(AddShopModel addShopModel) {
    _shopRepository.add(addShopModel);
    fetchAllAddShop();
  }

  updateAddShop(AddShopModel addShopModel) {
    _shopRepository.update(addShopModel);
    fetchAllAddShop();
  }

  deleteAddShop(int id) {
    _shopRepository.delete(id);
    fetchAllAddShop();
  }
}
