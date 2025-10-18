import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/HeadsShopVistModels.dart';
import '../Models/shop_visit_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ShopVisitRepository extends GetxService {
  DBHelper dbHelper = DBHelper();
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
        debugPrint('Network available, syncing pending shop visits...');
        postDataFromDatabaseToAPI();
        postDataFromDatabaseToAPIHeads();
      }
    });
  }

  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitMasterTableName, columns: [
      'shop_visit_master_id',
      'brand',
      'shop_visit_date',
      'shop_visit_time',
      'shop_name',
      'shop_address',
      'address',
      'owner_name',
      'booker_name',
      'walk_through',
      'planogram',
      'signage',
      'product_reviewed',
      'feedback',
      'user_id',
      'latitude',
      'longitude',
      'city',
      'posted',
      'body',
    ]);
    List<ShopVisitModel> shopvisit = [];
    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }

    debugPrint('Raw data from Shop Visit Table database:');
    for (var map in maps) {
      debugPrint("$map");
    }
    return shopvisit;
  }

  Future<void> fetchAndSaveShopVisit() async {
    debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopVisit}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopVisit}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ShopVisitModel model = ShopVisitModel.fromMap(item);
      await dbClient.insert(shopVisitMasterTableName, model.toMap());
    }
  }

  Future<List<ShopVisitModel>> getUnPostedShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      shopVisitMasterTableName,
      where: 'posted = ?',
      whereArgs: [0], // Fetch machines that have not been posted
    );

    List<ShopVisitModel> attendanceIn = maps.map((map) => ShopVisitModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    if (isSyncing.value) return; // Prevent multiple simultaneous syncs

    try {
      isSyncing(true);
      var unPostedShops = await getUnPostedShopVisit();

      if (unPostedShops.isEmpty) {
        debugPrint('No unposted shop visits to sync');
        return;
      }

      if (await isNetworkAvailable()) {
        debugPrint('Syncing ${unPostedShops.length} unposted shop visits to server...');

        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop, shop.body!);
            shop.posted = 1;
            await update(shop);

            debugPrint('Shop with id ${shop.shop_visit_master_id} posted and updated in local database.');
          } catch (e) {
            debugPrint('Failed to post shop with id ${shop.shop_visit_master_id}: $e');
            // Continue with next shop even if one fails
          }
        }

        debugPrint('Shop visit sync completed successfully');
      } else {
        debugPrint('Network not available. Unposted shops will remain local.');
      }
    } catch (e) {
      debugPrint('Error fetching unposted shops: $e');
    } finally {
      isSyncing(false);
    }
  }

  Future<void> postShopToAPI(ShopVisitModel shop, Uint8List imageBytes) async {
    try {
      await Config.fetchLatestConfig();
      debugPrint('API URL: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShopVisit}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShopVisit}"),
      );

      // Add all fields except 'body'
      shop.toMap().forEach((key, value) {
        if (key != 'body') {
          request.fields[key] = value.toString();
        }
      });

      // Add image file
      if (imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body', // Make sure this matches your API's expected field name
            imageBytes,
            filename: 'shop_visit_${shop.shop_visit_master_id}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Debug print request details
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Files count: ${request.files.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Shop data posted successfully. Response: $responseBody');
        await delete(shop.shop_visit_master_id!);
      } else {
        debugPrint('Failed to post shop. Status: ${response.statusCode}, Response: $responseBody');
        throw Exception('Server error: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      debugPrint('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  Future<int> add(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    int result = await dbClient.insert(shopVisitMasterTableName, shopvisitModel.toMap());

    // Auto-sync if network is available
    if (await isNetworkAvailable()) {
      await postDataFromDatabaseToAPI();
    }

    return result;
  }

  Future<int> addHeasdsShopVisits(HeadsShopVisitModel headsShopVisitModel) async {
    var dbClient = await dbHelper.db;
    int result = await dbClient.insert(headsShopVisitsTableName, headsShopVisitModel.toMap());

    // Auto-sync if network is available
    if (await isNetworkAvailable()) {
      await postDataFromDatabaseToAPIHeads();
    }

    return result;
  }

  Future<int> update(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(shopVisitMasterTableName, shopvisitModel.toMap(),
        where: 'shop_visit_master_id = ?', whereArgs: [shopvisitModel.shop_visit_master_id]);
  }

  Future<int> updateheads(HeadsShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(headsShopVisitsTableName, shopvisitModel.toMap(),
        where: 'shop_visit_master_id = ?', whereArgs: [shopvisitModel.shop_visit_master_id]);
  }

  Future<int> delete(String id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(shopVisitMasterTableName,
        where: 'shop_visit_master_id = ?', whereArgs: [id]);
  }

  Future<void> serialNumberGeneratorApi() async {
    await Config.fetchLatestConfig();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopVisitSerial}$user_id',
      maxColumnName: 'max(shop_visit_master_id)',
      serialType: shopVisitHighestSerial, // Unique identifier for shop visit serials
    );
    await orderDetailsGenerator.getAndIncrementSerialNumber();
    shopVisitHighestSerial = orderDetailsGenerator.serialType;
    await prefs.reload();
    await prefs.setInt("shopVisitHighestSerial", shopVisitHighestSerial!);
  }

  Future<void> serialNumberGeneratorApiHeads() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlShopVisitSerial}$user_id',
      maxColumnName: 'max(shop_visit_master_id)',
      serialType: shopVisitHeadsHighestSerial, // Unique identifier for shop visit serials
    );
    await orderDetailsGenerator.getAndIncrementSerialNumber();
    shopVisitHeadsHighestSerial = orderDetailsGenerator.serialType;
    await prefs.reload();
    await prefs.setInt("shopVisitHeadsHighestSerial", shopVisitHeadsHighestSerial!);
  }

  Future<List<HeadsShopVisitModel>> getUnPostedShopVisitHeads() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      headsShopVisitsTableName,
      where: 'posted = ?',
      whereArgs: [0], // Fetch machines that have not been posted
    );

    List<HeadsShopVisitModel> headsShopVisit = maps.map((map) => HeadsShopVisitModel.fromMap(map)).toList();
    return headsShopVisit;
  }

  Future<void> postDataFromDatabaseToAPIHeads() async {
    if (isSyncing.value) return; // Prevent multiple simultaneous syncs

    try {
      isSyncing(true);
      var unPostedShops = await getUnPostedShopVisitHeads();

      if (unPostedShops.isEmpty) {
        debugPrint('No unposted heads shop visits to sync');
        return;
      }

      if (await isNetworkAvailable()) {
        debugPrint('Syncing ${unPostedShops.length} unposted heads shop visits to server...');

        for (var shop in unPostedShops) {
          try {
            await postShopToAPIHeads(shop);
            shop.posted = 1;
            await updateheads(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.shop_visit_master_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.shop_visit_master_id}: $e');
            }
            // Continue with next shop even if one fails
          }
        }

        debugPrint('Heads shop visit sync completed successfully');
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

  Future<void> postShopToAPIHeads(HeadsShopVisitModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        print('Updated Shop Post API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShopVisitHeads}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlShopVisitHeads}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Shop data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  // New method to force sync all pending data
  Future<void> syncAllPendingData() async {
    await postDataFromDatabaseToAPI();
    await postDataFromDatabaseToAPIHeads();
  }
}