
import 'package:flutter/foundation.dart';

import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';

import '../../Models/add_shop_model.dart';

class RSMS_ShopRepository {

  DBHelper dbHelper = DBHelper();
  Future<List<AddShopModel>> getAddShop() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(addShopTableName, columns: [
      'shop_id',
      'shop_name',
      'city',
      'shop_date',
      'user_id',
      'shop_time',
      'shop_address',
      'owner_name',
      'owner_cnic',
      'phone_no',
      'alternative_phone_no',
      'posted'
    ]);
    List<AddShopModel> addShop = [];
    for (int i = 0; i < maps.length; i++) {
      addShop.add(AddShopModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Shop Raw data from database:');
    }
    for (var map in maps) {
      // debugPrint("$map");
    }
    return addShop;
  }
}