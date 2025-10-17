// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Models/add_shop_model.dart';
// import '../../Repositories/add_shop_repository.dart';
// import '../Databases/util.dart';
// import 'location_view_model.dart';
//
// class AddShopViewModel extends GetxController {
//   final AddShopRepository _shopRepository = Get.put(AddShopRepository());
//   final _shop = AddShopModel().obs;
//   var allAddShop = <AddShopModel>[].obs;
//   final locationViewModel = Get.put(LocationViewModel());
//
//   final _formKey = GlobalKey<FormState>();
//
//   GlobalKey<FormState> get formKey => _formKey;
//   var cities = <String>[].obs;
//   var country = <String>[].obs;
//
//   int shopSerialCounter = 1;
//   String shopCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//
//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     // fetchAndSaveShop();
//     fetchCities();
//   }
//
//   void fetchCities() async {
//     try {
//       var fetchedCities = await _shopRepository.fetchCities();
//       cities.value = fetchedCities;
//     } catch (e) {
//       debugPrint('Failed to fetch cities: $e');
//     }
//   }
//
//   var selectedCity = ''.obs;
//   var selectedCountry = ''.obs;
//
//   void setShopField(String field, dynamic value) {
//     switch (field) {
//       case 'shop_name':
//         _shop.update((shop) {
//           shop!.shop_name = value;
//         });
//         break;
//       case 'shop_address':
//         _shop.update((shop) {
//           shop!.shop_address = value;
//         });
//         break;
//       case 'owner_name':
//         _shop.update((shop) {
//           shop!.owner_name = value;
//         });
//         break;
//       case 'owner_cnic':
//         _shop.update((shop) {
//           shop!.owner_cnic = value;
//         });
//         break;
//       case 'phone_no':
//         _shop.update((shop) {
//           shop!.phone_no = value;
//         });
//         break;
//       case 'alternative_phone_no':
//         _shop.update((shop) {
//           shop!.alternative_phone_no = value;
//         });
//         break;
//       case 'city':
//         _shop.update((shop) {
//           selectedCity.value = value;
//           shop!.city = value;
//         });
//         break;
//       case 'isGPSEnabled':
//         _shop.update((shop) {
//           shop!.isGPSEnabled = value;
//         });
//         break;
//       default:
//         break;
//     }
//   }
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     shopSerialCounter =
//     (prefs.getInt('shopSerialCounter') ?? shopHighestSerial ?? 1);
//     shopCurrentMonth = prefs.getString('shopCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (shopCurrentMonth != currentMonth) {
//       shopSerialCounter = 1;
//       shopCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $shopSerialCounter');
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('shopSerialCounter', shopSerialCounter);
//     await prefs.setString('shopCurrentMonth', shopCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       shopSerialCounter = shopHighestSerial ?? 1;
//       currentuser_id = user_id;
//     }
//
//     if (shopCurrentMonth != currentMonth) {
//       shopSerialCounter = 1;
//       shopCurrentMonth = currentMonth;
//     }
//
//     String orderId = "S-$user_id-$currentMonth-${shopSerialCounter
//         .toString()
//         .padLeft(3, '0')}";
//     shopSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//
//   // Clear filters
//   clearFilters() {
//     _shop.value = AddShopModel();
//  locationViewModel.isGPSEnabled.value = false;
//     _shop.value.isGPSEnabled = false;
//     selectedCity.value = ''; // Reset selected city
//     _formKey.currentState?.reset();
//   }
//
//   bool validateForm() {
//     return _formKey.currentState?.validate() ?? false;
//   }
//
//   void saveForm() async {
//     final isFormValid = validateForm();
//     final isGpsEnabled = locationViewModel.isGPSEnabled.value == true;
//     debugPrint('Form valid: $isFormValid, GPS enabled: $isGpsEnabled');
//
//
//     if (isFormValid && isGpsEnabled) {
//       await _loadCounter();
//       final shopSerial = await generateNewOrderId(user_id);
//
//       await _shopRepository.addAddShop(AddShopModel(
//         shop_id: shopSerial,
//         shop_name: _shop.value.shop_name,
//         shop_address: _shop.value.shop_address,
//         owner_name: _shop.value.owner_name,
//         owner_cnic: _shop.value.owner_cnic,
//         phone_no: _shop.value.phone_no,
//         alternative_phone_no: _shop.value.alternative_phone_no,
//         city: _shop.value.city,
//         user_id: user_id.toString(),
//         longitude: locationViewModel.globalLatitude1.value,
//         latitude: locationViewModel.globalLongitude1.value,
//         shop_live_address: locationViewModel.shopAddress.value,
//         isGPSEnabled: _shop.value.isGPSEnabled,
//       ),
//           allAddShop);
//
//       // ✅ Show success snackbar
//       Get.snackbar(
//         'Success',
//         'Shop saved successfully!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 2),
//       );
//
//       // 👉 Clear the form fields after saving
//      await clearFilters();
//     } else {
//       // ❌ Show error
//       Get.snackbar(
//         'Error',
//         'Please fill all required fields.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 2),
//       );
//     }
//   }
//
//
//   fetchAllAddShop() async {
//     var addShop = await _shopRepository.getAddShop();
//     allAddShop.value = addShop;
//   }
//
//   fetchAndSaveShop() async {
//     await _shopRepository.fetchAndSaveShops();
//     // await fetchAllAddShop();
//   }
//
//   fetchAndSaveHeadsShop() async {
//     await _shopRepository.fetchAndSaveShopsForHeads();
//     // await fetchAllAddShop();
//   }
//
//   addAddShop(AddShopModel addShopModel) async {
//     await _shopRepository.addAddShop(addShopModel, allAddShop);
//   }
//
//   updateAddShop(AddShopModel addShopModel) async {
//     await _shopRepository.updateAddShop(addShopModel, allAddShop);
//   }
//
//   deleteAddShop(String? id) async {
//     await _shopRepository.deleteAddShop(id, allAddShop);
//   }
//
//   serialCounterGet() async {
//     await _shopRepository.serialNumberGeneratorApi();
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/add_shop_model.dart';
import '../../Repositories/add_shop_repository.dart';
import '../Databases/util.dart';
import 'location_view_model.dart';

