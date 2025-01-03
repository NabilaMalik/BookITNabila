import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/ScreenModels/return_form_model.dart';
import '../../ViewModels/ScreenViewModels/return_form_view_model.dart';

class FormRow extends StatelessWidget {
  final Size size;
  final ReturnFormViewModel viewModel;
  final ReturnForm row;
  final int index;

  const FormRow({required this.size, required this.viewModel, required this.row, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: size.width * 0.2,
          height: 50,
          child: Obx(() => DropdownButtonFormField<Item>(
            decoration: const InputDecoration(
              hintText: "Item *",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: UnderlineInputBorder(),
            ),
            value: row.selectedItem,
            items: viewModel.items.map((item) {
              return DropdownMenuItem<Item>(
                value: item,
                child: Text(item.name),
              );
            }).toList(),
            onChanged: (item) {
              row.selectedItem = item;
            },
          )),
        ),
        _buildTextField(
          label: "Qty *",
          initialValue: row.quantity,
          onChanged: (value) => row.quantity = value,
          width: size.width * 0.2,
          height: 50,
          fontSize: 20.0,
        ),
        SizedBox(
          width: size.width * 0.3,
          height: 50,
          child: Obx(() => DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: "Reason *",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: UnderlineInputBorder(),
            ),
            value: row.reason.isEmpty ? null : row.reason,
            items: viewModel.reasons.map((reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason),
              );
            }).toList(),
            onChanged: (reason) {
              row.reason = reason!;
            },
          )),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => viewModel.removeRow(index),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required double width,
    required double height,
    double fontSize = 16.0,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        initialValue: initialValue,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: const UnderlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}