import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DBHelper extends GetxService {
  /// In Dart, the underscore (_) at the beginning of a variable or method name indicates private access.
  /// This means the variable or method is only accessible within the file in which it is declared.
  /// Like Encapsulation process

  static Database? _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'bookIt.db');
    var db = openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    // Database Table
    List<String> tableQueries = [
      "CREATE TABLE IF NOT EXISTS $tableNameLogin(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,RSM TEXT,SM TEXT,NSM TEXT,RSM_ID TEXT,SM_ID TEXT,NSM_ID TEXT,images BLOB)",
      "CREATE TABLE IF NOT EXISTS $addShopTableName(shop_id TEXT PRIMARY KEY, shop_date TEXT, shop_time TEXT, shop_name TEXT,city TEXT,shop_address TEXT,owner_name TEXT,owner_cnic TEXT,phone_no TEXT, alternative_phone_no TEXT, user_id TEXT, posted INTEGER DEFAULT 0 )",
      "CREATE TABLE IF NOT EXISTS $shopVisitMasterTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT, shop_visit_time TEXT, brand TEXT,user_id TEXT, shop_name TEXT, shop_address TEXT, owner_name TEXT,posted INTEGER DEFAULT 0, booker_name TEXT,walk_through TEXT,planogram TEXT,signage TEXT,product_reviewed TEXT,feedback TEXT,body BLOB)",
      "CREATE TABLE IF NOT EXISTS $shopVisitDetailsTableName(shop_visit_details_id TEXT PRIMARY KEY, shop_visit_details_date TEXT, shop_visit_details_time TEXT,user_id TEXT, shop_visit_master_id TEXT, product TEXT, quantity TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(shop_visit_master_id) REFERENCES $shopVisitMasterTableName(shop_visit_master_id))",
      "CREATE TABLE IF NOT EXISTS $orderMasterTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderMasterStatusTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderDetailsTableName (order_details_id TEXT PRIMARY KEY, order_details_date TEXT, order_details_time TEXT,user_id TEXT, order_master_id TEXT, product TEXT, quantity TEXT, in_stock TEXT, rate TEXT,posted INTEGER DEFAULT 0, amount TEXT, FOREIGN KEY(order_master_id) REFERENCES $orderMasterTableName(order_master_id))",
      "CREATE TABLE IF NOT EXISTS $returnFormMasterTableName(return_master_id TEXT PRIMARY KEY, return_amount TEXT,return_master_date TEXT,user_id TEXT, return_master_time TEXT, posted INTEGER DEFAULT 0,select_shop TEXT)",
      "CREATE TABLE IF NOT EXISTS $returnFormDetailsTableName(return_details_id TEXT PRIMARY KEY, return_details_date TEXT, return_details_time TEXT,user_id TEXT, return_master_id TEXT, item TEXT, quantity TEXT, reason TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(return_master_id) REFERENCES $returnFormMasterTableName(return_master_id))",
      "CREATE TABLE IF NOT EXISTS $recoveryFormTableName(recovery_id TEXT PRIMARY KEY, recovery_date TEXT, recovery_time TEXT, shop_name TEXT,user_id TEXT,current_balance TEXT,cash_recovery TEXT,net_balance TEXT,posted INTEGER DEFAULT 0)",
      "CREATE TABLE IF NOT EXISTS $attendanceTableName(attendance_in_id TEXT PRIMARY KEY, attendance_in_date TEXT, attendance_in_time TEXT,user_id TEXT, lat_in TEXT, lng_in TEXT, booker_name TEXT,designation, city TEXT,posted INTEGER DEFAULT 0, address TEXT)",
      "CREATE TABLE IF NOT EXISTS $attendanceOutTableName(attendance_out_id TEXT PRIMARY KEY, attendance_out_date TEXT, attendance_out_time TEXT,  total_time TEXT, user_id TEXT, lat_out TEXT, lng_out TEXT, total_distance TEXT,posted INTEGER DEFAULT 0, address TEXT)",
      "CREATE TABLE IF NOT EXISTS $locationTableName(location_id TEXT PRIMARY KEY, location_date TEXT, location_time TEXT, file_name TEXT, user_id TEXT, total_distance TEXT, booker_name TEXT, posted INTEGER DEFAULT 0, body BLOB)",
      "CREATE TABLE IF NOT EXISTS $productsTableName(id NUMBER, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT, in_stock TEXT)",
    ];
    for (var query in tableQueries) {
      await db.execute(query);
    }
  }
  Future<void> clearData() async {
    final db = await this.db; // Get the database instance

    // List of all table names to clear data
    List<String> tableNames = [
      // tableNameLogin,
      productsTableName
    ];

    for (var tableName in tableNames) {
      await db.execute("DELETE FROM $tableName");
    }
  }

}
