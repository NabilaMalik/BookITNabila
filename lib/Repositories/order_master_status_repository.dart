import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/order_master_status_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class OrderMasterStatusRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
  Future<List<OrderMasterStatusModel>> getOrderMasterStatus() async {
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
    List<OrderMasterStatusModel> confirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      confirmorder.add(OrderMasterStatusModel.fromMap(maps[i]));
    }

      debugPrint('Raw data from database:');

    for (var map in maps) {
      if (kDebugMode) {
        debugPrint("$map");
      }
    }
    return confirmorder;
  }
  Future<void> fetchAndSaveOrderMaster() async {
    debugPrint('${Config.getApiUrlOrderMaster}$user_id');
    // List<dynamic> data = await ApiService.getData('${Config.getApiUrlOrderMaster}$user_id');
    List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/ordermasterget/get/$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      OrderMasterStatusModel model = OrderMasterStatusModel.fromMap(item);
      await dbClient.insert(orderMasterTableName, model.toMap());
    }
  }

  Future<List<OrderMasterStatusModel>> getUnPostedOrderMaster() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      orderMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<OrderMasterStatusModel> attendanceIn = maps.map((map) => OrderMasterStatusModel.fromMap(map)).toList();
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

  Future<void> postShopToAPI(OrderMasterStatusModel shop) async {
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
  Future<int> add(OrderMasterStatusModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(orderMasterTableName, confirmorderModel.toMap());
  }

  Future<int> update(OrderMasterStatusModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderMasterTableName, confirmorderModel.toMap(),
        where: 'order_master_id = ?', whereArgs: [confirmorderModel.order_master_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderMasterTableName, where: 'order_master_id = ?', whereArgs: [id]);
  }

}
