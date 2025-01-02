import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/order_booking_view_model.dart';
import 'package:order_booking_app/screens/reconfirm_order_screen.dart';
import '../widgets/rounded_button.dart';
import 'Components/custom_dropdown.dart';
import 'Components/custom_editable_menu_option.dart';
import 'OrderBookingScreenComponents/order_master_product_search_card.dart';

class OrderBookingScreen extends StatefulWidget {
  const OrderBookingScreen({Key? key}) : super(key: key);

  @override
  _OrderBookingScreenState createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends State<OrderBookingScreen> {
  final OrderBookingViewModel viewModel = Get.put(OrderBookingViewModel());
  final _formKey = GlobalKey<FormState>();

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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Shop Name",
                    text: viewModel.selectedShop.value,
                    icon: Icons.warehouse,
                  ),
                  _buildTextField(
                    label: "Owner Name",
                    text: viewModel.ownerName.value,
                    icon: Icons.person_outlined,
                  ),
                  _buildTextField(
                    label: "Phone Number",
                    text: viewModel.phoneNumber.value,
                    icon: Icons.phone,
                  ),
                  _buildTextField(
                    label: "Brand",
                    text: viewModel.selectedBrand.value,
                    icon: Icons.branding_watermark,
                  ),
                  const SizedBox(height: 20),
                  OrderMasterProductSearchCard(
                    filterData: viewModel.filterData,
                    rowsNotifier: viewModel.rowsNotifier,
                    filteredRows: viewModel.filteredRows,
                    viewModel: viewModel,
                  ),
                  const SizedBox(height: 20),
                  Obx(() => CustomEditableMenuOption(
                        label: "Total",
                        initialValue: viewModel.total.value,
                        onChanged:
                            (value) {}, // Read-only mode, no need to change
                        inputBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        iconColor: Colors.blue,
                        useBoxShadow: false,
                        icon: Icons.money,
                        readOnly: true,
                        enableListener: true, // Enable listener where required
                        viewModel: viewModel, // Pass the viewModel parameter
                      )),
                  const SizedBox(height: 10),
                CustomDropdown(
                    label: "Credit Limit",
                    icon: Icons.payment,
                    items: viewModel.credits,
                    selectedValue: viewModel.creditLimit.value,
                    onChanged: (value) {
                      viewModel.creditLimit.value = value!;
                      if (kDebugMode) {
                        print("Selected: ${viewModel.creditLimit.value}");
                      }
                    },
                    useBoxShadow: false,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a credit limit'
                        : null,
                    inputBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    maxHeight: 40.0,
                    maxWidth: 300.0,
                    iconSize: 20.0,
                    contentPadding: 10.0,
                    iconColor: Colors.blue,
                  ),

                  const SizedBox(height: 10),
                  _buildTextField(
                    label: "Required Delivery",
                    text: viewModel.requiredDelivery.value,
                    icon: Icons.calendar_today,
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
    required String text,
    required IconData icon,
  }) {
    return CustomEditableMenuOption(
      label: label,
      initialValue: text,
      onChanged: (value) {},
      inputBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.0),
      ),
      iconColor: Colors.blue,
      useBoxShadow: false,
      icon: icon,
      readOnly: true, // Make it read-only
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: RoundedButton(
        text: 'Confirm',
        press: () {
          Get.to(() => const ReconfirmOrderScreen());
          if (_formKey.currentState!.validate()) {
            viewModel.submitForm(_formKey);
          }
        },
      ),
    );
  }
}
