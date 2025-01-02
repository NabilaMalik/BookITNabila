import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:order_booking_app/ViewModels/order_booking_status_view_model.dart';
import 'package:order_booking_app/screens/OrderBookingStatusScreenComponents/order_booking_status_history_card.dart';

class OrderBookingStatusScreen extends StatelessWidget {
  OrderBookingStatusScreen({super.key});
  final viewModel = Get.put(OrderBookingStatusViewModel());

  @override
  Widget build(BuildContext context) {
    // Fetch the orders as soon as the screen is displayed
    viewModel.fetchOrders();

    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Order Booking Status',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // First Row: Shop and Order
                buildShopAndOrderRow(viewModel),
                const SizedBox(height: 20),
                // Second Row: Date Range
                buildDateRangeRow(context, viewModel),
                const SizedBox(height: 20),
                // Third Row: Status and Button
                buildStatusAndButtonRow(viewModel),
                const SizedBox(height: 20),
                // Two Buttons in Horizontal Layout
                buildActionButtonsRow(viewModel),
                const SizedBox(height: 20),
                // Data Table Section
                OrderBookingStatusHistoryCard(
                  filterData: (filter) => viewModel.filterData(filter),
                  rowsNotifier: ValueNotifier(viewModel.filteredRowsAsMapList),
                  viewModel: viewModel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShopAndOrderRow(OrderBookingStatusViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildLabeledDropdownSearch(
            label: "Shop",
            hint: "Search shop name",
            items: viewModel.orders.map((order) => order.shop).toList(),
            onChanged: (value) => viewModel.shopName.value = value ?? '',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLabeledDropdownSearch(
            label: "Order",
            hint: "Search order ID",
            items: viewModel.orders.map((order) => order.orderNo).toList(),
            onChanged: (value) => viewModel.orderId.value = value ?? '',
          ),
        ),
      ],
    );
  }

  Widget buildDateRangeRow(
      BuildContext context, OrderBookingStatusViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildLabeledTextField(
            label: "Start Date",
            hint: "Select start date",
            keyboardType: TextInputType.text,
            controller: TextEditingController(text: viewModel.startDate.value),
            readOnly: true,
            onTap: () => _selectDate(context, viewModel, isStartDate: true),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "To",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLabeledTextField(
            label: "End Date",
            hint: "Select end date",
            keyboardType: TextInputType.text,
            controller: TextEditingController(text: viewModel.endDate.value),
            readOnly: true,
            onTap: () => _selectDate(context, viewModel, isStartDate: false),
          ),
        ),
      ],
    );
  }

  Widget buildStatusAndButtonRow(OrderBookingStatusViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildLabeledDropdownSearch(
            label: "Status",
            hint: "Search status",
            items:
                viewModel.orders.map((order) => order.status).toSet().toList(),
            onChanged: (value) => viewModel.status.value = value ?? '',
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 150,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              viewModel.clearFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shadowColor: Colors.black,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Clear Filters",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton('Order PDF', viewModel),
        _buildActionButton('Products PDF', viewModel),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    required TextInputType keyboardType,
    TextEditingController? controller,
    bool readOnly = false,
    Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdownSearch({
    required String label,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownSearch<String>(
          popupProps: PopupProps.dialog(
            showSearchBox: true,
          ),
          items: items,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: hint,
              hintText: hint,
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
            ),
          ),
          onChanged: onChanged,
          selectedItem: hint,
        ),
      ],
    );
  }

  // Function to select a date
  Future<void> _selectDate(
      BuildContext context, OrderBookingStatusViewModel viewModel,
      {required bool isStartDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate = "${pickedDate.toLocal()}".split(' ')[0];
      if (isStartDate) {
        viewModel.updateDateRange(formattedDate, viewModel.endDate.value);
      } else {
        viewModel.updateDateRange(viewModel.startDate.value, formattedDate);
      }
    }
  }

  // Action button for PDFs
  Widget _buildActionButton(
      String label, OrderBookingStatusViewModel viewModel) {
    return SizedBox(
      width: 160,
      height: 40,
      child: ElevatedButton(
        onPressed: () => viewModel.handleButtonAction(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              label == 'Order PDF' ? Colors.blue[900] : Colors.green,
          shadowColor: Colors.black,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
