
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'  show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DBHelper{
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
    db.execute("CREATE TABLE $addShopTableName(id INTEGER PRIMARY KEY, shopName TEXT,city SELECTED,shopAddress TEXT,ownerName TEXT,ownerCNIC TEXT,phoneNumber TEXT, alterPhoneNumber TEXT )");
    db.execute("CREATE TABLE $shopVisitMasterTableName(shopVisitMasterId INTEGER PRIMARY KEY, brand TEXT, shopName TEXT, shopAddress TEXT, ShopOwner TEXT, bookerName TEXT,walkthrough TEXT,planogram TEXT,signage TEXT,productReviewed TEXT,feedback TEXT,body BLOB)");
    db.execute("CREATE TABLE $shopVisitDetailsTableName(id INTEGER PRIMARY KEY, shopVisitMasterId INTEGER, product TEXT, quantity TEXT, FOREIGN KEY(shopVisitMasterId) REFERENCES $shopVisitMasterTableName(shopVisitMasterId))");
    db.execute("CREATE TABLE $orderMasterTableName(orderMasterId INTEGER PRIMARY KEY,shopName TEXT,ownerName TEXT, phoneNumber TEXT,brand TEXT,total INGEGER, creditLimit TEXT, requiredDelivery TEXT)");
    db.execute("CREATE TABLE $orderDetailsTableName (id INTEGER PRIMARY KEY,orderMasterId INTEGER, product TEXT, quantity TEXT, inStock INTEGER, rate TEXT, amount TEXT, FOREIGN KEY(orderMasterId) REFERENCES $orderMasterTableName(orderMasterId))");
    db.execute("CREATE TABLE $returnFormMasterTableName(returnMasterId INTEGER PRIMARY KEY, selectShop TEXT)");
    db.execute("CREATE TABLE $returnFormDetailsTableName(id INTEGER PRIMARY KEY, returnMasterId INTEGER, item TEXT, qty INTEGER, reason TEXT, FOREIGN KEY(returnMasterId) REFERENCES $returnFormMasterTableName(returnMasterId))");
    db.execute("CREATE TABLE $recoveryFormTableName(id INTEGER PRIMARY KEY, shopName TEXT,currentBalance TEXT,cashRecovery TEXT,newBalance TEXT,date TEXT)");
    db.execute("CREATE TABLE $attendanceTableName(id INTEGER PRIMARY KEY, date TEXT, timeIn TEXT, userId TEXT, latIn TEXT, lngIn TEXT, bookerName TEXT,designation, city TEXT, address TEXT)");
    db.execute("CREATE TABLE $attendanceOutTableName(id INTEGER PRIMARY KEY, date TEXT, timeOut TEXT, totalTime TEXT, userId TEXT, latOut TEXT, lngOut TEXT, totalDistance TEXT, address TEXT)");
    db.execute("CREATE TABLE $locationTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, fileName TEXT, userId TEXT, totalDistance TEXT, userName TEXT, posted INTEGER DEFAULT 0, body BLOB)");
  }

}

