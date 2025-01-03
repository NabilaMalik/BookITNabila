import 'package:flutter/material.dart';
import 'package:order_booking_app/ViewModels/order_booking_status_view_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

Widget buildShopAndOrderRow(OrderBookingStatusViewModel viewModel) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: LabeledDropdownSearch(
          label: "Shop Name",
          hint: "Search",
          items: viewModel.orders.map((order) => order.shop).toList(),
          onChanged: (value) {
            viewModel.shopName.value = value ?? '';
            viewModel.filterData();
          },
          selectedItem: viewModel.shopName.value.isEmpty ? null : viewModel.shopName.value,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: LabeledDropdownSearch(
          label: "Order No",
          hint: "Search",
          items: viewModel.orders.map((order) => order.orderNo).toList(),
          onChanged: (value) {
            viewModel.orderId.value = value ?? '';
            viewModel.filterData();
          },
        ),
      ),
    ],
  );
}

class LabeledDropdownSearch extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? selectedItem;

  LabeledDropdownSearch({
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.selectedItem
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownSearch<String>(
          popupProps: const PopupProps.dialog(
            showSearchBox: true,
          ),
          items: items,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              // hintText: hint,
                ),
          ),
          onChanged: onChanged,
          selectedItem:selectedItem?? hint ,
        ),
      ],
    );
  }
}
