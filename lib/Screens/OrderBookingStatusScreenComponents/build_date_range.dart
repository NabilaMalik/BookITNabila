import 'package:flutter/material.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';

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
  DateTime now = DateTime.now();

  // Parse start and end dates safely
  DateTime? parsedStartDate = DateTime.tryParse(viewModel.startDate.value);
  DateTime? parsedEndDate = DateTime.tryParse(viewModel.endDate.value);

  // Default values
  DateTime initialDate = now;
  DateTime firstDate = DateTime(2000);
  DateTime lastDate = DateTime(2100);

  if (isStartDate) {
    if (parsedStartDate != null) {
      initialDate = parsedStartDate;
    }
    if (parsedEndDate != null) {
      lastDate = parsedEndDate; // start date cannot be after end date
    }
  } else {
    if (parsedEndDate != null) {
      initialDate = parsedEndDate;
    }
    if (parsedStartDate != null) {
      firstDate = parsedStartDate; // end date must be >= start date
    }
  }

  // Show date picker
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (pickedDate != null) {
    String formattedDate = pickedDate.toIso8601String().split('T')[0];

    if (isStartDate) {
      // If new start date is after existing end date, clear end date
      if (parsedEndDate != null && pickedDate.isAfter(parsedEndDate)) {
        viewModel.updateDateRange(formattedDate, "");
      } else {
        viewModel.updateDateRange(formattedDate, viewModel.endDate.value);
      }
    } else {
      // Validate end date >= start date
      if (parsedStartDate != null && pickedDate.isBefore(parsedStartDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End date cannot be before start date")),
        );
        return; // Invalid selection, do nothing
      }
      viewModel.updateDateRange(viewModel.startDate.value, formattedDate);
    }
  }
}
