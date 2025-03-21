import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/home_screen.dart';

import '../ViewModels/ScreenViewModels/signup_view_model.dart';
import '../components/under_part.dart';
import 'Components/custom_button.dart';
import 'Components/custom_editable_menu_option.dart';
import 'Components/validators.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final SignUpController controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              _buildHeader(),
              _buildForm(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.blue,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 39,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'by creating an account',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 200.0),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  label: "Company Name",
                  icon: Icons.business,
                  controller: controller.companyNameController,
                  validator: (value) =>
                      Validators.validateTextField(value, "company name"),
                ),
                _buildTextField(
                  label: "Company Address",
                  icon: Icons.location_on,
                  controller: controller.companyAddressController,
                  validator: (value) =>
                      Validators.validateTextField(value, "company address"),
                ),
                _buildTextField(
                  label: "Company Email",
                  icon: Icons.email,
                  controller: controller.companyEmailController,
                  validator: Validators.validateEmail,
                ),
                _buildTextField(
                  label: "Owner Name",
                  icon: Icons.person_outline,
                  controller: controller.owner_nameController,
                  validator: (value) =>
                      Validators.validateTextField(value, "owner name"),
                ),
                _buildTextField(
                  label: "Owner Email",
                  icon: Icons.email_outlined,
                  controller: controller.ownerEmailController,
                  validator: Validators.validateEmail,
                ),
                _buildTextField(
                  label: "Phone Number",
                  icon: Icons.phone,
                  controller: controller.phone_noController,
                  validator: (value) =>
                      Validators.validateTextField(value, "phone number"),
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  label: "Password",
                  icon: Icons.lock,
                  controller: controller.passwordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),
                _buildTextField(
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  controller: controller.confirmPasswordController,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    controller.passwordController.text,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  height: size.height * 0.065,
                  width: size.width * 0.45,
                  onTap:  () async {
                    await controller.createFirebaseProject(
                    'my-new-project-12345',
                    'My Project New',
                    'folder' ,
                    '123456789012');
                  },
                  // onTap:  () => Get.to(() => const HomeScreen()),
                  // onTap: _handleRegistration,
                  buttonText: "Register",
                  gradientColors: const [Colors.blue, Colors.blue],
                ),
                const SizedBox(height: 10),
                UnderPart(
                  title: "Already have an account?",
                  navigatorText: "Login here",
                  onTap: () => Get.to(() => const LoginScreen()),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomEditableMenuOption(
      label: label,
      initialValue: controller.text,
      onChanged: (value) => controller.text = value,
      inputBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 1.0),

        //borderRadius: BorderRadius.circular(8),
      ),
      iconColor: Colors.blue,
      useBoxShadow: false,
      icon: icon,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  void _handleRegistration() {
    if (controller.validateForm()) {
      debugPrint("Registration Successful: \${controller.userModel}");
    }
  }
}
