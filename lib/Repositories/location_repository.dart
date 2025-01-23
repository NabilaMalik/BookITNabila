import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/location_model.dart';

class LocationRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<LocationModel>> getLocation() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(locationTableName, columns: [
      'location_id',
      'location_date',
      'location_time',
      'file_name',
      'user_id',
      'booker_name',
      'total_distance',
      'body',
      'posted'
    ]);
    List<LocationModel> location = [];
    for (int i = 0; i < maps.length; i++) {
      location.add(LocationModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from Location database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return location;
  }

  Future<int> add(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(locationTableName, locationModel.toMap());
  }

  Future<int> update(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(locationTableName, locationModel.toMap(),
        where: 'location_id = ?', whereArgs: [locationModel.location_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(locationTableName, where: 'location_id = ?', whereArgs: [id]);
  }
}
