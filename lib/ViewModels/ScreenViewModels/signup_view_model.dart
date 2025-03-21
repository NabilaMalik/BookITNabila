import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/ScreenModels/signup_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class SignUpController extends GetxController {
  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyEmailController = TextEditingController();
  final owner_nameController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final phone_noController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // final projectIdController = TextEditingController();
  // final displayNameController = TextEditingController();
  // final parentTypeController = TextEditingController();
  // final parentIdController = TextEditingController();


  // SignupModel
  SignupModel? userModel;

  // Method to validate and save the form
  bool validateForm() {
    if (formKey.currentState!.validate()) {
      userModel = SignupModel(
        companyName: companyNameController.text,
        companyAddress: companyAddressController.text,
        companyEmail: companyEmailController.text,
        owner_name: owner_nameController.text,
        ownerEmail: ownerEmailController.text,
        phone_no: phone_noController.text,
        password: passwordController.text,
      );
      return true;
    }
    return false;
  }
  Future<void> createFirebaseProject(String projectId, String displayName, String parentType, String parentId) async {
    const url = 'https://createproject-zhlg46sckq-uc.a.run.app'; // Your Cloud Function URL
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'projectId': projectId,
        'displayName': displayName,
        'parentType': parentType,  // Pass parent type (organization or folder)
        'parentId': parentId        // Pass parent ID
      }),
    );

    if (response.statusCode == 200) {
      print('Project created: ${response.body}');
    } else {
      print('Failed to create project: ${response.body}');
    }
  }

  // Clean up controllers when the controller is disposed
  @override
  void onClose() {
    companyNameController.dispose();
    companyAddressController.dispose();
    companyEmailController.dispose();
    owner_nameController.dispose();
    ownerEmailController.dispose();
    phone_noController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
