import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import '../Databases/util.dart';
import 'Components/custom_button.dart';

class ReconfirmOrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rows;

  const ReconfirmOrderScreen({required this.rows, super.key});

  @override
  _ReconfirmOrderScreenState createState() => _ReconfirmOrderScreenState();
}

class _ReconfirmOrderScreenState extends State<ReconfirmOrderScreen> {
  int _currentPage = 0;
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  ShopVisitViewModel shopVisitViewModel =Get.put(ShopVisitViewModel());

  void _nextPage() {
    setState(() {
      if ((_currentPage + 1) * 10 < widget.rows.length) {
        _currentPage++;
      }
    });
  }

  void _prevPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  List<Map<String, dynamic>> _getCurrentPageRows() {
    int startIndex = _currentPage * 10;
    int endIndex = startIndex + 10;
    if (endIndex > widget.rows.length) {
      endIndex = widget.rows.length;
    }
    return widget.rows.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Order Invoice',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white,),
            onPressed: () {
              // Add your share functionality here
            },
          ),
        ],
      ),

      body: SingleChildScrollView( child:
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(label: 'Order ID', value: order_master_id),
            _buildField(label: 'Customer Name', value: shopVisitViewModel.selectedShop.value),
            _buildField(label: 'Phone Number', value: '+1234567890'),

            const Divider(color: Colors.grey),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // Example: 50% of screen height
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: _getCurrentPageRows().map((row) {
                        int index = _getCurrentPageRows().indexOf(row);
                        return OrderSummaryRow(
                          serialNumber: (_currentPage * 10) + index + 1,
                          rowData: row,
                        );
                      }).toList(),
                    ),
                  ),

                  _buildPaginationControls(),
                  const Divider(color: Colors.grey),
                ],
              ),
            ),
            const OrderFooter(),

            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                textSize: 14,
                spacing: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                height: 40,
                width: 120,
                buttonText: "Close",
                onTap: orderMasterViewModel.confirmSubmitForm,
                gradientColors: [Colors.red, Colors.red],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildField({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '', style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: _prevPage,
            child: const Text('View Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        if ((_currentPage + 1) * 5 < widget.rows.length)
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('View Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),

      ],
    );
  }
}

class OrderSummaryRow extends StatelessWidget {
  final int serialNumber;
  final Map<String, dynamic> rowData;

  const OrderSummaryRow({
    Key? key,
    required this.serialNumber,
    required this.rowData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              serialNumber.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(rowData['Product'], style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(rowData['Enter Qty'].toString(), style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,

            child: Text(rowData['Amount'].toString(), style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}


class OrderFooter extends StatefulWidget {

  const OrderFooter({super.key});

  @override
  State<OrderFooter> createState() => _OrderFooterState();
}

class _OrderFooterState extends State<OrderFooter> {
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Total',
            value: orderDetailsViewModel.total.value,
          ),
          _buildField(
            label: 'Credit Limit',
            value: orderMasterViewModel.credit_limit.value,
          ),
          _buildField(
            label: 'Required Date',
            value: orderMasterViewModel.requiredDelivery.value,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              buttonText: "CONFIRM ORDER",
              onTap: orderMasterViewModel.confirmSubmitForm,
              gradientColors: [Colors.blue, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
