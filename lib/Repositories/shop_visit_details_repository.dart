import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Models/shop_visit_model.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_details_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';


class ShopVisitDetailsRepository extends GetxService{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitDetailsModel>> getShopVisitDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitDetailsTableName, columns: [
      'shop_visit_details_id',
      'shop_visit_details_date',
      'shop_visit_details_time',
      'product',
      'quantity',
      'shop_visit_master_id',
      'posted'
    ]);
    List<ShopVisitDetailsModel> shopvisitdetails = [];
    for (int i = 0; i < maps.length; i++) {
      shopvisitdetails.add(ShopVisitDetailsModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print(' Raw data from Shop Visit Details database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return shopvisitdetails;
  }
  Future<void> fetchAndSaveShopVisitDetails() async {
    print('${Config.getApiUrlShopVisitDetails}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlShopVisitDetails}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ShopVisitDetailsModel model = ShopVisitDetailsModel.fromMap(item);
      await dbClient.insert(shopVisitDetailsTableName, model.toMap());
    }
  }

  Future<List<ShopVisitDetailsModel>> getUnPostedShopVisitDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      shopVisitDetailsTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<ShopVisitDetailsModel> attendanceIn = maps.map((map) => ShopVisitDetailsModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedShopVisitDetails();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.shop_visit_details_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.shop_visit_details_id}: $e');
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

  Future<void> postShopToAPI(ShopVisitDetailsModel shop) async {
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
  Future<int> add(ShopVisitDetailsModel shopvisitdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        shopVisitDetailsTableName, shopvisitdetailsModel.toMap());
  }

  Future<int> update(ShopVisitDetailsModel shopvisitdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        shopVisitDetailsTableName, shopvisitdetailsModel.toMap(),
        where: 'shop_visit_details_id = ?',
        whereArgs: [shopvisitdetailsModel.shop_visit_details_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(shopVisitDetailsTableName, where: 'shop_visit_details_id = ?', whereArgs: [id]);
  }

}
