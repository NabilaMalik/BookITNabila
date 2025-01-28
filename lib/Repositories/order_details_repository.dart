import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/order_details_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class OrderDetailsRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  Future<List<OrderDetailsModel>> getReConfirmOrder() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderDetailsTableName, columns: [
      'order_details_id',
      'order_details_date',
      'order_details_time',
      'product',
      'quantity',
      'in_stock',
      'rate',
      'amount',
      'order_master_id',
      'posted'
    ]);
    List<OrderDetailsModel> reconfirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      reconfirmorder.add(OrderDetailsModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('OrderDetails Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return reconfirmorder;
  }
  Future<void> fetchAndSaveOrderDetails() async {
    print('${Config.getApiUrlOrderDetails}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlOrderDetails}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      OrderDetailsModel model = OrderDetailsModel.fromMap(item);
      await dbClient.insert(orderDetailsTableName, model.toMap());
    }
  }

  Future<List<OrderDetailsModel>> getUnPostedOrderDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      orderDetailsTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<OrderDetailsModel> attendanceIn = maps.map((map) => OrderDetailsModel.fromMap(map)).toList();
    return attendanceIn;
  }
  Future<int> add(OrderDetailsModel orderDetailsModel) async {
    var dbClient = await dbHelper.db;
    int result =
        await dbClient.insert(orderDetailsTableName, orderDetailsModel.toMap());
    if (kDebugMode) {
      print('Inserted OrderDetailsModel: ${orderDetailsModel.toMap()}');
    }
    return result;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedOrderDetails();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.order_details_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.order_details_id}: $e');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Network not available. Unposted shops will remain local.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching unposted shops: $e');
      }
    }
  }

  Future<void> postShopToAPI(OrderDetailsModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        print('Updated Shop Post API: ${Config.postApiUrlShops}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlShops),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Shop data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  Future<int> update(OrderDetailsModel orderDetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        orderDetailsTableName, orderDetailsModel.toMap(),
        where: 'order_details_id = ?', whereArgs: [orderDetailsModel.order_details_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(orderDetailsTableName, where: 'order_details_id = ?', whereArgs: [id]);
  }
}
