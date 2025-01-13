import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/products_model.dart';
import '../Models/order_details_model.dart';
import '../ViewModels/order_master_view_model.dart';
import '../ViewModels/shop_visit_view_model.dart';

class OrderDetailsRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  Future<List<OrderDetailsModel>> getReConfirmOrder() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderDetailsTableName, columns: [
      'id',
      'product',
      'quantity',
      'inStock',
      'rate',
      'amount',
      'orderMasterId'
    ]);
    List<OrderDetailsModel> reconfirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      reconfirmorder.add(OrderDetailsModel.fromMap(maps[i]));
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

  Future<int> add(OrderDetailsModel orderDetailsModel) async {
    var dbClient = await dbHelper.db;
    int result = await dbClient.insert(orderDetailsTableName, orderDetailsModel.toMap());
    if (kDebugMode) {
      print('Inserted OrderDetailsModel: ${orderDetailsModel.toMap()}');
    }
    return result;
  }

  Future<int> update(OrderDetailsModel orderDetailsModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderDetailsTableName, orderDetailsModel.toMap(),
        where: 'id = ?', whereArgs: [orderDetailsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderDetailsTableName, where: 'id = ?', whereArgs: [id]);
  }

}
