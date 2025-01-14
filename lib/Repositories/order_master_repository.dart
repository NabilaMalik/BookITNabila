import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/order_details_repository.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/order_master_model.dart';

class OrderMasterRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
  OrderDetailsRepository orderDetailsRepository = Get.put(OrderDetailsRepository());
OrderDetailsViewModel orderDetailsViewModel =Get.put(OrderDetailsViewModel());
  Future<List<OrderMasterModel>> getConfirmOrder() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderMasterTableName, columns: [
      'orderMasterId',
      'shopName',
      'ownerName',
      'phoneNumber',
      'ownerName',
      'total',
      'creditLimit',
      'requiredDelivery'
    ]);
    List<OrderMasterModel> confirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      confirmorder.add(OrderMasterModel.fromMap(maps[i]));
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

  Future<int> add(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(orderMasterTableName, confirmorderModel.toMap());
  }

  Future<int> update(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(orderMasterTableName, confirmorderModel.toMap(),
        where: 'orderMasterId = ?', whereArgs: [confirmorderModel.orderMasterId]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(orderMasterTableName, where: 'orderMasterId = ?', whereArgs: [id]);
  }

}
