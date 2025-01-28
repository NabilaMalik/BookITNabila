import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceOutRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(attendanceOutTableName, columns: [
      'attendance_out_id',
      'attendance_out_date',
      'attendance_out_time',
      'user_id',
      'total_time',
      'lat_out',
      'lng_out',
      'total_distance',
      'address',
      'posted'
    ]);
    List<AttendanceOutModel> attendanceout = [];

    for (int i = 0; i < maps.length; i++) {
      attendanceout.add(AttendanceOutModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from AttendanceOut database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return attendanceout;
  }Future<void> fetchAndSaveAttendanceOut() async {
    print('${Config.getApiUrlAttendanceOut}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlAttendanceOut}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      AttendanceOutModel model = AttendanceOutModel.fromMap(item);
      await dbClient.insert(attendanceOutTableName, model.toMap());
    }
  }

  Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      attendanceOutTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<AttendanceOutModel> attendanceOutModel = maps.map((map) => AttendanceOutModel.fromMap(map)).toList();
    return attendanceOutModel;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedAttendanceOut();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.attendance_out_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.attendance_out_id}: $e');
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

  Future<void> postShopToAPI(AttendanceOutModel shop) async {
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
  Future<int> add(AttendanceOutModel attendanceoutModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        attendanceOutTableName, attendanceoutModel.toMap());
  }

  Future<int> update(AttendanceOutModel attendanceoutModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        attendanceOutTableName, attendanceoutModel.toMap(),
        where: 'attendance_out_id = ?', whereArgs: [attendanceoutModel.attendance_out_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(attendanceOutTableName, where: 'attendance_out_id = ?', whereArgs: [id]);
  }
}
