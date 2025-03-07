import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:order_booking_app/Models/returnform_details_model.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import '../Models/ScreenModels/return_form_model.dart';
import '../Models/order_master_model.dart';
import '../ViewModels/ScreenViewModels/return_form_view_model.dart';
import '../ViewModels/order_master_view_model.dart';
import '../ViewModels/return_form_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_editable_menu_option.dart';
import 'ReturnFormScreenComponents/form_row.dart';
import 'ReturnFormScreenComponents/return_appbar.dart';

class ReturnFormScreen extends StatelessWidget {
 ReturnFormScreen({super.key});
  final ReturnFormViewModel viewModel = Get.put(ReturnFormViewModel());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
 final OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());

 final ReturnFormDetailsViewModel returnFormDetailsViewModel =
 Get.put(ReturnFormDetailsViewModel());
  @override
  Widget build(BuildContext context) {
    viewModel.initializeData();
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                Obx(() {
                  // Debug: Print the contents of viewModel.shops
                  debugPrint("Shops in ViewModel: ${viewModel.shops}");
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Shop Name",
                      labelStyle: TextStyle(fontSize: 15),
                      border: UnderlineInputBorder(),
                    ),
                    value: viewModel.selectedShop.value.isEmpty
                        ? null
                        : viewModel.selectedShop.value,
                    items: viewModel.shops.map((shop) {
                      // Debug: Print each shop name being added to the dropdown
                      debugPrint("Adding Shop to Dropdown: ${shop.name}");
                      return DropdownMenuItem(
                        value: shop.name,
                        child: Text(shop.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      viewModel.selectedShop.value = value!;

                      // Find the order_master_id for the selected shop
                      OrderMasterModel? selectedOrder;
                      try {
                        selectedOrder = orderMasterViewModel.allOrderMaster.firstWhere(
                              (order) => order.shop_name == value,
                        );
                      } catch (e) {
                        debugPrint("No order found for the selected shop: $value");
                        selectedOrder = null; // Set to null if no match is found
                      }

                      if (selectedOrder != null) {
                        // Proceed with filtering items
                        var filteredItems = orderDetailsViewModel.allReConfirmOrder
                            .where((detail) => detail.order_master_id == selectedOrder!.order_master_id)
                            .map((detail) => Item(detail.product!))
                            .toList();

                        returnFormDetailsViewModel.items.value = filteredItems;
                      } else {
                        debugPrint("No order found for the selected shop: $value");
                        returnFormDetailsViewModel.items.value = [];
                      }
                    },
                  );
                }),
                const SizedBox(height: 30),
                Obx(() => Column(
                      children: returnFormDetailsViewModel.formRows
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        ReturnForm row = entry.value;
                        return FormRow(
                            size: size,
                            returnFormDetailsViewModel:
                                returnFormDetailsViewModel,
                            row: row,
                            index: index);
                      }).toList(),
                    )),
                const SizedBox(height: 10),
                 AddRowButton(),
                const SizedBox(height: 40),

                const SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class AddRowButton extends StatelessWidget {
  AddRowButton({super.key});
  final ReturnFormDetailsViewModel returnFormDetailsViewModel =
      Get.put(ReturnFormDetailsViewModel());

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return CustomButton(
      buttonText: "Add Row",
      textStyle: TextStyle(color: Colors.red, fontSize: 16),
      onTap: returnFormDetailsViewModel.addRow,
      gradientColors: [Colors.yellow, Colors.yellow],
      padding:const EdgeInsets.symmetric(horizontal: 45, vertical: 15) ,
      width: 200,
      height: 50,
      icon: Icons.add_circle_outlined,
      iconColor: Colors.red,
      iconPosition: IconPosition.right,
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return
      CustomButton(
        buttonText: "Submit",
        onTap: viewModel.submitForm,
        gradientColors: [Colors.blue, Colors.blue],
      );
    //   ElevatedButton(
    //   onPressed: viewModel.submitForm,
    //   style: ElevatedButton.styleFrom(
    //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    //     backgroundColor: Colors.blue,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(20),
    //     ),
    //   ),
    //   child: const Text(
    //     'Submit',
    //     style: TextStyle(fontSize: 20, color: Colors.white),
    //   ),
    // );
  }
}
