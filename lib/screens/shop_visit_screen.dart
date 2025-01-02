import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/orderbooking_screen.dart';
import '../ViewModels/shop_visit_view_model.dart';
import '../widgets/rounded_button.dart';
import 'Components/custom_dropdown.dart';
import 'Components/custom_editable_menu_option.dart';
import 'ShopVisitScreenComponents/check_list_section.dart';
import 'ShopVisitScreenComponents/feedback_section.dart';
import 'ShopVisitScreenComponents/photo_picker.dart';
import 'ShopVisitScreenComponents/product_search_card.dart';

class ShopVisitScreen extends StatelessWidget {
  ShopVisitScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final ShopVisitViewModel viewModel = Get.put(ShopVisitViewModel());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Obx(() => CustomDropdown(
                        label: "Brand",
                        icon: Icons.branding_watermark,
                        items: viewModel.brands,
                        selectedValue: viewModel.selectedBrand.value,
                        onChanged: (value) {
                          viewModel.selectedBrand.value = value!;
                        },
                        useBoxShadow: false,
                        validator: (value) => value == null || value.isEmpty ? 'Please select a brand' : null,
                        inputBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        maxHeight: 40.0,
                        maxWidth: 300.0,
                        iconSize: 20.0,
                        contentPadding: 10.0,
                        iconColor: Colors.blue,
                      )),
                      Obx(() => CustomDropdown(
                        label: "Shop",
                        icon: Icons.store,
                        items: viewModel.shops,
                        selectedValue: viewModel.selectedShop.value,
                        onChanged: (value) {
                          // Keep this empty if there is no specific action on change
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a shop' : null,
                        useBoxShadow: false,
                        inputBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        maxHeight: 40.0,
                        maxWidth: 300.0,
                        iconSize: 25.0,
                        contentPadding: 10.0,
                        iconColor: Colors.blue,
                      )),
                      _buildTextField(
                        controller: TextEditingController(text: viewModel.shopAddress.value),
                        label: "Shop Address",
                        icon: Icons.location_on,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter the shop address' : null,
                        onChanged: (value) => viewModel.shopAddress.value = value,
                      ),
                      _buildTextField(
                        controller: TextEditingController(text: viewModel.ownerName.value),
                        label: "Owner Name",
                        icon: Icons.person_outlined,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter the owner name' : null,
                        onChanged: (value) => viewModel.ownerName.value = value,
                      ),
                      _buildTextField(
                        label: "Booker Name",
                        controller: TextEditingController(text: viewModel.bookerName.value),
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter the booker name' : null,
                        onChanged: (value) => viewModel.bookerName.value = value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: "Stock Check"),
                const SizedBox(height: 10),
                ProductSearchCard(
                  filterData: viewModel.filterData,
                  rowsNotifier: viewModel.rowsNotifier,
                  filteredRows: viewModel.filteredRows,
                ),
                const SizedBox(height: 20),
                ChecklistSection(
                  labels: viewModel.checklistLabels,
                  checklistState: viewModel.checklistState,
                  onStateChanged: (index, value) {
                    viewModel.checklistState[index] = value;
                  },
                ),
                const SizedBox(height: 20),
                PhotoPicker(
                  onPickImage: viewModel.pickImage,
                  selectedImage: viewModel.selectedImage,
                  onTakePicture: viewModel.takePicture,
                ),
                const SizedBox(height: 20),
                const FeedbackSection(),
                const SizedBox(height: 20),
                RoundedButton(
                  text: "Submit",
                  press: () {
                    Get.to(() => const OrderBookingScreen());
                    viewModel.submitForm(_formKey);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Shop Visit', style: TextStyle(color: Colors.white, fontSize: 24)),
      centerTitle: true,
      backgroundColor: Colors.blue,
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
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
