import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import '../Models/ScreenModels/return_form_model.dart';
import '../Models/order_master_model.dart';
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
      child: Scaffold(backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      // Dropdown for Shop Selection
                      Obx(() {
                        debugPrint("Shops in ViewModel: ${viewModel.shops}");
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Shop Name",
                            labelStyle: TextStyle(fontSize: 15),
                            border: UnderlineInputBorder(),
                          ),
                          value: viewModel.selectedShop.value.isEmpty ? null : viewModel.selectedShop.value,
                          items: viewModel.shops.map((shop) {
                            debugPrint("Adding Shop to Dropdown: ${shop.name}");
                            return DropdownMenuItem(
                              value: shop.name,
                              child: Text(shop.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            viewModel.selectedShop.value = value!;
                            OrderMasterModel? selectedOrder;
                            try {
                              selectedOrder =
                                  orderMasterViewModel.allOrderMaster.firstWhere(
                                        (order) => order.shop_name == value,
                                  );
                            } catch (e) {
                              debugPrint("No order found for shop: $value");
                              selectedOrder = null;
                            }

                            if (selectedOrder != null) {
                              var filteredItems =
                              orderDetailsViewModel.allReConfirmOrder
                                  .where((detail) =>
                              detail.order_master_id ==
                                  selectedOrder!.order_master_id)
                                  .map((detail) => Item(detail.product!))
                                  .toList();

                              returnFormDetailsViewModel.items.value =
                                  filteredItems;
                            } else {
                              returnFormDetailsViewModel.items.value = [];
                            }
                          },
                        );
                      }),
                      const SizedBox(height: 30),

                      // List of Form Rows
                      Obx(
                            () => Column(
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
                              index: index,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AddRowButton(),
                  const SizedBox(height: 20),
                  SubmitButton(),
                ],
              ),
            ),
          ],
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
      textStyle: TextStyle(color: Colors.blue.shade900, fontSize: 16,fontWeight: FontWeight.bold),
      onTap: returnFormDetailsViewModel.addRow,
      gradientColors: [Colors.yellow, Colors.yellow.shade200],
      padding:const EdgeInsets.symmetric(horizontal: 45, vertical: 15) ,
      width: 200,
      height: 50,
      icon: Icons.add_circle_outlined,
      iconColor: Colors.blue.shade900,
      iconPosition: IconPosition.right,
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    final ReturnFormDetailsViewModel returnFormDetailsViewModel = Get.find();

    return CustomButton(
      buttonText: "Submit",
      onTap: () async {
        // ✅ Step 1: Validate if a shop is selected
        if (viewModel.selectedShop.value.isEmpty) {
          Get.snackbar(
            "Error",
            "⚠ Please select a shop before submitting.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        // ✅ Step 2: Validate if all required fields are filled
        if (returnFormDetailsViewModel.items.isEmpty ||
            returnFormDetailsViewModel.reasons.isEmpty ||
            returnFormDetailsViewModel.formRows.isEmpty) {
          Get.snackbar(
            "Error",
            "⚠ Please fill all required fields before submitting.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        // ✅ Step 3: Call submitForm (even though it returns void, we still call it)
        await viewModel.submitForm();

        // ✅ Step 4: Clear fields after submission
        viewModel.selectedShop.value = "";
        returnFormDetailsViewModel.items.clear();
        returnFormDetailsViewModel.reasons.clear();
        returnFormDetailsViewModel.formRows.clear();
        Get.snackbar(
          "Success",
          "Form submitted successfully! Fields cleared.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      },
      gradientColors: const [Colors.blue, Colors.blue],
    );
  }
}
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