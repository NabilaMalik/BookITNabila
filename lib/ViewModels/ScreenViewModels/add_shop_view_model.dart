// lib/viewmodels/add_shop_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/ScreenModels/shop_model.dart';
import '../../Repositories/ScreenRepositories/shop_repository.dart';

class AddShopViewModel extends GetxController {
  final ShopRepository _shopRepository = Get.put(ShopRepository());
  final _shop = Shop().obs;
  final _formKey = GlobalKey<FormState>();

  Shop get shop => _shop.value;
  GlobalKey<FormState> get formKey => _formKey;

  List<String> cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Peshawar',
    'Quetta', 'Multan', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Sukkur',
    'Sargodha', 'Bahawalpur', 'Abbottabad', 'Mardan', 'Sheikhupura',
    'Gujrat', 'Jhelum', 'Kasur', 'Okara', 'Sahiwal', 'Rahim Yar Khan',
    'Dera Ghazi Khan', 'Chiniot', 'Nawabshah', 'Mirpur Khas', 'Khairpur',
    'Mansehra', 'Swat', 'Muzaffarabad', 'Kotli', 'Larkana', 'Jacobabad',
    'Shikarpur', 'Hafizabad', 'Toba Tek Singh', 'Mianwali', 'Bannu',
    'Dera Ismail Khan', 'Chaman', 'Gwadar', 'Zhob', 'Lakhdar', 'Ghotki',
    'Snowshed', 'Haripur', 'Charade'
  ];
  var selectedCity = ''.obs;
  void setShopField(String field, dynamic value) {
    switch (field) {
      case 'name':
        _shop.update((shop) { shop!.name = value; });
        break;
      case 'address':
        _shop.update((shop) { shop!.address = value; });
        break;
      case 'ownerName':
        _shop.update((shop) { shop!.ownerName = value; });
        break;
      case 'ownerCnic':
        _shop.update((shop) { shop!.ownerCnic = value; });
        break;
      case 'phoneNumber':
        _shop.update((shop) { shop!.phoneNumber = value; });
        break;
      case 'alternativePhoneNumber':
        _shop.update((shop) { shop!.alternativePhoneNumber = value; });
        break;
      case 'city':
        _shop.update((shop) { shop!.city = value; });
        break;
      case 'isGpsEnabled':
        _shop.update((shop) { shop!.isGpsEnabled = value; });
        break;
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    if (validateForm()) {
      _shopRepository.addShop(shop);
      // Get.to(() => HomeScreen());
    }
  }
}
