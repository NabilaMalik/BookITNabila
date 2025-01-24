import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'  show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DBHelper extends GetxService{
 /// In Dart, the underscore (_) at the beginning of a variable or method name indicates private access.
  /// This means the variable or method is only accessible within the file in which it is declared.
  /// Like Encapsulation process

  static Database? _db;
  Future<Database> get db async{
    if(_db != null)
    {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async{
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,'bookIt.db');
    var db = openDatabase(path,version: 1,onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version){
    // Database Table
    db.execute("CREATE TABLE $addShopTableName(shop_id TEXT PRIMARY KEY, shop_date TEXT, shop_time TEXT, shop_name TEXT,city TEXT,shop_address TEXT,owner_name TEXT,owner_cnic TEXT,phone_no TEXT, alternative_phone_no TEXT, user_id TEXT, posted INTEGER DEFAULT 0 )");
    db.execute("CREATE TABLE $shopVisitMasterTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT, shop_visit_time TEXT, brand TEXT, shop_name TEXT, shop_address TEXT, owner_name TEXT, booker_name TEXT,walk_through TEXT,planogram TEXT,signage TEXT,product_reviewed TEXT,feedback TEXT,body BLOB)");
    db.execute("CREATE TABLE $shopVisitDetailsTableName(shop_visit_details_id TEXT PRIMARY KEY, shop_visit_details_date TEXT, shop_visit_details_time TEXT, shop_visit_master_id TEXT, product TEXT, quantity TEXT, FOREIGN KEY(shop_visit_master_id) REFERENCES $shopVisitMasterTableName(shop_visit_master_id))");
    db.execute("CREATE TABLE $orderMasterTableName(order_master_id TEXT PRIMARY KEY, order_master_date TEXT, order_master_time TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, required_delivery_date TEXT)");
    db.execute("CREATE TABLE $orderDetailsTableName (order_details_id TEXT PRIMARY KEY, order_details_date TEXT, order_details_time TEXT, order_master_id TEXT, product TEXT, quantity TEXT, in_stock TEXT, rate TEXT, amount TEXT, FOREIGN KEY(order_master_id) REFERENCES $orderMasterTableName(order_master_id))");
    db.execute("CREATE TABLE $returnFormMasterTableName(return_master_id TEXT PRIMARY KEY, return_master_date TEXT, return_master_time TEXT, select_shop TEXT)");
    db.execute("CREATE TABLE $returnFormDetailsTableName(return_details_id TEXT PRIMARY KEY, return_details_date TEXT, return_details_time TEXT, return_master_id TEXT, item TEXT, quantity TEXT, reason TEXT, FOREIGN KEY(return_master_id) REFERENCES $returnFormMasterTableName(return_master_id))");
    db.execute("CREATE TABLE $recoveryFormTableName(recovery_id TEXT PRIMARY KEY, recovery_date TEXT, recovery_time TEXT shop_name TEXT,current_balance TEXT,cash_recovery TEXT,net_balance TEXT,date TEXT)");
    db.execute("CREATE TABLE $attendanceTableName(attendance_in_id TEXT PRIMARY KEY, attendance_in_date TEXT, attendance_in_time TEXT, time_in TEXT, user_id TEXT, lat_in TEXT, lng_in TEXT, booker_name TEXT,designation, city TEXT, address TEXT)");
    db.execute("CREATE TABLE $attendanceOutTableName(attendance_out_id TEXT PRIMARY KEY, attendance_out_date TEXT, attendance_out_time TEXT, time_out TEXT, total_time TEXT, user_id TEXT, lat_out TEXT, lng_out TEXT, total_distance TEXT, address TEXT)");
    db.execute("CREATE TABLE $locationTableName(location_id TEXT PRIMARY KEY, location_date TEXT, location_time TEXT, file_name TEXT, user_id TEXT, total_distance TEXT, booker_name TEXT, posted INTEGER DEFAULT 0, body BLOB)");

    db.execute("CREATE TABLE $productsTableName(id NUMBER PRIMARY KEY, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT, in_stock TEXT)");

  }

}

