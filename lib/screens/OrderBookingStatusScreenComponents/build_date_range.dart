import 'package:flutter/material.dart';
import 'package:order_booking_app/ViewModels/order_booking_status_view_model.dart';

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
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      // const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
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
