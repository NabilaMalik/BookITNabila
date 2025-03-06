import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/returnform_details_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class ReturnFormDetailsRepository {
  DBHelper dbHelper = DBHelper();
  Future<List<ReturnFormDetailsModel>> getReturnFormDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(returnFormDetailsTableName, columns: [
      'return_details_id',
      'return_details_date',
      'return_details_time',
      'item',
      'quantity',
      'user_id',
      'reason',
      'return_master_id',
      'posted'
    ]);
    List<ReturnFormDetailsModel> returnformdetails = [];
    for (int i = 0; i < maps.length; i++) {
      returnformdetails.add(ReturnFormDetailsModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      debugPrint('Return Form Details Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        debugPrint("map");
      }
    }
    return returnformdetails;
  }
  Future<void> fetchAndSaveReturnFormDetails() async {
    debugPrint('${Config.getApiUrlReturnFormDetails}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlReturnFormDetails}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ReturnFormDetailsModel model = ReturnFormDetailsModel.fromMap(item);
      await dbClient.insert(returnFormDetailsTableName, model.toMap());
    }
  }

  Future<List<ReturnFormDetailsModel>> getUnPostedReturnFormDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      returnFormDetailsTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<ReturnFormDetailsModel> attendanceIn = maps.map((map) => ReturnFormDetailsModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedReturnFormDetails();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              debugPrint('Shop with id ${shop.return_details_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to post shop with id ${shop.return_details_id}: $e');
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

  Future<void> postShopToAPI(ReturnFormDetailsModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        debugPrint('Updated Shop Post API: ${Config.postApiUrlReturnFormDetails}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlReturnFormDetails),
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
  Future<int> add(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        returnFormDetailsTableName, returnformdetailsModel.toMap());
  }

  Future<int> update(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        returnFormDetailsTableName, returnformdetailsModel.toMap(),
        where: 'return_details_id = ?', whereArgs: [returnformdetailsModel.return_details_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(returnFormDetailsTableName, where: 'return_details_id = ?', whereArgs: [id]);
  }
}
