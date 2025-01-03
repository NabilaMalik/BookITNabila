import 'package:flutter/material.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import '../Components/custom_button.dart';

Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      CustomButton(
        buttonText: 'Order PDF',
        width: 150,
        height: 50,
        onTap: () => viewModel.handleButtonAction('Order PDF'),
        gradientColors: [Colors.blue[900]!, Colors.blue], // Use the appropriate gradient colors
      ),
      CustomButton(
        width: 150,
        height: 50,
        buttonText: 'Products PDF',
        onTap: () => viewModel.handleButtonAction('Products PDF'),
        gradientColors: [Colors.green[700]!, Colors.green], // Use the appropriate gradient colors
      ),
    ],
  );
}
