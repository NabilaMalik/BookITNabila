
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';

import '../../Models/ScreenModels/order_status_models.dart';
import '../../Models/order_master_model.dart';

class OrderBookingStatusRepository {
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  // Simulating a delay like fetching data from an API or Database
  Future<List<OrderBookingStatusModel>> fetchOrders() async {
    //await orderMasterViewModel.fetchAllConfirmOrder();
    // Access the list of OrderMasterModel from the ViewModel
    List<OrderMasterModel> allOrders = orderMasterViewModel.allOrderMaster;

    // Simulate a network delay (optional)
   // await Future.delayed(const Duration(seconds: 2));

    // Map each OrderMasterModel to OrderBookingStatusModel
    List<OrderBookingStatusModel> mappedOrders = allOrders.map((order) {
      return OrderBookingStatusModel(
        orderNo: order.order_master_id!, // Assuming 'orderNo' exists in OrderMasterModel
        date: order.required_delivery_date !,
        // date: order.order_master_date != null
        //     ? DateFormat('yyyy-MM-dd').format(order.order_master_date!) // Convert DateTime to String
        //     : '',
        shop: order.shop_name!,   // Assuming 'shopName' exists in OrderMasterModel
        amount: order.total!, // Parse String to int, default to 0 if parsing fails
        status: order.order_status!,   // Assuming 'status' exists in OrderMasterModel
      );
    }).toList();

    // Return the dynamically generated list
    return mappedOrders;
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
