import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

import 'package:sqflite/sqflite.dart' show Database, openDatabase;
import 'package:path/path.dart' show join;
import 'dart:io' as io;
import 'dart:async' show Future;

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'valorTrading.db');
    var db = await openDatabase(
      path,
      version: 4, // Increment the version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    try {
      if (kDebugMode) {
        print('Creating database...');
      }
      await db.execute(
          "CREATE TABLE login(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,images BLOB)");
      await db.execute(
          "CREATE TABLE orderBookingStatusData(order_no TEXT PRIMARY KEY, status TEXT, order_date TEXT, shop_name TEXT, amount TEXT, user_id TEXT, city TEXT,brand TEXT)");
      await db.execute(
          "CREATE TABLE ownerData(id NUMBER,shop_name TEXT, owner_name TEXT, phone_no TEXT, city TEXT, shop_address TEXT, created_date TEXT, user_id TEXT, images BLOB)");
      await db.execute(
          "CREATE TABLE products(id NUMBER PRIMARY KEY, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT)");
      await db.execute(
          "CREATE TABLE orderMasterData(order_no TEXT, shop_name TEXT, user_id TEXT)");
      await db.execute(
          "CREATE TABLE orderDetailsData(id INTEGER, order_no TEXT, product_name TEXT, quantity_booked INTEGER, user_id TEXT, price INTEGER)");
      await db.execute("CREATE TABLE productCategory(id INTEGER,brand TEXT)");
      await db.execute(
          "CREATE TABLE recoveryFormGet(recovery_id TEXT, user_id TEXT)");
      await db.execute(
          "CREATE TABLE accounts(account_id INTEGER PRIMARY KEY, shop_name TEXT, order_date TEXT, credit NUMBER, booker_name TEXT, user_id TEXT)");
      await db.execute(
          "CREATE TABLE netBalance(account_id INTEGER PRIMARY KEY, balance NUMBER)");
      await db.execute("CREATE TABLE pakCities(id INTEGER,city TEXT)");
      await db.execute(
          "CREATE TABLE shop(id INTEGER PRIMARY KEY AUTOINCREMENT, shopName TEXT, city TEXT, date TEXT, shopAddress TEXT, ownerName TEXT, ownerCNIC TEXT, phoneNo TEXT, alternativePhoneNo INTEGER, latitude TEXT, longitude TEXT, userId TEXT, posted INTEGER DEFAULT 0, body BLOB)");
      await db.execute(
          "CREATE TABLE orderMaster (orderId TEXT PRIMARY KEY, date TEXT, shopName TEXT, ownerName TEXT, phoneNo TEXT, brand TEXT, userName TEXT, userId TEXT, total INTEGER, creditLimit TEXT, requiredDelivery TEXT, shopCity TEXT, posted INTEGER DEFAULT 0)");
      await db.execute(
          "CREATE TABLE order_details(id INTEGER PRIMARY KEY AUTOINCREMENT, order_master_id TEXT, productName TEXT, quantity INTEGER, price INTEGER, amount INTEGER, userId TEXT, posted INTEGER DEFAULT 0, FOREIGN KEY (order_master_id) REFERENCES orderMaster(orderId))");
      await db.execute(
          "CREATE TABLE attendance(id INTEGER PRIMARY KEY, date TEXT, timeIn TEXT, userId TEXT, latIn TEXT, lngIn TEXT, bookerName TEXT, city TEXT, designation TEXT)");
      await db.execute(
          "CREATE TABLE attendanceOut(id INTEGER PRIMARY KEY, date TEXT, timeOut TEXT, totalTime TEXT, userId TEXT, latOut TEXT, lngOut TEXT, totalDistance TEXT, posted INTEGER DEFAULT 0)");
      await db.execute(
          "CREATE TABLE recoveryForm (recoveryId TEXT, date TEXT, shopName TEXT, cashRecovery REAL, netBalance REAL, userId TEXT, bookerName TEXT, city TEXT, brand TEXT)");
      await db.execute(
          "CREATE TABLE returnForm (returnId INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, shopName TEXT, returnAmount INTEGER, bookerId TEXT, bookerName TEXT, city TEXT, brand TEXT)");
      await db.execute(
          "CREATE TABLE return_form_details(id INTEGER PRIMARY KEY AUTOINCREMENT, returnFormId TEXT, productName TEXT, quantity TEXT, reason TEXT, bookerId TEXT, FOREIGN KEY (returnFormId) REFERENCES returnForm(returnId))");
      await db.execute(
          "CREATE TABLE shopVisit (id TEXT PRIMARY KEY, date TEXT, shopName TEXT, userId TEXT, city TEXT, bookerName TEXT, brand TEXT, walkthrough TEXT, planogram TEXT, signage TEXT, productReviewed TEXT, feedback TEXT, latitude TEXT, longitude TEXT, address TEXT, body BLOB)");
      await db.execute(
          "CREATE TABLE Stock_Check_Items(id INTEGER PRIMARY KEY AUTOINCREMENT, shopvisitId TEXT, itemDesc TEXT, qty TEXT, FOREIGN KEY (shopvisitId) REFERENCES shopVisit(id))");
      await db.execute(
          "CREATE TABLE location(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, fileName TEXT, userId TEXT, totalDistance TEXT, userName TEXT, posted INTEGER DEFAULT 0, body BLOB)");
      // Upgrade functionalities for version 2
      if (version >= 2) {
        if (kDebugMode) {
          print('Performing upgrade to version 2');
        }
        _onUpgrade(db, 1, version);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating database: $e');
      }
    }
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (kDebugMode) {
        print('Upgrading database from version $oldVersion to $newVersion');
      }
      if (oldVersion < 2) {
        if (kDebugMode) {
          print('Performing upgrade to version 2');
        }
        await db.execute(
            "CREATE TABLE shop_new (id INTEGER PRIMARY KEY AUTOINCREMENT, shopName TEXT, city TEXT, date TEXT, shopAddress TEXT, ownerName TEXT, ownerCNIC TEXT, phoneNo TEXT, alternativePhoneNo INTEGER, latitude TEXT, longitude TEXT, userId TEXT, posted INTEGER DEFAULT 0, address TEXT)");
        if (kDebugMode) {
          print('Created shop_new table');
        }
        await db.execute(
            "INSERT INTO shop_new (id, shopName, city, date, shopAddress, ownerName, ownerCNIC, phoneNo, alternativePhoneNo, latitude, longitude, userId, posted) SELECT id, shopName, city, date, shopAddress, ownerName, ownerCNIC, phoneNo, alternativePhoneNo, latitude, longitude, userId, posted FROM shop");
        if (kDebugMode) {
          print('Copied data to shop_new table');
        }
        await db.execute("DROP TABLE shop");
        if (kDebugMode) {
          print('Dropped old shop table');
        }
        await db.execute("ALTER TABLE shop_new RENAME TO shop");
        if (kDebugMode) {
          print('Renamed shop_new to shop');
        }
      }
      if (oldVersion < 3) {
        // Adding new columns RSM, SM, and NMS to the login table
        await db.execute("ALTER TABLE login ADD COLUMN RSM TEXT;");
        await db.execute("ALTER TABLE login ADD COLUMN SM TEXT;");
        await db.execute("ALTER TABLE login ADD COLUMN NSM TEXT;");
        await db.execute("ALTER TABLE login ADD COLUMN RSM_ID TEXT;");
        await db.execute("ALTER TABLE login ADD COLUMN SM_ID TEXT;");
        await db.execute("ALTER TABLE login ADD COLUMN NSM_ID TEXT;");
        if (kDebugMode) {
          print(
              'Added RSM, SM, NSM, RSM_ID, SM_ID and NSM_ID columns to login table');
        }
        await db.execute(
            "CREATE TABLE HeadsShopVisits(id TEXT PRIMARY KEY, date TEXT, shopName TEXT, userId TEXT, city TEXT, bookerName TEXT, feedback TEXT, address TEXT, bookerId TEXT)");
        if (kDebugMode) {
          print('Created HeadsShopVisits table');
        }
      }
      if (oldVersion < 4) {
        // Adding brand column to shop table
        await db.execute("ALTER TABLE shop ADD COLUMN brand TEXT;");
        if (kDebugMode) {
          print('Added brand column to shop table');
        }

        // Adding address column to attendance table
        await db.execute("ALTER TABLE attendance ADD COLUMN address TEXT;");
        if (kDebugMode) {
          print('Added address column to attendance table');
        }

        // Adding address column to attendanceOut table
        await db.execute("ALTER TABLE attendanceOut ADD COLUMN address TEXT;");
        if (kDebugMode) {
          print('Added address column to attendanceOut table');
        }
      }
      if (oldVersion < 5) {
        await db.execute(
            "ALTER TABLE order_details ADD COLUMN details_date TEXT;");
        await db.execute(
            "ALTER TABLE orderDetailsData ADD COLUMN details_date TEXT;");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error upgrading database: $e');
      }
    }
  }
}