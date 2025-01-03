import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/re_confirm_order_model.dart';
class ReConfirmOrderRepository{
  DBHelper dbHelper = DBHelper();
  Future<List<ReConfirmOrderModel>> getReConfirmOrder() async{
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderDetailsTableName,columns: ['id','product','quantity','inStock','rate','amount','orderMasterId' ]);
    List<ReConfirmOrderModel> reconfirmorder = [];
    for(int i = 0; i<maps.length; i++)
    {
      reconfirmorder.add(ReConfirmOrderModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('OrderDetails Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return reconfirmorder;
  }
  Future<int> add(ReConfirmOrderModel reconfirmorderModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.insert(orderDetailsTableName, reconfirmorderModel.toMap());
  }
  Future<int> update(ReConfirmOrderModel reconfirmorderModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderDetailsTableName, reconfirmorderModel.toMap(),
        where: 'id = ?', whereArgs: [reconfirmorderModel.id]);
  }
  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderDetailsTableName,
        where: 'id = ?', whereArgs: [id]);
  }
}