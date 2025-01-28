import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class ShopVisitRepository extends GetxService{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitMasterTableName, columns: [
      'shop_visit_master_id',
      'brand',
      'shop_visit_date',
      'shop_visit_time',
      'shop_name',
      'shop_address',
      'owner_name',
      'booker_name',
      'walk_through',
      'planogram',
      'signage',
      'product_reviewed',
      'feedback',
      'posted'
,      'body'
    ]);
    List<ShopVisitModel> shopvisit = [];
    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from Shop Visit Table database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return shopvisit;
  }
  Future<void> fetchAndSaveShopVisit() async {
    print('${Config.getApiUrlShopVisit}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlShopVisit}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ShopVisitModel model = ShopVisitModel.fromMap(item);
      await dbClient.insert(shopVisitMasterTableName, model.toMap());
    }
  }

  Future<List<ShopVisitModel>> getUnPostedShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      shopVisitMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<ShopVisitModel> attendanceIn = maps.map((map) => ShopVisitModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedShopVisit();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.shop_visit_master_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.shop_visit_master_id}: $e');
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

  Future<void> postShopToAPI(ShopVisitModel shop) async {
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
  Future<int> add(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        shopVisitMasterTableName, shopvisitModel.toMap());
  }

  Future<int> update(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        shopVisitMasterTableName, shopvisitModel.toMap(),
        where: 'shop_visit_master_id = ?',
        whereArgs: [shopvisitModel.shop_visit_master_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(shopVisitMasterTableName, where: 'shop_visit_master_id = ?', whereArgs: [id]);
  }
}
