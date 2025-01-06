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
      case 'shopName':
        _shop.update((shop) { shop!.shopName = value; });
        break;
      case 'shopAddress':
        _shop.update((shop) { shop!.shopAddress = value; });
        break;
      case 'ownerName':
        _shop.update((shop) { shop!.ownerName = value; });
        break;
      case 'ownerCNIC':
        _shop.update((shop) { shop!.ownerCNIC = value; });
        break;
      case 'phoneNumber':
        _shop.update((shop) { shop!.phoneNumber = value; });
        break;
      case 'alterPhoneNumber':
        _shop.update((shop) { shop!.alterPhoneNumber = value; });
        break;
      case 'city':
        _shop.update((shop) { shop!.city = value; });
        break;
      case 'isGPSEnabled':
        _shop.update((shop) { shop!.isGPSEnabled = value; });
        break;
      default:
        break;
    }
  }

  // Clear filters
clearFilters() {
    shop.shopName= '';
    shop.city= '';
    shop.shopAddress= '';
    shop.ownerName= '';
    shop.ownerCNIC= '';
    shop.phoneNumber= '';
    shop.alterPhoneNumber= '';
    shop.isGPSEnabled = false;
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
  fetchAllAddShop() async{
    var addShop = await _shopRepository.getAddShop();
    allAddShop.value = addShop;
  }

  addAddShop(AddShopModel addShopModel){
    _shopRepository.add(addShopModel);
    fetchAllAddShop();
  }

  updateAddShop(AddShopModel addShopModel){
    _shopRepository.update(addShopModel);
    fetchAllAddShop();
  }

  deleteAddShop(int id){
    _shopRepository.delete(id);
    fetchAllAddShop();
  }

}
