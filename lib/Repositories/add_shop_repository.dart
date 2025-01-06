import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/add_shop_model.dart';

class AddShopRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  Future<List<AddShopModel>> getAddShop() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(addShopTableName, columns: [
      'id',
      'shopName',
      'city',
      'shopAddress',
      'ownerName',
      'ownerCNIC',
      'phoneNumber',
      'alterPhoneNumber',
      // 'isGPSEnabled'
    ]);
    List<AddShopModel> addShop = [];
    for (int i = 0; i < maps.length; i++) {
      addShop.add(AddShopModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from database:');
      for (var map in maps) {
        print(map);
      }
    }
    return addShop;
  }

  Future<int> add(AddShopModel addShopModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(addShopTableName, addShopModel.toMap());
  }

  Future<int> update(AddShopModel addShopModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(addShopTableName, addShopModel.toMap(),
        where: 'id = ?', whereArgs: [addShopModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(addShopTableName, where: 'id = ?', whereArgs: [id]);
  }
}
