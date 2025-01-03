import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_details_model.dart';

class ShopVisitDetailsRepository{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitDetailsModel>> getShopVisitDetails() async{
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitDetailsTableName,columns: ['id','product','quantity','shopVisitMasterId',]);
    List<ShopVisitDetailsModel> shopvisitdetails = [];
    for(int i = 0; i<maps.length; i++)
    {
      shopvisitdetails.add(ShopVisitDetailsModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print(' Raw data from Shop Visit Details database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return shopvisitdetails;
  }
  Future<int> add(ShopVisitDetailsModel shopvisitdetailsModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.insert(shopVisitDetailsTableName, shopvisitdetailsModel.toMap());
  }
  Future<int> update(ShopVisitDetailsModel shopvisitdetailsModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient.update(shopVisitDetailsTableName, shopvisitdetailsModel.toMap(),
        where: 'id = ?', whereArgs: [shopvisitdetailsModel.id]);
  }
  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(shopVisitDetailsTableName,
        where: 'id = ?', whereArgs: [id]);
  }
}