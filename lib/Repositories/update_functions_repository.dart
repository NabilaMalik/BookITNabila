import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Models/add_shop_model.dart';
import '../Models/order_master_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class UpdateFunctionsRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  Future<void> checkAndSetInitializationDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current date and time
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);

    // Check if 'lastInitializationDateTime' is already stored
    await prefs.reload();
    String? lastInitDateTime = prefs.getString('lastInitializationDateTime');

    if (lastInitDateTime == null) {
      // If not, set the current date and time
      await prefs.reload();
      await prefs.setString('lastInitializationDateTime', formattedDateTime);

      print(
          'lastInitializationDateTime was not set, initializing to: $formattedDateTime');
    } else {
      // If it is already set, update it with the new date and time
      await prefs.reload();
      await prefs.setString('lastInitializationDateTime', formattedDateTime);

      print('lastInitializationDateTime updated to: $formattedDateTime');
    }
  }


  // Future<void> checkAndSetInitializationDateTime() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   // Check if 'lastInitializationDateTime' is already stored
  //   String? lastInitDateTime = prefs.getString('lastInitializationDateTime');
  //
  //   if (lastInitDateTime == null) {
  //     // If not, set the current date and time
  //     DateTime now = DateTime.now();
  //     String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
  //     await prefs.setString('lastInitializationDateTime', formattedDateTime);
  //     if (kDebugMode) {
  //       print('lastInitializationDateTime was not set, initializing to: $formattedDateTime');
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print('lastInitializationDateTime is already set to: $lastInitDateTime');
  //     }
  //   }
  // }
  // Future<void> fetchAndSaveUpdatedShop() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   debugPrint('${Config.getApiUrlShopVisit}$user_id');
  //   String? formattedDateTime = prefs.getString('lastInitializationDateTime');
  //   // List<dynamic> data = await ApiService.getData('${Config.getApiUrlShop}$user_id');
  //   List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/shopgettime/get/$user_id/$formattedDateTime');
  //   var dbClient = await dbHelper.db;
  //
  //   // Save data to database
  //   for (var item in data) {
  //     item['posted'] = 1; // Set posted to 1
  //     AddShopModel model = AddShopModel.fromMap(item);
  //     await dbClient.insert(shopVisitMasterTableName, model.toMap());
  //   }
  // }
  Future<void> fetchAndSaveUpdatedOrderMaster() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    debugPrint('${Config.getApiUrlOrderMaster}$user_id');
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');

    // Fetch data from the API
    List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/ordermastergettime/get/$user_id/$formattedDateTime');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      OrderMasterModel model = OrderMasterModel.fromMap(item);

      // Check if the order_master_id already exists in the local database
      List<Map> existingRecords = await dbClient.query(
        orderMasterTableName,
        where: 'order_master_id = ?',
        whereArgs: [model.order_master_id],
      );

      if (existingRecords.isNotEmpty) {
        // Update the existing record
        await dbClient.update(
          orderMasterTableName,
          model.toMap(),
          where: 'order_master_id = ?',
          whereArgs: [model.order_master_id],
        );
        debugPrint('Updated existing record with order_master_id: ${model.order_master_id}');
      } else {
        // Insert the new record from the API
        await orderMasterViewModel.addConfirmOrder(model);
        // await dbClient.insert(orderMasterTableName, model.toMap());
        debugPrint('Inserted new record with order_master_id: ${model.order_master_id}');
      }
    }
  }

  Future<void> fetchAndSaveUpdatedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint('${Config.getApiUrlShopVisit}$user_id');
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');
    // List<dynamic> data = await ApiService.getData('${Config.getApiUrlShop}$user_id');
    List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/productgettime/get/$formattedDateTime');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ProductsModel model = ProductsModel.fromMap(item);
      // Check if the order_master_id already exists in the local database
      List<Map> existingRecords = await dbClient.query(
        productsTableName,
        where: 'id = ?',
        whereArgs: [model.id],
      );
      // If a record with the same order_master_id exists, delete it
      if (existingRecords.isNotEmpty) {
        await dbClient.update(
          productsTableName,
          model.toMap(),
          where: 'id = ?',
          whereArgs: [model.id],
        );

        debugPrint('Updated existing record with Product Id: ${model.id}');
      }else{
      await dbClient.insert(productsTableName, model.toMap());
      debugPrint('Inserted new record with Product Id: ${model.id}');
    }}
  }

  Future<List<String>> fetchAndSaveUpdatedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.reload();
    // String url = Config.getApiUrlCities;
    String? formattedDateTime = prefs.getString('lastInitializationDateTime');

    String url = "https://cloud.metaxperts.net:8443/erp/test1/citiestime/get/$formattedDateTime";
    List<dynamic> data = await ApiService.getData(url);
    List<String> fetchedCities = data.map((city) => city.toString()).toList();

    List<String> storedCities = await getCitiesFromSharedPreferences();
    List<String> newCities = fetchedCities.where((city) => !storedCities.contains(city)).toList();
    List<String> removedCities = storedCities.where((city) => !fetchedCities.contains(city)).toList();

    storedCities.addAll(newCities);
    removedCities.forEach((city) => storedCities.remove(city));

    await saveCitiesToSharedPreferences(storedCities);
    return storedCities;
  }

  Future<void> saveCitiesToSharedPreferences(List<String> cities) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setStringList('cities', cities);
  }

  Future<List<String>> getCitiesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList('cities') ?? [];
  }

}