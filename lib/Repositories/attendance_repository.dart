import 'package:flutter/foundation.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendance_Model.dart';

class AttendanceRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceModel>> getAttendance() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(attendanceTableName, columns: [
      'attendance_in_id',
      'attendance_in_date',
      'attendance_in_time',
      'time_in',
      'user_id',
      'lat_in',
      'lng_in',
      'booker_name',
      'designation',
      'city',
      'address'
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

  Future<int> add(AttendanceModel attendanceModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(attendanceTableName, attendanceModel.toMap());
  }

  Future<int> update(AttendanceModel attendanceModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(attendanceTableName, attendanceModel.toMap(),
        where: 'id = ?', whereArgs: [attendanceModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(attendanceTableName, where: 'id = ?', whereArgs: [id]);
  }
}
