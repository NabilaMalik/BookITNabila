import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendance_Model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceModel>> getAttendance() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(attendanceTableName, columns: [
      'attendance_in_id',
      'attendance_in_date',
      'attendance_in_time',
      'user_id',
      'lat_in',
      'lng_in',
      'booker_name',
      'designation',
      'city',
      'address',
      'posted'
    ]);
    List<AttendanceModel> attendance = [];
    for (int i = 0; i < maps.length; i++) {
      attendance.add(AttendanceModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from Attendance database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return attendance;
  }
  Future<void> fetchAndSaveAttendance() async {
    print('${Config.getApiUrlAttendanceIn}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlAttendanceIn}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      AttendanceModel model = AttendanceModel.fromMap(item);
      await dbClient.insert(attendanceTableName, model.toMap());
    }
  }
  Future<List<AttendanceModel>> getUnPostedAttendanceIn() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      attendanceTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );
    List<AttendanceModel> attendanceIn = maps.map((map) => AttendanceModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedAttendanceIn();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.attendance_in_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.attendance_in_id}: $e');
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

  Future<void> postShopToAPI(AttendanceModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        print('Updated Shop Post API: ${Config.postApiUrlAttendanceIn}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlAttendanceIn),
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
  Future<int> add(AttendanceModel attendanceModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(attendanceTableName, attendanceModel.toMap());
  }

  Future<int> update(AttendanceModel attendanceModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(attendanceTableName, attendanceModel.toMap(),
        where: 'attendance_in_id = ?', whereArgs: [attendanceModel.attendance_in_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(attendanceTableName, where: 'id = ?', whereArgs: [id]);
  }
}
