import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/recovery_form_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
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
      'user_id',
      'posted'
    ]);
    List<RecoveryFormModel> recoveryform = [];
    for (int i = 0; i < maps.length; i++) {
      recoveryform.add(RecoveryFormModel.fromMap(maps[i]));
    }

      debugPrint('Recovery form Raw data from database:');

    // ignore: unused_local_variable
    for (var map in maps) {

        debugPrint("$map");

    }
    return recoveryform;
  }
  Future<void> fetchAndSaveRecovery() async {
    debugPrint('${Config.getApiUrlRecoveryForm}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlRecoveryForm}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      RecoveryFormModel model = RecoveryFormModel.fromMap(item);
      await dbClient.insert(recoveryFormTableName, model.toMap());
    }
  }

  Future<void> getRecoveryHighestSerialNo() async {
    int serial;
    String month='';

    final db = await dbHelper.db;
    final result = await db.rawQuery('''
    SELECT recovery_id 
    FROM $recoveryFormTableName
    WHERE user_id = ? AND recovery_id IS NOT NULL
  ''', [user_id]);

    if (result.isNotEmpty) {
      // Extract the serial numbers and month from the recovery_id strings
      final serialNos = result.map((row) {
        final recoveryId = row['recovery_id'] as String?;
        if (recoveryId != null) {
          // Assuming the format is like "SHP-B02-Jan-001"
          final parts = recoveryId.split('-');
          if (parts.length == 4) { // There should be exactly 4 parts
            final serialNoPart = parts[3];
            month = parts[2]; // Extract the month part
            if (serialNoPart.isNotEmpty) {
              return int.tryParse(serialNoPart);
            }
          }
        }
        return null;
      }).where((serialNo) => serialNo != null).cast<int>().toList();

      // Find and set the maximum serial number
      if (serialNos.isNotEmpty) {
        serial = serialNos.reduce(max);
        serial++;
        // Increment the highest serial number
        recoveryHighestSerial = serial;
        recoverySavedMonthCounter = month; // Save the month part to savedMonth variable
      } else {

          debugPrint('No valid recovery_id numbers found for this user');

      }
    } else {

        debugPrint('No orders found for this user');

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

              debugPrint('Shop with id ${shop.recovery_id} posted and updated in local database.');

          } catch (e) {

              debugPrint('Failed to post shop with id ${shop.recovery_id}: $e');

          }
        }
      } else {

          debugPrint('Network not available. Unposted shops will remain local.');

      }
    } catch (e) {

        debugPrint('Error fetching unposted shops: $e');

    }
  }

  Future<void> postShopToAPI(RecoveryFormModel shop) async {
    try {
      await Config.fetchLatestConfig();

        debugPrint('Updated Shop Post API: ${Config.postApiUrlRecoveryForm}');
        // debugPrint('Updated Shop Post API: ${Config.postApiUrlRecoveryForm}');

      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlRecoveryForm),
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
  Future<void> serialNumberGeneratorApi() async {
     final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/recoveryserial/get/$user_id',
      maxColumnName: 'max(recovery_id)',
      serialType: recoveryHighestSerial, // Unique identifier for shop visit serials
    );
     await orderDetailsGenerator.getAndIncrementSerialNumber();
     recoveryHighestSerial = orderDetailsGenerator.serialType;

  }
}
