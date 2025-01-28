import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/recovery_form_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class RecoveryFormRepository {
  DBHelper dbHelper = DBHelper();
  Future<List<RecoveryFormModel>> getRecoveryForm() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(recoveryFormTableName, columns: [
      'recovery_id',
      'shop_name',
      'current_balance',
      'cash_recovery',
      'net_balance',
      'recovery_date',
      'recovery_time',
      'posted'
    ]);
    List<RecoveryFormModel> recoveryform = [];
    for (int i = 0; i < maps.length; i++) {
      recoveryform.add(RecoveryFormModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Recovery form Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return recoveryform;
  }
  Future<void> fetchAndSaveRecovery() async {
    print('${Config.getApiUrlRecoveryForm}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlRecoveryForm}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      RecoveryFormModel model = RecoveryFormModel.fromMap(item);
      await dbClient.insert(recoveryFormTableName, model.toMap());
    }
  }

  Future<List<RecoveryFormModel>> getUnPostedRecovery() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      recoveryFormTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<RecoveryFormModel> attendanceIn = maps.map((map) => RecoveryFormModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedRecovery();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.recovery_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.recovery_id}: $e');
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

  Future<void> postShopToAPI(RecoveryFormModel shop) async {
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
  Future<int> add(RecoveryFormModel recoveryformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        recoveryFormTableName, recoveryformModel.toMap());
  }

  Future<int> update(RecoveryFormModel recoveryformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        recoveryFormTableName, recoveryformModel.toMap(),
        where: 'recovery_id = ?', whereArgs: [recoveryformModel.recovery_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(recoveryFormTableName, where: 'recovery_id = ?', whereArgs: [id]);
  }
}
