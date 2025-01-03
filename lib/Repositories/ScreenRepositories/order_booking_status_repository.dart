
import '../../Models/ScreenModels/order_status_models.dart';

class OrderBookingStatusRepository {
  // Simulating a delay like fetching data from an API or Database
  Future<List<OrderBookingStatusModel>> fetchOrders() async {
   // await Future.delayed(const Duration(seconds: 2)); // Simulating network delay
    return [
      OrderBookingStatusModel(orderNo: '12345',date: " date", shop: 'Product A', amount: 10, status: 'Completed'),
      OrderBookingStatusModel(orderNo: '12346',date: " date", shop: 'Product B', amount: 5, status: 'Pending'),
      OrderBookingStatusModel(orderNo: '12347',date: " date", shop: 'Product C', amount: 8, status: 'Processing'),
      OrderBookingStatusModel(orderNo: '12347',date: " date", shop: 'Product C', amount: 8, status: 'Processing'),
    ];
  }

  // Handle Errors
  Future<List<OrderBookingStatusModel>> safeFetchOrders() async {
    try {
      return await fetchOrders();
    } catch (e) {
      // Log or handle error
      rethrow;
    }
  }

// Add more methods to interact with data (e.g., update, delete orders)
}
