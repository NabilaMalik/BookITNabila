import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/LoginModels/login_models.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Repositories/LoginRepositories/login_repository.dart';


class LoginViewModel extends GetxController {

  var allLogin = <LoginModels>[].obs;
  LoginRepository loginRepository = LoginRepository();
  DBHelper dbHelper = Get.put(DBHelper());
  var isAuthenticated = false.obs; // To track login status

  @override
  void onInit(){
    // TODO: implement onInit
    super.onInit();
    //fetchAllLight();
    _checkInternetBeforeNavigation();
  }
  // Method to check the internet connection before navigating to the login page
  Future<void> _checkInternetBeforeNavigation() async {
    bool hasInternet = await checkInternetConnection();

    if (!hasInternet) {


      // Show a GetX Snackbar with an internet error message
      Get.snackbar(
        'Internet Error',
        'No internet connection. The app will close shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Delay for a few seconds before closing the app to allow user to see the message
      await Future.delayed(Duration(seconds: 5));
      exit(0); // Close the app if no internet connection
    } else {
      await fetchAndSaveLoginData();

    }
  }
  Future<void> checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated.value = prefs.getBool('isAuthenticated') ?? false;
  }
  // Future<bool> login(String userId, String password) async {
  //   await fetchAllLogin(); // Ensure the latest data is fetched
  //
  //   // Check if the user exists and password matches
  //   for (var loginModel in allLogin) {
  //     if (loginModel.user_id == userId && loginModel.password == password) {
  //       isAuthenticated.value = true; // Set login status
  //       return true; // Login successful
  //     }
  //   }
  //   isAuthenticated.value = false; // Set login status
  //   return false; // Login failed
  // }
  Future<bool> login(String userId, String password) async {
    final user = await loginRepository.getUserByCredentials(userId, password);

    if (user != null) {
      isAuthenticated.value = true; // Set login status to true

      // Save authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);

      return true; // Login successful
    }

    isAuthenticated.value = false; // Set login status to false
    return false; // Login failed
  }
   logout() async {
    isAuthenticated.value = false; // Set login status to false

    // Clear authentication state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove("userId");

    // Clear the data from all tables
    await dbHelper.clearData();
  }

  fetchAllLogin() async{
    var login = await loginRepository.getLogin();
    allLogin.value = login;
  }
  fetchAndSaveLoginData() async {
    await loginRepository.fetchAndSaveLogin();
    fetchAllLogin();
  }
  addLogin(LoginModels loginModels){
    loginRepository.add(loginModels);
  }

  updateLogin(LoginModels loginModels){
    loginRepository.update(loginModels);
    fetchAllLogin();
  }

  deleteLogin(int id){
    loginRepository.delete(id);
    fetchAllLogin();
  }

}

