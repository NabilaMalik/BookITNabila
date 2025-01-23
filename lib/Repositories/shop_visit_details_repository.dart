import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_details_model.dart';


class ShopVisitDetailsRepository extends GetxService{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitDetailsModel>> getShopVisitDetails() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitDetailsTableName, columns: [
      'shop_visit_details_id',
      'shop_visit_details_date',
      'shop_visit_details_time',
      'product',
      'quantity',
      'shop_visit_master_id',
    ]);
    List<ShopVisitDetailsModel> shopvisitdetails = [];
    for (int i = 0; i < maps.length; i++) {
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

  Future<int> add(ShopVisitDetailsModel shopvisitdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        shopVisitDetailsTableName, shopvisitdetailsModel.toMap());
  }

  Future<int> update(ShopVisitDetailsModel shopvisitdetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        shopVisitDetailsTableName, shopvisitdetailsModel.toMap(),
        where: 'shop_visit_details_id = ?',
        whereArgs: [shopvisitdetailsModel.shop_visit_details_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(shopVisitDetailsTableName, where: 'shop_visit_details_id = ?', whereArgs: [id]);
  }

}