class AddShopViewModel extends GetxController {
  final AddShopRepository _shopRepository = Get.put(AddShopRepository());
  final _shop = AddShopModel().obs;
  var allAddShop = <AddShopModel>[].obs;
  final locationViewModel = Get.put(LocationViewModel());

  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;
  var cities = <String>[].obs;
  var country = <String>[].obs;

  // New reactive variable for button state
  var isFormReadyToSave = false.obs;

  int shopSerialCounter = 1;
  String shopCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  Future<void> onInit() async {
    super.onInit();
    // fetchAndSaveShop();
    fetchCities();
  }

  // ///addlines
  // Future<void> syncLocalShopsToServer() async {
  //   try {
  //
  //     await _shopRepository.syncLocalShops(allAddShop);
  //     debugPrint('✅ All local shops pushed to server successfully');
  //   } catch (e) {
  //     debugPrint('❌ Error syncing shops: $e');
  //   }
  // }

  // Helper function to clean the city string format
  String _cleanCityString(String cityString) {
    // Expected format: "{city: City Name}"
    // This regex will find and replace "{city: " and the closing "}"
    // It is case-insensitive and trims whitespace.
    return cityString.replaceAll(RegExp(r'\{city:\s*|\}$', caseSensitive: false), '').trim();
  }

  void fetchCities() async {
    try {
      var fetchedCities = await _shopRepository.fetchCities();
      // Clean up the city names before assigning to the observable list
      cities.value = fetchedCities.map((city) => _cleanCityString(city)).toList();
    } catch (e) {
      debugPrint('Failed to fetch cities: $e');
    }
  }

  var selectedCity = ''.obs;
  var selectedCountry = ''.obs;

  // New method to check and update the save button state
  void updateSaveButtonState() {
    // Note: The validator is not run here, only a check for non-empty values
    final areRequiredFieldsFilled =
        (_shop.value.shop_name?.isNotEmpty ?? false) &&
            (_shop.value.shop_address?.isNotEmpty ?? false) &&
            (_shop.value.owner_name?.isNotEmpty ?? false) &&
            (_shop.value.owner_cnic?.isNotEmpty ?? false) &&
            (_shop.value.phone_no?.isNotEmpty ?? false) &&
            (_shop.value.city?.isNotEmpty ?? false);

    final isGpsEnabled = locationViewModel.isGPSEnabled.value == true;

    isFormReadyToSave.value = areRequiredFieldsFilled && isGpsEnabled;
    debugPrint('Is Form Ready to Save: ${isFormReadyToSave.value}');
  }

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
    // Update button state after any field change
    updateSaveButtonState();
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // NOTE: shopHighestSerial is undefined in the provided file.
    // Assuming a default value of 1 if it cannot be fetched.
    const int shopHighestSerial = 1;
    shopSerialCounter =
    (prefs.getInt('shopSerialCounter') ?? shopHighestSerial ?? 1);
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

    // NOTE: shopHighestSerial is undefined in the provided file.
    // Assuming a default value of 1 if it cannot be fetched.
    const int shopHighestSerial = 1;

    if (currentuser_id != user_id) {
      shopSerialCounter = shopHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (shopCurrentMonth != currentMonth) {
      shopSerialCounter = 1;
      shopCurrentMonth = currentMonth;
    }

    String orderId = "S-$user_id-$currentMonth-${shopSerialCounter
        .toString()
        .padLeft(3, '0')}";
    shopSerialCounter++;
    _saveCounter();
    return orderId;
  }

  // Clear filters
  clearFilters() {
    _shop.value = AddShopModel();
    locationViewModel.isGPSEnabled.value = false;
    _shop.value.isGPSEnabled = false;
    selectedCity.value = ''; // Reset selected city
    _formKey.currentState?.reset();
    updateSaveButtonState(); // Ensure button is disabled after clearing
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() async {
    // We already check if the form is ready to save via isFormReadyToSave
    // but the final validation check should still be here.
    final isFormValid = validateForm();
    final isGpsEnabled = locationViewModel.isGPSEnabled.value == true;
    debugPrint('Form valid: $isFormValid, GPS enabled: $isGpsEnabled');


    if (isFormValid && isGpsEnabled) {
      // Logic for saving (your existing logic)
      await _loadCounter();
      // NOTE: 'user_id' is missing from the view model,
      // it should ideally be loaded from Shared Preferences.
      // Assuming 'user_id' is a global or static variable for now.
      // const String user_id = 'DEFAULT_USER'; // TEMPORARY FIX
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
        longitude: locationViewModel.globalLatitude1.value,
        latitude: locationViewModel.globalLongitude1.value,
        shop_live_address: locationViewModel.shopAddress.value,
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
      await clearFilters();
    } else {
      // ❌ Show error
      // This path is less likely to be hit now if the button is disabled,
      // but it handles cases where validation fails even with data entered.
      Get.snackbar(
        'Error',
        'Please fill all required fields and enable GPS.',
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

  serialCounterGet() async {
    await _shopRepository.serialNumberGeneratorApi();
  }
}