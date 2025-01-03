import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/ScreenModels/return_form_model.dart';
import '../ViewModels/ScreenViewModels/return_form_view_model.dart';
import 'ReturnFormScreenComponents/form_row.dart';
import 'ReturnFormScreenComponents/return_appbar.dart';

class ReturnFormScreen extends StatelessWidget {
  const ReturnFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.put(ReturnFormViewModel());
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
                ShopDropdown(size: size, viewModel: viewModel),
                const SizedBox(height: 30),
                Obx(() => Column(
                  children: viewModel.formRows.asMap().entries.map((entry) {
                    int index = entry.key;
                    ReturnForm row = entry.value;
                    return FormRow(size: size, viewModel: viewModel, row: row, index: index);
                  }).toList(),
                )),
                const SizedBox(height: 30),
                const AddRowButton(),
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

class ShopDropdown extends StatelessWidget {
  final Size size;
  final ReturnFormViewModel viewModel;

  const ShopDropdown({required this.size, required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      width: size.width * 0.8,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: "Select Shop *",
          labelStyle: TextStyle(fontSize: 18),
          border: UnderlineInputBorder(),
        ),
        value: viewModel.selectedShop.value.isEmpty
            ? null
            : viewModel.selectedShop.value,
        items: viewModel.shops.map((shop) {
          return DropdownMenuItem(
            value: shop,
            child: Text(shop),
          );
        }).toList(),
        onChanged: (value) {
          viewModel.selectedShop.value = value!;
        },
      ),
    ));
  }
}



class AddRowButton extends StatelessWidget {
  const AddRowButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return ElevatedButton(
      onPressed: viewModel.addRow,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Add Row',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return ElevatedButton(
      onPressed: viewModel.submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
