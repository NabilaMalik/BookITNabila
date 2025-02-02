import 'package:get/get.dart';
import 'package:order_booking_app/Models/order_master_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'as pw;
import '../../Models/ScreenModels/order_status_models.dart';
import '../../Repositories/ScreenRepositories/order_booking_status_repository.dart';

class OrderBookingStatusViewModel extends GetxController {
  // Observables
  var orders = <OrderBookingStatusModel>[].obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var shop_name = ''.obs;
  var orderId = ''.obs;
  var status = ''.obs;
  var filteredRows = <OrderBookingStatusModel>[].obs;
  var filteredRowsMaster = <OrderMasterModel>[].obs;

  // Instance of the repository
  final OrderBookingStatusRepository _orderRepository =
      OrderBookingStatusRepository();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch orders from the repository
  Future<void> fetchOrders() async {
    try {
      List<OrderBookingStatusModel> fetchedOrders =
          await _orderRepository.safeFetchOrders();
      orders.value = fetchedOrders;
      filteredRows.value = fetchedOrders;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    }
  }

  // Update date range
  void updateDateRange(String start, String end) {
    startDate.value = start;
    endDate.value = end;
    filterData();
  }

  // Clear filters
  void clearFilters() {
    shop_name.value = '';
    orderId.value = '';
    status.value = '';
    startDate.value = '';
    endDate.value = '';
    filteredRows.value = orders;
  }

// Filter data based on query
  void filterData([String query = '']) {
    final lowerCaseQuery = query.toLowerCase();
    filteredRows.value = orders.where((order) {
      final isShopMatch = shop_name.value.isEmpty ||
          order.shop!.toLowerCase().contains(shop_name.value.toLowerCase());
      final isOrderNoMatch = orderId.value.isEmpty ||
          order.orderNo!.toLowerCase().contains(orderId.value.toLowerCase());
      final isStatusMatch = status.value.isEmpty ||
          order.status!.toLowerCase().contains(status.value.toLowerCase());
      final isDateRangeMatch =
          (startDate.value.isEmpty || endDate.value.isEmpty) ||
              (order.date!.compareTo(startDate.value) >= 0 &&
                  order.date!.compareTo(endDate.value) <= 0);
      return isShopMatch && isOrderNoMatch && isStatusMatch && isDateRangeMatch;
    }).toList();
  }

  // Convert filtered rows to a list of maps
  List<Map<String, dynamic>> get filteredRowsAsMapList {
    return filteredRowsMaster.map((order) {
      return {
        'Order No': order.order_master_id,
        'Date': order.order_master_date,
        'Shop': order.shop_name,
        'Status': order.order_status,
        'Amount': order.total
      };
    }).toList();
  }

  // Handle button actions (e.g., Order PDF, Products PDF)
  void handleButtonAction(String action) {
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

    Get.snackbar('Action', '$action pressed!');
  }
}
