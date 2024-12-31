import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/home_screen.dart';
import 'Components/custom_button.dart';
import 'Components/cutstom_dropdown.dart';

class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  _AddShopScreenState createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? selectedCity;
  final List<String> cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Peshawar',
    'Quetta', 'Multan', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Sukkur',
    'Sargodha', 'Bahawalpur', 'Abbottabad', 'Mardan', 'Sheikhupura',
    'Gujrat', 'Jhelum', 'Kasur', 'Okara', 'Sahiwal', 'Rahim Yar Khan',
    'Dera Ghazi Khan', 'Chiniot', 'Nawabshah', 'Mirpur Khas', 'Khairpur',
    'Mansehra', 'Swat', 'Muzaffarabad', 'Kotli', 'Larkana', 'Jacobabad',
    'Shikarpur', 'Hafizabad', 'Toba Tek Singh', 'Mianwali', 'Bannu',
    'Dera Ismail Khan', 'Chaman', 'Gwadar', 'Zhob', 'Lakhdar', 'Ghotki',
    'Snowshed', 'Haripur', 'Charade'
  ];
  bool isGpsEnabled = false; // For GPS toggle

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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: "Shop Name",
                    icon: Icons.store,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter shop name" : null,
                  ),
                  // CustomDropdown(
                  //   label: "City",
                  //     icon: Icons.location_city,
                  //     items: cities,
                  //     selectedValue: selectedCity,
                  //     onChanged: (value){
                  //     },
                  //   validator: (value) =>
                  //   value == null || value.isEmpty ? "Please enter City name" : null,
                  //   showBorder: true,
                  //
                  // ),
                  _buildTextField(
                    label: "Shop Address",
                    icon: Icons.place,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter shop address" : null,
                  ),
                  _buildTextField(
                    label: "Owner Name",
                    icon: Icons.person,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter owner name" : null,
                  ),
                  _buildTextField(
                    label: "Owner CNIC",
                    icon: Icons.badge,
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
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter phone number" : null,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    label: "Alternative Phone Number",
                    icon: Icons.phone_android,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Please enter alternative number" : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildSwitch(
                    label: "GPS Enabled",
                    value: isGpsEnabled,
                    onChanged: (value) => setState(() => isGpsEnabled = value),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    buttonText: "Save",
                    onTap: () => Get.to(() => HomeScreen()),
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
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  /// Builds a custom switch with a label.
  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
