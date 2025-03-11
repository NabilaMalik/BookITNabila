import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Models/ScreenModels/products_model.dart';
import '../../Services/ApiServices/api_service.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

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
      'quantity',
      'in_stock'
    ]);
    // // debugPrint the raw data retrieved from the database
    // if (kDebugMode) {
    //   debugPrint('Raw data from database:');
    // }
    // for (var map in maps) {
    //   if (kDebugMode) {
    //     debugPrint("$map");
    //   }
    // }
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
        'quantity',
        'in_stock'
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

  Future<void> fetchAndSaveProducts() async {
       debugPrint(Config.getApiUrlProducts);
      debugPrint('https://cloud.metaxperts.net:8443/erp/valor_trading/products/get/');
    try {
     // List<dynamic> data = await ApiService.getData(Config.getApiUrlProducts);
      List<dynamic> data = await ApiService.getData('https://cloud.metaxperts.net:8443/erp/test1/products/get/');
      var dbClient = await dbHelperProducts.db;

      // Save data to database
      for (var item in data) {
        item['posted'] = 1; // Set posted to 1
        ProductsModel model = ProductsModel.fromMap(item);
        await dbClient.insert(productsTableName, model.toMap());
      }
      getProductsModel();
    } catch (e) {
      debugPrint("Error fetching and saving products: $e");
    }
  }
}

