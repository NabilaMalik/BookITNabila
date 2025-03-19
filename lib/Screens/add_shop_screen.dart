// lib/screens/add_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/Components/custom_switch.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import '../ViewModels/add_shop_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_dropdown_second.dart';
import 'Components/validators.dart';

class AddShopScreen extends StatelessWidget {
  final AddShopViewModel _viewModel = Get.put(AddShopViewModel());

  final LocationViewModel locationViewModel = Get.put(LocationViewModel());
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
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                    onChanged: (value) =>
                        _viewModel.setShopField('shop_name', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter shop name"
                        : null,
                  ),
                  Obx(() => CustomDropdownSecond(
                        borderColor: Colors.black,
                        iconColor: Colors.blue,

                        label: "City",
                        useBoxShadow: false,
                        icon: Icons.location_city,
                        items: _viewModel.cities.value,
                        selectedValue: _viewModel.selectedCity.value.isNotEmpty
                            ? _viewModel.selectedCity.value
                            : 'Select a City',
                        onChanged: (value) =>
                            _viewModel.setShopField('city', value),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter City name"
                            : null,
                        textStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black), // ✅ Adjust font size
                      )),
                  _buildTextField(
                    label: "Shop Address",
                    icon: Icons.place,
                    onChanged: (value) =>
                        _viewModel.setShopField('shop_address', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter shop address"
                        : null,
                  ),
                  _buildTextField(
                    label: "Owner Name",
                    icon: Icons.person,
                    onChanged: (value) =>
                        _viewModel.setShopField('owner_name', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter owner name"
                        : null,
                  ),

                  _buildTextField(
                    label: "CNIC",
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CNICInputFormatter()],
                    validator: Validators.validateCNIC,
                    onChanged: (value) {
                      // Handle CNIC value if needed
                      _viewModel.setShopField('cnic', value);
                    },
                  ),


                  _buildTextField(
                    label: "Phone Number",
                    icon: Icons.phone,
                    onChanged: (value) => _viewModel.setShopField('phone_no', value),
                    validator: Validators.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                  ),



                  _buildTextField(
                    label: "Alternative Phone Number",
                    icon: Icons.phone_android,
                    onChanged: (value) =>
                        _viewModel.setShopField('alternative_phone_no', value),
                    validator: Validators.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                  ),
                  const SizedBox(height: 10),
                  // Use Obx to reactively update CustomSwitch
                  Obx(() => CustomSwitch(
                        label: "GPS Enabled",
                        value: locationViewModel.isGPSEnabled.value,
                        onChanged: (value) async {
                          locationViewModel.isGPSEnabled.value = value;
                          if (value) {
                            await locationViewModel
                                .saveCurrentLocation(); // Save location when switch is turned on
                          }
                        },
                      )),
                  const SizedBox(height: 10),
                  CustomButton(
                    buttonText: "Save",
                    onTap: _viewModel.saveForm,
                    gradientColors: const [Colors.blue, Colors.blue],
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
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters, // <-- apply it here
        validator: validator,
      ),
    );
  }
}
