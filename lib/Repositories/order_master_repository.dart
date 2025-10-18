import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/order_details_repository.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/order_master_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OrderMasterRepository extends GetxService {
  DBHelper dbHelper = Get.put(DBHelper());
  OrderDetailsRepository orderDetailsRepository = Get.put(OrderDetailsRepository());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
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
        debugPrint('Network available, syncing pending orders...');
        postDataFromDatabaseToAPI();
      }
    });
  }

  Future<void> syncLocalOrders(List<OrderMasterModel> orders) async {
    var dbClient = await dbHelper.db; // get the DB instance once
    for (var order in orders) {
      var existingOrders = await dbClient.query(
        orderMasterTableName,
        where: 'order_master_id = ?',
        whereArgs: [order.order_master_id],
      );

      if (existingOrders.isEmpty) {
        await add(order); // Insert if not exists
      } else {
        await update(order); // Update if exists
      }

      if (await isNetworkAvailable()) {
        await postShopToAPI(order);
        order.posted = 1;
        await update(order);
      }
    }
  }

  Future<List<OrderMasterModel>> getConfirmOrder() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(orderMasterTableName, columns: [
      'order_master_id',
      'order_master_date',
      'order_master_time',
      'shop_name',
      'owner_name',
      'phone_no',
      'owner_name',
      'order_status',
      'total',
      'user_id',
      'user_name',
      'credit_limit',
      'rsm_id',
      'sm_id',
      'nsm_id',
      'rsm',
      'sm',
      'nsm',
      'city',
      'required_delivery_date',
      'posted'
    ]);
    List<OrderMasterModel> confirmorder = [];
    for (int i = 0; i < maps.length; i++) {
      confirmorder.add(OrderMasterModel.fromMap(maps[i]));
    }

    debugPrint('Raw data from database:');
    for (var map in maps) {
      debugPrint("$map");
    }
    return confirmorder;
  }

  Future<void> fetchAndSaveOrderMaster() async {
    await Config.fetchLatestConfig();
    debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlOrderMaster}$user_id');
    List<dynamic> data = await ApiService.getData(
        '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlOrderMaster}$user_id'
    );
    var dbClient = await dbHelper.db;

    for (var item in data) {
      item['posted'] = 1;
      OrderMasterModel model = OrderMasterModel.fromMap(item);

      List<Map> existingRecords = await dbClient.query(
        orderMasterTableName,
        where: 'order_master_id = ?',
        whereArgs: [model.order_master_id],
      );

      if (existingRecords.isNotEmpty) {
        await dbClient.delete(
          orderMasterTableName,
          where: 'order_master_id = ?',
          whereArgs: [model.order_master_id],
        );

        debugPrint('Deleted existing record with order_master_id: ${model.order_master_id}');
      }

      await dbClient.insert(orderMasterTableName, model.toMap());

      debugPrint('Inserted new record with order_master_id: ${model.order_master_id}');
    }
  }

  Future<List<OrderMasterModel>> getUnPostedOrderMaster() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      orderMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],
    );

    List<OrderMasterModel> attendanceIn = maps.map((map) => OrderMasterModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    if (isSyncing.value) return; // Prevent multiple simultaneous syncs

    try {
      isSyncing(true);
      var unPostedShops = await getUnPostedOrderMaster();

      if (unPostedShops.isEmpty) {
        debugPrint('No unposted orders to sync');
        return;
      }

      if (await isNetworkAvailable()) {
        debugPrint('Syncing ${unPostedShops.length} unposted orders to server...');

        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);

            debugPrint('Order with id ${shop.order_master_id} posted and updated in local database.');
          } catch (e) {
            debugPrint('Failed to post order with id ${shop.order_master_id}: $e');
            // Continue with next order even if one fails
          }
        }

        debugPrint('Order sync completed successfully');
      } else {
        debugPrint('Network not available. Unposted orders will remain local.');
      }
    } catch (e) {
      debugPrint('Error fetching unposted orders: $e');
    } finally {
      isSyncing(false);
    }
  }

  Future<void> postShopToAPI(OrderMasterModel shop) async {
    try {
      await Config.fetchLatestConfig();

      debugPrint('Updated Shop Post API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlOrderMaster}');

      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlOrderMaster}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Order data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error posting order data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  /// ✅ FIX APPLIED HERE ONLY
  Future<int> add(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    int result = await dbClient.insert(
      orderMasterTableName,
      confirmorderModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // ✅ Prevents duplicate crash
    );

    // Auto-sync if network is available
    if (await isNetworkAvailable()) {
      await postDataFromDatabaseToAPI();
    }

    return result;
  }

  Future<int> update(OrderMasterModel confirmorderModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
      orderMasterTableName,
      confirmorderModel.toMap(),
      where: 'order_master_id = ?',
      whereArgs: [confirmorderModel.order_master_id],
    );
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(
      orderMasterTableName,
      where: 'order_master_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> getHighestSerialNo() async {
    int serial;

    final db = await dbHelper.db;
    final result = await db!.rawQuery('''
    SELECT order_master_id 
    FROM $orderMasterTableName
    WHERE user_id = ? AND order_master_id IS NOT NULL
  ''', [user_id]);

    if (result.isNotEmpty) {
      final serialNos = result.map((row) {
        final orderNo = row['order_master_id'] as String?;
        if (orderNo != null) {
          final parts = orderNo.split('-');
          if (parts.length > 2) {
            final serialNoPart = parts.last;
            if (serialNoPart.isNotEmpty) {
              return int.tryParse(serialNoPart);
            }
          }
        }
        return null;
      }).where((serialNo) => serialNo != null).cast<int>().toList();

      if (serialNos.isNotEmpty) {
        serial = serialNos.reduce(max);
        serial++;
        orderMasterHighestSerial = serial;
        if (kDebugMode) {
          print('Highest serial number orderMasterHighestSerial incremented to: $orderMasterHighestSerial');
        }
      } else {
        if (kDebugMode) {
          print('No valid order numbers found for this user');
        }
      }
    } else {
      if (kDebugMode) {
        print('No orders found for this user');
      }
    }
  }

  Future<void> serialNumberGeneratorApi() async {
    await Config.fetchLatestConfig();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlOrderMasterSerial}$user_id',
      maxColumnName: 'max(order_master_id)',
      serialType: orderMasterHighestSerial,
    );
    await orderDetailsGenerator.getAndIncrementSerialNumber();
    orderMasterHighestSerial = orderDetailsGenerator.serialType;
    await prefs.reload();
    await prefs.setInt("orderMasterHighestSerial", orderMasterHighestSerial!);
  }

  // New method to force sync all pending data
  Future<void> syncAllPendingData() async {
    await postDataFromDatabaseToAPI();
  }
}