import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../Repositories/ScreenRepositories/login_repository.dart';


class LoginController extends GetxController {
  // final LoginRepository userRepository;
  //
  // LoginController(this.userRepository);

  // State variables
  var email = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs;
  var isChecked = true.obs;
  var isLoading = false.obs;
  var isAuthenticated = false.obs; // To track login status

  final formKey = GlobalKey<FormState>();

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle "Remember Me" checkbox
  void toggleRememberMe(bool? value) {
    isChecked.value = value ?? false;
  }
  Future<void> checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated.value = prefs.getBool('isAuthenticated') ?? false;
  }
  // // Login logic
  // Future<String?> validateAndLogin() async {
  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();
  //     isLoading.value = true;
  //
  //     bool userExists = await userRepository.isUserRegistered(email.value);
  //     if (userExists==true) {
  //       isAuthenticated.value = true; // Set login status to true
  //
  //       // Save authentication state
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('isAuthenticated', true);
  //
  //       return 'Account existed'; // Login successful
  //     }
  //     isLoading.value = false;
  //
  //     if (!userExists) {
  //       return 'Account does not exist. Please sign up first.';
  //     }
  //
  //     return null; // Login successful
  //   }
  //   return 'Please fill in all required fields.';
  // }
}
