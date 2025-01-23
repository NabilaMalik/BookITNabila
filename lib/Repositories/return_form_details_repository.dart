import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/returnform_details_model.dart';

class ReturnFormDetailsRepository {
  DBHelper dbHelper = DBHelper();
  Future<List<ReturnFormDetailsModel>> getReturnFormDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(returnFormDetailsTableName, columns: [
      'return_details_id',
      'return_details_date',
      'return_details_time',
      'item',
      'qty',
      'reason',
      'return_master_id'
    ]);
    List<ReturnFormDetailsModel> returnformdetails = [];
    for (int i = 0; i < maps.length; i++) {
      returnformdetails.add(ReturnFormDetailsModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Return Form Details Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return returnformdetails;
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
