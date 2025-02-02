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
// // Generate Order PDF
// Future<void> generateOrderPDF() async {
//   final pdf = pw.Document();
//   // Load the logo image
//   final imageLogo = await imageFromAssetBundle('assets/images/1download.jpeg'); // Replace with your logo asset path
//   pdf.addPage(
//     pw.Page(
//       margin: const pw.EdgeInsets.all(20),
//       build: (pw.Context context) {
//         return pw.Container(
//           decoration: pw.BoxDecoration(
//             border: pw.Border.all(color: PdfColors.black, width: 1), // Add border
//             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)), // Rounded corners
//           ),
//           padding: const pw.EdgeInsets.all(10), // Padding inside the border
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.SizedBox(height: 16),
//               // Logo and "BookIT" text in the same line
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.start,
//                 children: [
//                   // Logo image
//                   pw.Image(
//                     imageLogo,
//                     height: 40,
//                     width: 40,
//                   ),
//                   pw.SizedBox(width: 10), // Adjust spacing between image and text
//                   // "BookIT" text
//                   pw.Text(
//                     'Valor Trading',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.blueAccent,
//                     ),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 25), // Space between logo and "Order Summary"
//               // "Order Summary" text on the next line
//               pw.Text(
//                 'Order Summary',
//                 style: pw.TextStyle(
//                   fontSize: 24,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blueAccent,
//                 ),
//               ),
//               pw.SizedBox(height: 10),
//               pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Expanded(
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 5),
//                           child: pw.Text(
//                             'Order ID: ${viewModel.orderId}',
//                             style: const pw.TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 30),
//                           child: pw.Text(
//                             'Shop: ${viewModel.shop_name}',
//                             style: const pw.TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 5),
//                           child: pw.Text(
//                             'Booker Name:  ${shopVisitViewModel.owner_name}',
//                             style: const pw.TextStyle(fontSize: 16),
//                           ),
//                         ), pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 5),
//                           child: pw.Text(
//                             'Date: ${DateFormat('dd-MMM-yyyy : HH-MM-ss')
//                                 .format(DateTime.now())}',
//                             style: const pw.TextStyle(fontSize: 16),
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 5),
//                           child: pw.Text(
//                             'Date Range: ${viewModel.startDate} - ${viewModel.endDate}',
//                             style: const pw.TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         // pw.Padding(
//                         //   padding: const pw.EdgeInsets.only(left: 20, top: 5),
//                         //   child: pw.Text(
//                         //     'Req.Delivery: ${orderMasterViewModel.requiredDelivery}',
//                         //     style: const pw.TextStyle(fontSize: 16),
//                         //   ),
//                         // ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.only(left: 20, top: 6),
//                           child: pw.Text(
//                             'Status: ${viewModel.status}',
//                             style:const pw.TextStyle(
//                               fontSize: 16.8,
//                               color: PdfColors.green,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headerStyle: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.white,
//                 ),
//                 headerDecoration: const pw.BoxDecoration(
//                   color: PdfColors.blue,
//                 ),
//                 cellStyle: const pw.TextStyle(fontSize: 12),
//                 cellAlignments: {
//                   0: pw.Alignment.center,
//                   1: pw.Alignment.centerLeft,
//                   2: pw.Alignment.center,
//                 },
//                 data: [
//                   ['OrderNo', 'ShopName', 'Amount'], // Table Header
//                   ...viewModel.filteredRows.map((order) => [
//                     order.orderNo,
//                     order.shop,
//                     order.amount.toString(),
//                   ]),
//                 ],
//               ),
//               pw.SizedBox(height: 480),
//               buildFooter(),
//             ],
//           ),
//         );
//       },
//     ),
//   );
//
//   // Save the PDF to device or share it
//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }
//
// // Generate Products PDF
// Future<void> generateProductsPDF() async {
//   final pdf = pw.Document();
//
//   // Load the logo image
//   final imageLogo = await imageFromAssetBundle('assets/images/1download.jpeg'); // Replace with your logo asset path
//
//   // Retrieve filtered rows from the viewModel
//   final filteredProducts = viewModel.filteredRows;
//
//   pdf.addPage(
//     pw.MultiPage(
//       margin: const pw.EdgeInsets.all(20),
//       header: (pw.Context context) {
//         return pw.Container(
//           padding: const pw.EdgeInsets.only(top: 20, left: 20, bottom: 10), // Padding for header
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Horizontal line
//               pw.Divider(
//                 thickness: 1,
//                 color: PdfColors.black,
//               ),
//               // Padding below the line
//               pw.SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//       footer: (pw.Context context) => buildFooter(),
//       build: (pw.Context context) => [
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Add padding to the logo and text on the same line
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               children: [
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.only(left: 150), // Adjust the padding around the logo
//                   child: pw.Image(
//                     imageLogo,
//                     height: 100,
//                     width: 100,
//                   ),
//                 ),
//                 pw.SizedBox(width: 10), // Adjust spacing between image and text
//                 pw.Text(
//                   'Valor Trading',
//                   style: pw.TextStyle(
//                     fontSize: 30, // Set your desired font size here
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.black,
//                   ),
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 20), // Add space between logo/text and table
//             // Data Table
//             pw.Table.fromTextArray(
//               headerStyle: pw.TextStyle(
//                 fontWeight: pw.FontWeight.bold,
//                 color: PdfColors.white,
//               ),
//               headerDecoration: const pw.BoxDecoration(
//                 color: PdfColors.blue,
//               ),
//               cellStyle: const pw.TextStyle(fontSize: 12),
//               cellAlignments: {
//                 0: pw.Alignment.center,
//                 1: pw.Alignment.centerLeft,
//                 2: pw.Alignment.center,
//                 3: pw.Alignment.center,
//                 4: pw.Alignment.center,
//               },
//               data: [
//                 ['Order ID', 'Product Name', 'Quantity', 'Status', 'Date'], // Table Header
//                 ...filteredProducts.map((product) => [
//                   product.orderNo,
//                   product.shop,
//                   product.amount.toString(),
//                   product.status,
//                   product.date,
//                 ]).toList(),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//
//   // Save the PDF to device or share it
//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }

// Handle PDF generation actions
// void handleButtonAction(String action) async {
//   if (action == 'Order PDF') {
//     await generateOrderPDF();
//   } else if (action == 'Products PDF') {
//     await generateProductsPDF();
//   }
//   }