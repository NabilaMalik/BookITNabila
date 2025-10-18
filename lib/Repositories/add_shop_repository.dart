import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/add_shop_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddShopRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        // Network is available, sync all pending data
        debugPrint('Network available, syncing pending shops...');
        postDataFromDatabaseToAPI();
      }
    });
  }

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
      'address',
      'owner_name',
      'owner_cnic',
      'phone_no',
      'alternative_phone_no',
      'latitude',
      'longitude',
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
      debugPrint("$map");
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
        where: 'shop_id = ?', whereArgs: [addShopModel.shop_id]);
  }

  Future<int> delete(String? id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(addShopTableName, where: 'shop_id = ?', whereArgs: [id]);
  }

  Future<void> addAddShop(
      AddShopModel addShopModel, RxList<AddShopModel> allAddShop) async {
    await add(addShopModel);
    // Auto-sync if network is available
    if (await isNetworkAvailable()) {
      await postDataFromDatabaseToAPI();
    }
  }

  Future<void> updateAddShop(
      AddShopModel addShopModel, RxList<AddShopModel> allAddShop) async {
    await update(addShopModel);
    // Auto-sync if network is available
    if (await isNetworkAvailable()) {
      await postDataFromDatabaseToAPI();
    }
  }

  Future<void> deleteAddShop(
      String? id, RxList<AddShopModel> allAddShop) async {
    await delete(id);
  }

  Future<List<String>> fetchCitiesFromApi() async {
    String url = "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlCities}";
    List<dynamic> data = await ApiService.getData(url);
    List<String> fetchedCities = data.map((city) => city.toString()).toList();

    List<String> storedCities = await getCitiesFromSharedPreferences();
    List<String> newCities =
    fetchedCities.where((city) => !storedCities.contains(city)).toList();
    List<String> removedCities =
    storedCities.where((city) => !fetchedCities.contains(city)).toList();

    storedCities.addAll(newCities);
    removedCities.forEach((city) => storedCities.remove(city));

    await saveCitiesToSharedPreferences(storedCities);
    return storedCities;
  }

  Future<void> saveCitiesToSharedPreferences(List<String> cities) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cities', cities);
  }

  Future<List<String>> getCitiesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cities') ?? [];
  }

  Future<List<String>> fetchCities() async {
    List<String> cities = await getCitiesFromSharedPreferences();
    if (cities.isEmpty) {
      cities = await fetchCitiesFromApi();
    }
    return cities;
  }

  Future<void> fetchAndSaveShops() async {
    await Config.fetchLatestConfig();
    List<dynamic> data = await ApiService.getData(
        '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopsUserId}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      AddShopModel model = AddShopModel.fromMap(item);
      await dbClient.insert(addShopTableName, model.toMap());
    }
  }

  Future<void> fetchAndSaveShopsForHeads() async {
    await Config.fetchLatestConfig();
    List<dynamic> data = await ApiService.getData(
        '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShops}'
    );
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      AddShopModel model = AddShopModel.fromMap(item);
      await dbClient.insert(addShopTableName, model.toMap());
    }
  }

  // Fetch all unposted shops (posted = 0)
  Future<List<AddShopModel>> getUnPostedShops() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      addShopTableName,
      where: 'posted = ?',
      whereArgs: [0], // Fetch shops that have not been posted
    );

    List<AddShopModel> unpostedShops =
    maps.map((map) => AddShopModel.fromMap(map)).toList();
    return unpostedShops;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    if (isSyncing.value) return; // Prevent multiple simultaneous syncs

    try {
      isSyncing(true);
      var unPostedShops = await getUnPostedShops();

      if (unPostedShops.isEmpty) {
        debugPrint('No unposted shops to sync');
        return;
      }

      if (await isNetworkAvailable()) {
        debugPrint('Syncing ${unPostedShops.length} unposted shops to server...');

        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.shop_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.shop_id}: $e');
            }
            // Continue with next shop even if one fails
          }
        }

        debugPrint('Shop sync completed successfully');
      } else {
        if (kDebugMode) {
          print('Network not available. Unposted shops will remain local.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching unposted shops: $e');
      }
    } finally {
      isSyncing(false);
    }
  }

  Future<void> postShopToAPI(AddShopModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        print('Updated Shop Post API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShops}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShops}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Shop data posted successfully: $shopData');
      } else {
        throw Exception(
            'Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  Future<void> serialNumberGeneratorApi() async {
    await Config.fetchLatestConfig();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopSerial}$user_id',
      maxColumnName: 'max(shop_id)',
      serialType: shopHighestSerial, // Unique identifier for shop visit serials
    );
    await orderDetailsGenerator.getAndIncrementSerialNumber();
    shopHighestSerial = orderDetailsGenerator.serialType;
    await prefs.setInt("shopHighestSerial", shopHighestSerial!);
  }

  // New method to force sync all pending data
  Future<void> syncAllPendingData() async {
    await postDataFromDatabaseToAPI();
  }
}