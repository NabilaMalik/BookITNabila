import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Models/ScreenModels/products_model.dart';

class ProductsRepository extends GetxService{

  DBHelper dbHelperProducts = Get.put(DBHelper());

  Future<List<ProductsModel>> getProductsModel() async {
    var dbClient = await dbHelperProducts.db;
    List<Map> maps = await dbClient.query(productsTableName, columns: [
      'product_code',
      'product_name',
      'uom',
      'price',
      'brand',
      'quantity'
    ]);
    // Print the raw data retrieved from the database
    if (kDebugMode) {
      print('Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    List<ProductsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(ProductsModel.fromMap(maps[i]));
    }
    return products;
  }
  Future<int> add(ProductsModel productsModel) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient.insert(productsTableName, productsModel.toMap());
  }

  Future<List<ProductsModel>> getProductsByBrand(String brand) async {
    var dbClient = await dbHelperProducts.db;
    List<Map> maps = await dbClient.query(
      'products',
      columns: [
        'product_code',
        'product_name',
        'uom',
        'price',
        'brand',
        'quantity'
      ],
      where: 'brand = ?',
      whereArgs: [globalselectedbrand],
    );
    List<ProductsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(ProductsModel.fromMap(maps[i]));
    }
    return products;
  }

  Future<int> update(ProductsModel productsModel) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient.update(productsTableName, productsModel.toMap(),
       where: 'product_code = ?', whereArgs: [productsModel.product_code]);
  }

  Future<int> delete(int productCode) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient.delete(productsTableName,
        where: 'product_code = ?', whereArgs: [productCode]);
  }


}

