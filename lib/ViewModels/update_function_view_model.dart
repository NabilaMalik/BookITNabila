import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/update_functions_repository.dart';
import 'package:order_booking_app/Repositories/add_shop_repository.dart';
import 'package:order_booking_app/Repositories/shop_visit_repository.dart';
import 'package:order_booking_app/Repositories/order_master_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateFunctionViewModel extends GetxController {
  UpdateFunctionsRepository updateFunctionsRepository = Get.put(UpdateFunctionsRepository());
  final AddShopRepository addShopRepository = Get.put(AddShopRepository());
  final ShopVisitRepository shopVisitRepository = Get.put(ShopVisitRepository());
  final OrderMasterRepository orderMasterRepository = Get.put(OrderMasterRepository());

  bool isUpdate = false;
  var isInitialized = false.obs;
  var lastSyncTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndSetInitializationDateTime();
  }

  Future<void> checkAndSetInitializationDateTime() async {
    await updateFunctionsRepository.checkAndSetInitializationDateTime();
  }

  Future<void> fetchAndSaveUpdatedOrderMaster() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedOrderMaster();
  }

  Future<void> fetchAndSaveUpdatedProducts() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedProducts();
  }

  Future<List<String>> fetchAndSaveUpdatedCities() async {
    return await updateFunctionsRepository.fetchAndSaveUpdatedCities();
  }

  // NEW: Sync all local data to server
  Future<void> syncAllLocalDataToServer() async {
    try {
      debugPrint('🔄 Starting automatic sync of all local data to server...');

      // Sync shops
      await addShopRepository.syncAllPendingData();

      // Sync shop visits
      await shopVisitRepository.syncAllPendingData();

      // Sync orders
      await orderMasterRepository.syncAllPendingData();

      // Update sync time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentDateTime = DateTime.now().toString();
      await prefs.setString('initializationDateTime', currentDateTime);
      lastSyncTime.value = currentDateTime;

      debugPrint('✅ All local data synced to server successfully at: $currentDateTime');
    } catch (e) {
      debugPrint('❌ Error during automatic sync: $e');
      rethrow;
    }
  }

  // Force refresh all data
  Future<void> forceRefreshAllData() async {
    try {
      await fetchAndSaveUpdatedCities();
      await fetchAndSaveUpdatedProducts();
      await fetchAndSaveUpdatedOrderMaster();
      await syncAllLocalDataToServer();

      debugPrint('✅ Force refresh completed successfully');
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
      rethrow;
    }
  }
}