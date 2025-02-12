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
import 'package:printing/printing.dart';
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
  Future<void> generateOrderPDF() async {
    final pdf = pw.Document();
    const baseColor = PdfColors.blue;
    const headerColor = PdfColors.black;
    String currentDate = _getFormattedDate();
    String ordersDate = (orderBookingStatusViewModel.startDate.value != null &&
            orderBookingStatusViewModel.endDate.value != null)
        ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
        : 'Date Not Selected';

    // Ensure orders are fetched
    await orderMasterViewModel.fetchAllOrderMaster();

    // Extract data from OrderMasterViewModel
    List<List<String>> rowsData = [];
    double totalAmount = 0.0;
    int totalOrders = orderMasterViewModel.allOrderMaster.length;
    for (var order in orderMasterViewModel.allOrderMaster) {
      String amountText =
          (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
      double amount = double.tryParse(amountText) ?? 0.0;
      totalAmount += amount;
      rowsData.add([
        order.order_master_id ?? '-',
        order.shop_name ?? '-',
        amountText,
      ]);
    }

    // Generate PDF page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Valor Trading Order Booking Status',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
              pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
              pw.Text('Print Date: $currentDate'),
              pw.Text('Orders Date: $ordersDate'),
              pw.SizedBox(height: 10),

              // Table with aligned headers
              pw.Table.fromTextArray(
                headers: ['Order No', 'Shop Name', 'Amount'],
                data: rowsData,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.black),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.center,
                cellPadding: const pw.EdgeInsets.all(6),
                oddRowDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                border: null, // Remove table borders
              ),
              pw.Divider(),
              pw.Text('Total Orders: $totalOrders',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              buildFooter(), // Add Footer
            ],
          );
        },
      ),
    );

    // Save or Share PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  generateProductsPDF() async {
    final pdf = pw.Document();
    String currentDate = _getFormattedDate();
    String ordersDate = (orderBookingStatusViewModel.startDate.value != null &&
            orderBookingStatusViewModel.endDate.value != null)
        ? '${orderBookingStatusViewModel.startDate.value}${orderBookingStatusViewModel.endDate.value}'
        : 'Date Not Selected';
    // String ordersDate = startDateController.text.isNotEmpty ? startDateController.text : 'Date Not Selected';
    print("Generating PDF for Date: $ordersDate");
    final Database? db = await DBHelper().db;
    if (db == null) {
      if (kDebugMode) {
        print("Database is not initialized!");
      }
      return;
    }
    List<Map<String, dynamic>> queryRows = await db.query(
      'orderDetails',
      where: 'order_details_date = ?',
      whereArgs: [],
    );
    List<List<String>> productTableData = queryRows.map((order) {
      String productName =
          order['product'] ?? 'N/A'; // Adjust key as per your data structure
      String quantity = order['quantity']?.toString() ??
          '0'; // Adjust key as per your data structure
      return [
        productName,
        quantity
      ]; // Return product name and quantity as a list
    }).toList();

    // Calculate total orders
    int totalOrders = productTableData.length;

    int itemsPerPage = 20;
    int pageCount = (totalOrders / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      int startIndex = pageIndex * itemsPerPage;
      int endIndex = (startIndex + itemsPerPage).clamp(0, totalOrders);
      List<List> currentPageData =
          productTableData.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Valor Trading Products Details - Page ${pageIndex + 1}',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold),
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
                      pw.Text(
                          'Booker ID: ${orderDetailsViewModel.currentuser_id}',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Booker Name: ${shopVisitViewModel.booker_name}',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Print Date: $currentDate',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Orders/Products Date: $ordersDate',
                          style: const pw.TextStyle(fontSize: 16)),
                      // pw.Text('Booker ID: LG473-33G',
                      //     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      // pw.Text('Booker Name: NABILA',
                      //     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      // pw.Text('Print Date: 10-02-2025',
                      //     style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      // pw.Text('Orders/Products Date: 02-02-2024',
                      //     style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Product Details:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity'],
                  data: currentPageData.isNotEmpty
                      ? currentPageData
                      : [
                          ['No Products Found', '0']
                        ],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  oddRowDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                  border: const pw.TableBorder(
                    horizontalInside:
                        pw.BorderSide(width: 0.5, color: PdfColors.grey),
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
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final output = File('${directory.path} Products PDF.pdf');
      await output.writeAsBytes(await pdf.save());
      final xfile = XFile(output.path);
      await Share.shareXFiles([xfile], text: 'PDF Document');
    } catch (e) {
      if (kDebugMode) {
        print("Error saving or sharing PDF: $e");
      }
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
        onPressed: () => handleButtonAction('Order PDF'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('Order PDF'),
      ),
      ElevatedButton(
        onPressed: () => handleButtonAction('Products PDF'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Products PDF'),
      )
    ],
  );
}
