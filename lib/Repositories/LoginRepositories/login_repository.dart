
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../Models/LoginModels/login_models.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Services/ApiServices/api_service.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class LoginRepository extends GetxService{

  DBHelper dbHelper = DBHelper();
  // Fetch a specific user by user_id and password
  Future<LoginModels?> getUserByCredentials(String userId, String password) async {
    var dbClient = await dbHelper.db;

    List<Map> maps = await dbClient.query(
        tableNameLogin,
        where: 'user_id = ? AND password = ?',
        whereArgs: [userId, password],
        columns: ['user_id', 'password' , 'city' ,'user_name', 'designation' , 'brand' ,  'images' ,'RSM','RSM_ID','SM','SM_ID','NSM','NSM_ID']
    );

    if (maps.isNotEmpty) {
      return LoginModels.fromMap(maps.first); // Return the first matching user
    }
    return null; // No user found
  }

  Future<List<LoginModels>> getLogin() async {
    // Get the database client
    var dbClient = await dbHelper.db;

    // Query the database
    List<Map> maps = await dbClient.query(
        tableNameLogin,
        columns: ['user_id', 'password' , 'city' ,'user_name', 'designation' , 'brand' ,  'images' ,'RSM','RSM_ID','SM','SM_ID','NSM','NSM_ID']
    );

    // Print the raw data retrieved from the database

      debugPrint('Raw data from database:');

    // ignore: unused_local_variable
    for (var map in maps) {

        debugPrint("$map");

    }

    // Convert the raw data into a list
    List<LoginModels> login = [];
    for (int i = 0; i < maps.length; i++) {
      login.add(LoginModels.fromMap(maps[i]));
    }

    // Print the list of

      debugPrint('Parsed LoginModels objects:');


    return login;
  }

  Future<void> fetchAndSaveLogin() async {
    await Config.fetchLatestConfig();
    // List<dynamic> data = await ApiService.getData(Config.getApiUrlLogin);
    // List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/valor_trading/login1/get");
    //  List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/alnoor_town/login/get/");
    List<dynamic> data = await ApiService.getData("https://cloud.metaxperts.net:8443/erp/valor_trading/login1/get/");
    var dbClient = await dbHelper.db;

    // Save data to local database
    for (var item in data) {
      LoginModels model = LoginModels.fromMap(item);
      await dbClient.insert(tableNameLogin, model.toMap());

      // Save data to Firebase Firestore
      await FirebaseFirestore.instance
          .collection('login')
          .doc(model.user_id?.toString()) // Convert int? to String?
          .set(model.toMap());
    }
  }

  Future<int>add(LoginModels loginModels) async{
    var dbClient = await dbHelper.db;
    return await dbClient.insert(tableNameLogin,loginModels.toMap());
  }

  Future<int>update(LoginModels loginModels) async{
    var dbClient = await dbHelper.db;
    return await dbClient.update(tableNameLogin,loginModels.toMap(),
        where: 'user_id = ?', whereArgs: [loginModels.user_id]);

  }

  Future<int>delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(tableNameLogin,
        where: 'user_id = ?', whereArgs: [id]);
  }
  // Future<List<String>> getBookerNamesByRSMDesignation() async {
  //   var dbClient = await dbHelper.db;
  //
  //   final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
  //     'login',
  //     where: 'RSM_ID = ?',
  //     whereArgs: [userId],
  //   );
  //   return bookerNames.map((map) => map['user_id'] as String).toList();
  //
  // }Future<List<String>> getBookerNamesBySMDesignation() async {
  //   var dbClient = await dbHelper.db;
  //
  //   final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
  //     'login',
  //     where: 'SM_ID = ?',
  //     whereArgs: [userId],
  //   );
  //   return bookerNames.map((map) => map['user_id'] as String).toList();
  //
  // }
  // Future<List<String>> getBookerNamesByNSMDesignation() async {
  //   var dbClient = await dbHelper.db;
  //
  //   final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
  //     'login',
  //     where: 'NSM_ID = ?',
  //     whereArgs: [userId],
  //   );
  //   return bookerNames.map((map) => map['user_id'] as String).toList();
  //
  // }
}