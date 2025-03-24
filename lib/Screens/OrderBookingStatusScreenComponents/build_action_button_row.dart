import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import '../../ViewModels/order_master_view_model.dart';
import '../../ViewModels/shop_visit_view_model.dart';
import '../../Databases/dp_helper.dart';

List<DataRow> dataRows = [];
OrderBookingStatusViewModel orderBookingStatusViewModel =
Get.put(OrderBookingStatusViewModel());
String _getFormattedDate() {
  return DateFormat('dd-MMM-yyyy').format(DateTime.now());
}

Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
  OrderDetailsViewModel orderDetailsViewModel =
  Get.put(OrderDetailsViewModel());
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  final OrderMasterViewModel orderMasterViewModel =
  Get.find<OrderMasterViewModel>();
  String _getFormattedDate([DateTime? date]) {
    final DateTime now = date ?? DateTime.now();
    return DateFormat('dd-MM-yyyy').format(now);
  }

  // Define a footer
  pw.Widget buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Developed By MetaXperts!',
        style: pw.TextStyle(
          fontSize: 12,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey,
        ),
      ),
    );
  }

  // Generate Order PDF
  // Future<void> generateOrderPDF() async {
  //   final pdf = pw.Document();
  //   String currentDate = _getFormattedDate();
  //   String ordersDate = (orderBookingStatusViewModel.endDate.value != null)
  //       ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
  //       : 'Date Not Selected';
  //
  //   await orderMasterViewModel.fetchAllOrderMaster();
  //
  //   // Get selected status
  //   String selectedStatus = orderBookingStatusViewModel.selectedStatus.value;
  //
  //   // Filter orders by selected status
  //   var filteredOrders = orderMasterViewModel.allOrderMaster.where((order) {
  //     return (order.order_status ?? '').toLowerCase() == selectedStatus.toLowerCase();
  //   }).toList();
  //
  //   if (filteredOrders.isEmpty) {
  //     Get.snackbar('No Orders Found', 'No orders with status "$selectedStatus" found.');
  //     return;
  //   }
  //
  //   List<List<String>> rowsData = [];
  //   double totalAmount = 0.0;
  //   int totalOrders = filteredOrders.length;
  //
  //   for (var order in filteredOrders) {
  //     String amountText = (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
  //     double amount = double.tryParse(amountText) ?? 0.0;
  //     totalAmount += amount;
  //     rowsData.add([
  //       order.order_master_id ?? '-',
  //       order.shop_name ?? '-',
  //       amountText,
  //     ]);
  //   }
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('Valor Trading Order Booking Status',
  //                 style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
  //             pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
  //             pw.Text('Print Date: $currentDate'),
  //             pw.Text('Orders Date: $ordersDate'),
  //             pw.Text('Status: $selectedStatus'), // Show selected status
  //             pw.SizedBox(height: 10),
  //             pw.Table.fromTextArray(
  //               headers: ['Order No', 'Shop Name', 'Amount'],
  //               data: rowsData,
  //               headerStyle: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
  //               headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
  //               cellStyle: const pw.TextStyle(fontSize: 10),
  //               cellAlignment: pw.Alignment.center,
  //               cellPadding: const pw.EdgeInsets.all(6),
  //               oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //               border: null,
  //             ),
  //             pw.Divider(),
  //             pw.Text('Total Orders: $totalOrders',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             buildFooter(),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   try {
  //     final directory = await getTemporaryDirectory();
  //     final filePath = '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     final xfile = XFile(filePath);
  //     await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
  //     Get.snackbar('Success', 'Order PDF shared successfully!');
  //   } catch (e) {
  //     debugPrint("Error saving or sharing Order PDF: $e");
  //     Get.snackbar('Error', 'Failed to generate or share Order PDF.');
  //   }
  // }



  Future<void> generateOrderPDF() async {
    final pdf = pw.Document();

    // Utility function to format date
    String _getFormattedDate([DateTime? date]) {
      final DateTime now = date ?? DateTime.now();
      return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    }

    // Fetch all orders
    await orderMasterViewModel.fetchAllOrderMaster();

    // Debug: print total orders fetched
    print('Total Orders Fetched: ${orderMasterViewModel.allOrderMaster.length}');

    // Parse selected start and end dates
    DateTime? startDate;
    DateTime? endDate;

    try {
      var startValue = orderBookingStatusViewModel.startDate.value;
      if (startValue != null && startValue.toString().isNotEmpty) {
        startDate = DateTime.parse(startValue.toString());
      }
    } catch (e) {
      print('Error parsing startDate: $e');
      startDate = null;
    }

    try {
      var endValue = orderBookingStatusViewModel.endDate.value;
      if (endValue != null && endValue.toString().isNotEmpty) {
        endDate = DateTime.parse(endValue.toString());
      }
    } catch (e) {
      print('Error parsing endDate: $e');
      endDate = null;
    }

    // Format orders date range string
    String ordersDate = (startDate != null && endDate != null)
        ? '${_getFormattedDate(startDate)} - ${_getFormattedDate(endDate)}'
        : 'Date Not Selected';

    // Debug: print start and end dates
    print('Start Date: $startDate, End Date: $endDate');

    // Filter orders by date and status
    var filteredOrders = orderMasterViewModel.allOrderMaster.where((order) {
      DateTime? orderDate;

      if (order.order_master_date != null) {
        try {
          orderDate = DateTime.parse(order.order_master_date.toString());
        } catch (e) {
          print('Invalid order date format: ${order.order_master_date}');
          orderDate = null;
        }
      }

      bool dateMatch = true;
      if (startDate != null && endDate != null && orderDate != null) {
        dateMatch = orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(endDate.add(const Duration(days: 1)));
      }

      String status = order.order_status ?? '';
      bool statusMatch = status.trim().toLowerCase() == 'completed'; // Match 'completed' orders

      return dateMatch && statusMatch;
    }).toList();

    // Debug: print filtered orders count
    print('Filtered Orders Count: ${filteredOrders.length}');

    // Debug: print first two orders
    for (var order in orderMasterViewModel.allOrderMaster.take(2)) {
      print('Order Date: ${order.order_master_date}, Status: "${order.order_status}"');
    }

    // Prepare table data and totals
    List<List<String>> rowsData = [];
    double totalAmount = 0.0;
    int totalOrders = filteredOrders.length;

    for (var order in filteredOrders) {
      String amountText = (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
      double amount = double.tryParse(amountText) ?? 0.0;
      totalAmount += amount;

      rowsData.add([
        order.order_master_id ?? '-',
        order.shop_name ?? '-',
        'PKR $amountText',
      ]);
    }

    // Footer widget
    pw.Widget buildFooter() {
      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Developed By MetaXperts!',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey,
          ),
        ),
      );
    }

    // Build PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Valor Trading Order Booking Status',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id ?? '-'}'),
              pw.Text('Booker Name: ${shopVisitViewModel.booker_name ?? '-'}'),
              pw.Text('Print Date: ${_getFormattedDate()}'),
              pw.Text('Orders Date: $ordersDate'),
              pw.SizedBox(height: 10),

              if (rowsData.isEmpty)
                pw.Text('No orders found for the selected date range and status.',
                    style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic))
              else ...[
                pw.Table.fromTextArray(
                  headers: ['Order No', 'Shop Name', 'Amount'],
                  data: rowsData,
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                  cellPadding: const pw.EdgeInsets.all(6),
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  border: null,
                ),
                pw.Divider(),
                pw.Text('Total Orders: $totalOrders',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
              buildFooter(),
            ],
          );
        },
      ),
    );

    // Save and share PDF
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final xfile = XFile(filePath);
      await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
      Get.snackbar('Success', 'Order PDF shared successfully!');
    } catch (e) {
      debugPrint("Error saving or sharing Order PDF: $e");
      Get.snackbar('Error', 'Failed to generate or share Order PDF.');
    }
  }




  generateProductsPDF() async {
    final pdf = pw.Document();
    String currentDate = _getFormattedDate();
    String ordersDate = 'All Dates'; // No date range, show as 'All Dates'

    if (kDebugMode) {
      print("Generating PDF for all order data.");
    }

    final Database? db = await DBHelper().db;
    if (db == null) {
      print("Database is not initialized!");
      return;
    }

    // Fetch all rows without date filter
    List<Map<String, dynamic>> queryRows = await db.query('orderDetails');
    print("Query Result Rows: ${queryRows.length}"); // Debug log

    List<List<String>> productTableData = queryRows.isNotEmpty
        ? queryRows.map((order) {
      String productName = order['product'] ?? 'N/A';
      String quantity = order['quantity']?.toString() ?? '0';
      return [productName, quantity];
    }).toList()
        : [['No Products Found', '0']];

    int totalOrders = queryRows.length;

    int itemsPerPage = 20;
    int pageCount = (productTableData.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      int startIndex = pageIndex * itemsPerPage;
      int endIndex = (startIndex + itemsPerPage).clamp(0, productTableData.length);
      List<List> currentPageData = productTableData.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Valor Trading Products Details - Page ${pageIndex + 1}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Booker ID: ${orderDetailsViewModel.currentuser_id}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Booker Name: ${shopVisitViewModel.booker_name}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Print Date: $currentDate',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Orders/Products Date: $ordersDate',
                          style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Product Details:',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),

                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity'],
                  data: currentPageData.isNotEmpty
                      ? currentPageData
                      : [['No Products Found', '0']],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
                  ),
                  cellPadding: const pw.EdgeInsets.all(6),
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),

                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text('Total Orders: $totalOrders',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final output = File('${directory.path}/Products PDF.pdf');
      await output.writeAsBytes(await pdf.save());
      print("PDF Saved at: ${output.path}, Size: ${await output.length()} bytes"); // Debug file size
      final xfile = XFile(output.path);
      await Share.shareXFiles([xfile], text: 'PDF Document');
    } catch (e) {
      print("Error saving or sharing PDF: $e");
    }
  }


  // Handle PDF generation actions
  void handleButtonAction(String action) async {
    if (action == 'Order PDF') {
      await generateOrderPDF();
    } else if (action == 'Products PDF') {
      await generateProductsPDF();
    }
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      ElevatedButton(
        onPressed: generateOrderPDF,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('Order PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
      ),
      ElevatedButton(
        onPressed: generateProductsPDF,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Products PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
      ),
    ],
  );
}