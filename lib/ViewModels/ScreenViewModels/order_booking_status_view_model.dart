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


    Get.snackbar('Action', '$action pressed!');
  }
}
