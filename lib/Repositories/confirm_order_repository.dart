import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/confirm_order_model.dart';
class ConfirmOrderRepository{

  DBHelper dbHelper = DBHelper();

  Future<List<ConfirmOrderModel>> getConfirmOrder() async{
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderMasterTableName,columns: ['orderMasterId','shopName','ownerName','phoneNumber','ownerName','total','creditLimit','requiredDelivery' ]);
    List<ConfirmOrderModel> confirmorder = [];
    for(int i = 0; i<maps.length; i++)
    {
      confirmorder.add(ConfirmOrderModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return confirmorder;

  }

  Future<int> add(ConfirmOrderModel confirmorderModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.insert(orderMasterTableName, confirmorderModel.toMap());
  }

  Future<int> update(ConfirmOrderModel confirmorderModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderMasterTableName, confirmorderModel.toMap(),
        where: 'id = ?', whereArgs: [confirmorderModel.orderMasterId]);
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderMasterTableName,
        where: 'id = ?', whereArgs: [id]);
  }

}