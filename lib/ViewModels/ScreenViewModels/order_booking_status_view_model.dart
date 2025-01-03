import 'package:get/get.dart';
import '../../Models/ScreenModels/order_status_models.dart';
import '../../Repositories/ScreenRepositories/order_booking_status_repository.dart';

class OrderBookingStatusViewModel extends GetxController {
  // Observables
  var orders = <OrderBookingStatusModel>[].obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var shopName = ''.obs;
  var orderId = ''.obs;
  var status = ''.obs;
  var filteredRows = <OrderBookingStatusModel>[].obs;

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
    shopName.value = '';
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
      final isShopMatch = shopName.value.isEmpty ||
          order.shop.toLowerCase().contains(shopName.value.toLowerCase());
      final isOrderNoMatch = orderId.value.isEmpty ||
          order.orderNo.toLowerCase().contains(orderId.value.toLowerCase());
      final isStatusMatch = status.value.isEmpty ||
          order.status.toLowerCase().contains(status.value.toLowerCase());
      final isDateRangeMatch =
          (startDate.value.isEmpty || endDate.value.isEmpty) ||
              (order.date.compareTo(startDate.value) >= 0 &&
                  order.date.compareTo(endDate.value) <= 0);
      return isShopMatch && isOrderNoMatch && isStatusMatch && isDateRangeMatch;
    }).toList();
  }

  // Convert filtered rows to a list of maps
  List<Map<String, dynamic>> get filteredRowsAsMapList {
    return filteredRows.map((order) {
      return {
        'Order No': order.orderNo,
        'Date': order.date,
        'Shop': order.shop,
        'Status': order.status,
        'Amount': order.amount
      };
    }).toList();
  }

  // Handle button actions (e.g., Order PDF, Products PDF)
  void handleButtonAction(String action) {
    Get.snackbar('Action', '$action pressed!');
  }
}
