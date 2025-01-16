import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/ScreenModels/signup_model.dart';

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
