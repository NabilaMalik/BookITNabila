
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
        columns: ['id', 'user_id', 'user_name', 'contact', 'cnic', 'image', 'address', 'city', 'password']
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
        columns: ['id', 'user_id', 'user_name','contact','cnic','image','address','city','password']
    );

    // Print the raw data retrieved from the database
    if (kDebugMode) {
      print('Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }

    // Convert the raw data into a list
    List<LoginModels> login = [];
    for (int i = 0; i < maps.length; i++) {
      login.add(LoginModels.fromMap(maps[i]));
    }

    // Print the list of
    if (kDebugMode) {
      print('Parsed LoginModels objects:');
    }

    return login;
  }

  Future<void> fetchAndSaveLogin() async {
    await Config.fetchLatestConfig();
   // List<dynamic> data = await ApiService.getData(Config.getApiUrlLogin);
   // List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/valor_trading/login1/get");
   //  List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/alnoor_town/login/get/");
    List<dynamic> data = await ApiService.getData("https://cloud.metaxperts.net:8443/erp/alnoor_town/login/get/");
    var dbClient = await dbHelper.db;

    // Save data to local database
    for (var item in data) {
      LoginModels model = LoginModels.fromMap(item);
      await dbClient.insert(tableNameLogin, model.toMap());

      // Save data to Firebase Firestore
      await FirebaseFirestore.instance
          .collection('login')
          .doc(model.id?.toString()) // Convert int? to String?
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
        where: 'id = ?', whereArgs: [loginModels.id]);

  }

  Future<int>delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(tableNameLogin,
        where: 'id = ?', whereArgs: [id]);
  }
}