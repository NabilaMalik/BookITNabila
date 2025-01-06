import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';

class AttendanceOutRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(attendanceOutTableName, columns: [
      'id',
      'date',
      'timeOut',
      'userId',
      'totalTime',
      'latOut',
      'lngOut',
      'totalDistance',
      'address'
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
        where: 'id = ?', whereArgs: [attendanceoutModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(attendanceOutTableName, where: 'id = ?', whereArgs: [id]);
  }
}
