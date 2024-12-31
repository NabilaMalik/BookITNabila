import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/order_booking_view_model.dart';
import 'package:order_booking_app/screens/reconfirm_order_screen.dart';
import '../widgets/rounded_button.dart';
import 'Components/custom_editable_menu_option.dart';
import 'Components/cutstom_dropdown.dart';
import 'OrderBookingScreenComponents/order_master_product_search_card.dart';

class OrderBookingScreen extends StatefulWidget {
  const OrderBookingScreen({Key? key}) : super(key: key);

  @override
  _OrderBookingScreenState createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends State<OrderBookingScreen> {
  final OrderBookingViewModel viewModel = Get.put(OrderBookingViewModel());
//  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Order Booking Form',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              // key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: TextEditingController(text: viewModel.selectedShop.value),
                    label: "Shop Name",
                    icon: Icons.warehouse,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the shop name' : null,
                    onChanged: (value) => viewModel.selectedShop.value = value,
                  ),
                  _buildTextField(
                    controller: TextEditingController(text: viewModel.ownerName.value),
                    label: "Owner Name",
                    icon: Icons.person_outlined,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the owner name' : null,
                    onChanged: (value) => viewModel.ownerName.value = value,
                  ),
                  _buildTextField(
                    label: "Phone Number",
                    controller: TextEditingController(text: viewModel.phoneNumber.value),
                    icon: Icons.phone,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the phone number' : null,
                    onChanged: (value) => viewModel.phoneNumber.value = value,
                  ),
                  _buildTextField(
                    label: "Brand",
                    controller: TextEditingController(text: viewModel.selectedBrand.value),
                    icon: Icons.branding_watermark,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the brand' : null,
                    onChanged: (value) => viewModel.selectedBrand.value = value,
                  ),
                  const SizedBox(height: 20),
                  OrderMasterProductSearchCard(
                    filterData: viewModel.filterData,
                    rowsNotifier: viewModel.rowsNotifier,
                    filteredRows: viewModel.filteredRows,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Total",
                    controller: TextEditingController(text: viewModel.total.value),
                    icon: Icons.money,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the total' : null,
                    onChanged: (value) => viewModel.total.value = value,
                  ),
                  const SizedBox(height: 10),
                  Obx(() => CustomDropdown(
                    label: "Credit Limit",
                    icon: Icons.payment,
                    items: viewModel.credits,
                    selectedValue: viewModel.creditLimit.value,
                    onChanged: (value) {
                      viewModel.creditLimit.value = value!;
                    },
                    useBoxShadow: false,
                    validator: (value) => value == null || value.isEmpty ? 'Please select a credit limit' : null,
                    inputBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    maxHeight: 40.0,
                    maxWidth: 300.0,
                    iconSize: 20.0,
                    contentPadding: 10.0,
                    iconColor: Colors.blue,
                  )),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: "Required Delivery",
                    controller: TextEditingController(text: viewModel.requiredDelivery.value),
                    icon: Icons.calendar_today,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the required delivery' : null,
                    onChanged: (value) => viewModel.requiredDelivery.value = value,
                  ),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 50),
                ],
              ),
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
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomEditableMenuOption(
      height: 50,
      label: label,
      initialValue: controller.text,
      onChanged: onChanged,
      inputBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.0),
      ),
      iconColor: Colors.blue,
      useBoxShadow: false,
      icon: icon,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: RoundedButton(
        text: 'Confirm',
        press: () {
          Get.to(() => const ReconfirmOrderScreen());
          // if (_formKey.currentState!.validate()) {
          //
          //   //viewModel.submitForm(_formKey);
          // }
        },
      ),
    );
  }
}
