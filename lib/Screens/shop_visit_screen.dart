import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
import '../ViewModels/shop_visit_details_view_model.dart';
import '../ViewModels/shop_visit_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_dropdown.dart';
import 'Components/custom_editable_menu_option.dart';
import 'ShopVisitScreenComponents/check_list_section.dart';
import 'ShopVisitScreenComponents/feedback_section.dart';
import 'ShopVisitScreenComponents/photo_picker.dart';
import 'ShopVisitScreenComponents/product_search_card.dart';

class ShopVisitScreen extends StatefulWidget {
  const ShopVisitScreen({super.key});
  @override
  _StateShopVisitScreen createState() => _StateShopVisitScreen();
}
class _StateShopVisitScreen extends State<ShopVisitScreen>{
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
      Get.put(ShopVisitDetailsViewModel());
  final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());


  @override
  void initState() {
    super.initState();
    shopVisitViewModel.fetchBrands();
    shopVisitViewModel.fetchShops();
    // shopVisitDetailsViewModel.initializeProductData();
  }

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
                  key: shopVisitViewModel.formKey,
                  child: Column(
                    children: [
                      Obx(() => CustomDropdown(

                        label: "Brand",
                        icon: Icons.branding_watermark,
                        items: shopVisitViewModel.brands
                            .where((brand) => brand != null)
                            .cast<String>()
                            .toList(),
                        selectedValue: shopVisitViewModel.selectedBrand.value.isNotEmpty
                            ? shopVisitViewModel.selectedBrand.value
                            : 'Select a Brand',
                        onChanged: (value) async {
                          shopVisitDetailsViewModel.filteredRows.refresh();
                          shopVisitViewModel.selectedBrand.value = value!;
                          shopVisitDetailsViewModel.filterProductsByBrand(value);
                        },
                        useBoxShadow: false,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a brand'
                            : null,
                        inputBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        // maxWidth: fieldWidth,  // ✅ Same width as _buildTextField
                        // maxHeight: MediaQuery.of(context).size.height * 0.079,
                        iconSize: 22.0,
                        contentPadding: MediaQuery.of(context).size.height * 0.005,
                        iconColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                       )
                      ),


                      Obx(() => CustomDropdown(
                            label: "Shop",
                            icon: Icons.store,
                            items: shopVisitViewModel.shops.value.where((shop) => shop != null).cast<String>().toList(),
                            selectedValue:shopVisitViewModel.selectedShop.value.isNotEmpty?
                                shopVisitViewModel.selectedShop.value: " Select  a Shop",
                            onChanged: (value) async {
                              shopVisitViewModel.selectedShop.value = value!;
                              await shopVisitViewModel.updateShopDetails(value);
                              shopVisitViewModel.selectedShop.value =
                                  value;
                              debugPrint(shopVisitViewModel.shop_address.value);
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a shop'
                                : null,
                            useBoxShadow: false,
                            inputBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                            ),
                        maxHeight: 50.0,
                        maxWidth: 385.0,
                        // maxWidth: 355.0,
                        iconSize: 23.0,
                        // contentPadding: 6.0,
                        contentPadding: 0.0,
                            iconColor: Colors.blue,
                          )
                      ),
                      Obx(() => _buildTextField(
                            initialValue: shopVisitViewModel.shop_address.value,
                            label: "Shop Address",
                            icon: Icons.location_on,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter the shop address'
                                : null,
                            onChanged: (value) =>
                                shopVisitViewModel.shop_address.value = value,
                          )
                      ),
                      Obx(() => _buildTextField(
                            initialValue: shopVisitViewModel.owner_name.value,
                            label: "Owner Name",
                            icon: Icons.location_on,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter the shop address'
                                : null,
                            onChanged: (value) =>
                                shopVisitViewModel.owner_name.value = value,
                          )),
                      _buildTextField(
                        label: "Booker Name",
                        initialValue: shopVisitViewModel.booker_name.value,
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter the booker name'
                            : null,
                        onChanged: (value) =>
                            shopVisitViewModel.booker_name.value = value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: "Stock Check"),
                const SizedBox(height: 10),
                ProductSearchCard(
                  filterData: shopVisitDetailsViewModel.filterData,
                  rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
                  filteredRows: shopVisitDetailsViewModel.filteredRows,
                  shopVisitDetailsViewModel: shopVisitDetailsViewModel,
                ),
                const SizedBox(height: 20),
                ChecklistSection(
                  labels: shopVisitViewModel.checklistLabels,
                  checklistState: shopVisitViewModel.checklistState,
                  onStateChanged: (index, value) {
                    shopVisitViewModel.checklistState[index] = value;
                  },
                ),
                const SizedBox(height: 20),
                PhotoPicker(
                  onPickImage: shopVisitViewModel.pickImage,
                  selectedImage: shopVisitViewModel.selectedImage,
                  onTakePicture: shopVisitViewModel.takePicture,
                ),
                const SizedBox(height: 20),
                Obx(() => FeedbackSection(
                      feedBackController: TextEditingController(
                          text: shopVisitViewModel.feedBack.value),
                      onChanged: (value) =>
                          shopVisitViewModel.feedBack.value = value,
                    )),
                const SizedBox(height: 20),
                Row(children: [
                  CustomButton(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                    textSize: 16,
                    iconSize: 18,
                    height: 45,
                    padding: const EdgeInsets.only(left: 3, right: 25),
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconColor: Colors.white,
                    iconPosition: IconPosition.left,
                    spacing: 0,
                    //iconBackgroundColor: Colors.white,
                    width: 120,
                    buttonText: "Only Visit",
                    onTap: shopVisitViewModel.saveFormNoOrder,
                    gradientColors: [Colors.red, Colors.red],
                  ),
                  const SizedBox(width: 80),
                  CustomButton(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                    textSize: 16,
                    iconSize: 18,
                    height: 45,
                    padding: EdgeInsets.only(left: 10, right: 5),
                    width: 120,
                    spacing: 0,
                    buttonText: "Order Form",
                    icon: Icons.arrow_forward_ios_outlined,
                    iconColor: Colors.white,
                    onTap: shopVisitViewModel.saveForm,
                    iconPosition: IconPosition.right,
                    gradientColors: [Colors.blue.shade900, Colors.blue],
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Shop Visit',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          // Add your back navigation logic here
          // For example, you can pop the current screen
          Get.offAllNamed("/home");
          // Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            shopVisitViewModel.fetchAllShopVisit();
           //productsViewModel.fetchAndSaveProducts();
           productsViewModel.fetchAllProductsModel();
          },
        ),
      ],
      backgroundColor: Colors.blue,
    );
  }


  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomEditableMenuOption(
      //readOnly: true,
      label: label,
      initialValue: initialValue,
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
      //enableListener: true,
      //useTextField: true, // Ensure this is true to use TextField
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
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
