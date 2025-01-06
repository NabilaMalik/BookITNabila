// lib/screens/add_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/Components/custom_switch.dart';
import 'package:order_booking_app/screens/home_screen.dart';

import '../ViewModels/ScreenViewModels/add_shop_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_dropdown.dart';

class AddShopScreen extends StatelessWidget {
  final AddShopViewModel _viewModel = Get.put(AddShopViewModel());

  AddShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Add Shop',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: "Shop Name",
                    icon: Icons.store,
                    onChanged: (value) => _viewModel.setShopField('name', value),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter shop name" : null,
                  ),
                  CustomDropdown(
                    borderColor: Colors.black,
                    iconColor: Colors.blue,
                    label: "City",
                    useBoxShadow: false,
                    icon: Icons.location_city,
                    items: _viewModel.cities,
                    selectedValue: _viewModel.selectedCity.value,
                    onChanged: (value){
                    },
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter City name" : null,
                    // showBorder: true,

                  ),
                  _buildTextField(
                    label: "Shop Address",
                    icon: Icons.place,
                    onChanged: (value) => _viewModel.setShopField('address', value),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter shop address" : null,
                  ),
                  _buildTextField(
                    label: "Owner Name",
                    icon: Icons.person,
                    onChanged: (value) => _viewModel.setShopField('ownerName', value),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter owner name" : null,
                  ),
                  _buildTextField(
                    label: "Owner CNIC",
                    icon: Icons.badge,
                    onChanged: (value) => _viewModel.setShopField('ownerCnic', value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter CNIC";
                      }
                      const cnicPattern = r'^\d{5}-\d{7}-\d{1}\$';
                      if (!RegExp(cnicPattern).hasMatch(value)) {
                        return "Please enter a valid CNIC (e.g., 12345-1234567-1)";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    label: "Phone Number",
                    icon: Icons.phone,
                    onChanged: (value) => _viewModel.setShopField('phoneNumber', value),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter phone number" : null,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    label: "Alternative Phone Number",
                    icon: Icons.phone_android,
                    onChanged: (value) => _viewModel.setShopField('alternativePhoneNumber', value),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter alternative number" : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  Obx(() => CustomSwitch(
                    label: "GPS Enabled",
                    value: _viewModel.shop.isGpsEnabled,
                    onChanged: (value) => _viewModel.setShopField('isGpsEnabled', value),
                  )),
                  const SizedBox(height: 10),
                  CustomButton(
                    buttonText: "Save",
                    onTap: _viewModel.saveForm,
                    gradientColors: [Colors.blue, Colors.blue],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a custom text field with validation.
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }


}
