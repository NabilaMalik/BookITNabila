import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/order_details_repository.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/order_master_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class OrderMasterRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
  OrderDetailsRepository orderDetailsRepository = Get.put(OrderDetailsRepository());
OrderDetailsViewModel orderDetailsViewModel =Get.put(OrderDetailsViewModel());
  Future<List<OrderMasterModel>> getConfirmOrder() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderMasterTableName, columns: [
      'order_master_id',
      'order_master_date',
      'order_master_time',
      'shop_name',
      'owner_name',
      'phone_no',
      'owner_name',
      'order_status',
      'total',
      'user_id',
      'credit_limit',
      'required_delivery_date',
      'posted'
    ]);
    List<OrderMasterModel> confirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      confirmorder.add(OrderMasterModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      debugPrint('Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        debugPrint("$map");
      }
    }
    return confirmorder;
  }
  Future<void> fetchAndSaveOrderMaster() async {
    debugPrint('${Config.getApiUrlOrderMaster}$user_id');
    List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/ordermasterget/get/$user_id');
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

      // If a record with the same order_master_id exists, delete it
      if (existingRecords.isNotEmpty) {
        await dbClient.delete(
          orderMasterTableName,
          where: 'order_master_id = ?',
          whereArgs: [model.order_master_id],
        );
        if (kDebugMode) {
          debugPrint('Deleted existing record with order_master_id: ${model.order_master_id}');
        }
      }

      // Insert the new record from the API
      await dbClient.insert(orderMasterTableName, model.toMap());
      if (kDebugMode) {
        debugPrint('Inserted new record with order_master_id: ${model.order_master_id}');
      }
    }
  }
  Future<List<OrderMasterModel>> getUnPostedOrderMaster() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      orderMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<OrderMasterModel> attendanceIn = maps.map((map) => OrderMasterModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedOrderMaster();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              debugPrint('Shop with id ${shop.order_master_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to post shop with id ${shop.order_master_id}: $e');
            }
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('Network not available. Unposted shops will remain local.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching unposted shops: $e');
      }
    }
  }

  Future<void> postShopToAPI(OrderMasterModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        debugPrint('Updated Shop Post API: ${Config.postApiUrlOrderMaster}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlOrderMaster),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Shop data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }
  Future<int> add(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(orderMasterTableName, confirmorderModel.toMap());
  }

  Future<int> update(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderMasterTableName, confirmorderModel.toMap(),
        where: 'order_master_id = ?', whereArgs: [confirmorderModel.order_master_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderMasterTableName, where: 'order_master_id = ?', whereArgs: [id]);
  }

}
