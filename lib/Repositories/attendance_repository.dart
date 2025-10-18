import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendance_Model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
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

      debugPrint('Raw data from Attendance database:');

    // ignore: unused_local_variable
    for (var map in maps) {

        debugPrint("$map");

    }
    return attendance;
  }
  Future<void> fetchAndSaveAttendance() async {
    debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceIn}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceIn}$user_id');
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

              debugPrint('Shop with id ${shop.attendance_in_id} posted and updated in local database.');

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
///oldcode
//   Future<void> postShopToAPI(AttendanceModel shop) async {
//     try {
//       await Config.fetchLatestConfig();
//       if (kDebugMode) {
//         print('Updated Shop Post API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceIn}');
//       }
//       var shopData = shop.toMap();
//       final response = await http.post(
//         Uri.parse( '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceIn}'),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(shopData),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint('attendance_in_id data posted successfully: $shopData');
//         // Delete the shop visit data from the local database after successful post
//         await delete(shop.attendance_in_id!);
//         if (kDebugMode) {
//           debugPrint('attendance_in_id with id ${shop.attendance_in_id} deleted from local database.');
//         }
//       } else {
//         throw Exception('Server error: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       print('Error posting shop data: $e');
//       throw Exception('Failed to post data: $e');
//     }
//   }

  ///added code
  Future<void> postShopToAPI(AttendanceModel shop) async {
    try {
      await Config.fetchLatestConfig();
      String apiUrl = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceIn}';
      debugPrint('🔄 [REPO-IN] Posting to: $apiUrl');

      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      debugPrint('📡 [REPO-IN] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [REPO-IN] Data posted successfully: ${shop.attendance_in_id}');

        // ✅ CORRECT: Just update posted status, DON'T DELETE!
        shop.posted = 1;
        await update(shop);
        debugPrint('✅ [REPO-IN] Marked as posted: ${shop.attendance_in_id}');

      } else {
        debugPrint('❌ [REPO-IN] Server error: ${response.statusCode}, ${response.body}');
        // Don't throw - let it retry later
      }
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error posting data: $e');
      // Don't throw - let it retry later
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

  Future<int> delete(String id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(attendanceTableName, where: 'attendance_in_id = ?', whereArgs: [id]);
  }
  Future<void> serialNumberGeneratorApi() async {
    await Config.fetchLatestConfig();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceInSerial}$user_id',
      maxColumnName: 'max(attendance_in_id)',
      serialType: attendanceInHighestSerial, // Unique identifier for shop visit serials
    );
     await orderDetailsGenerator.getAndIncrementSerialNumber();
     attendanceInHighestSerial = orderDetailsGenerator.serialType;
     await prefs.reload();
     await prefs.setInt("attendanceInHighestSerial", attendanceInHighestSerial!);

  }
}
