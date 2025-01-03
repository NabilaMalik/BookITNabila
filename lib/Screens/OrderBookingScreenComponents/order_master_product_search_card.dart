import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../ViewModels/ScreenViewModels/order_booking_view_model.dart';

class OrderMasterProductSearchCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final RxList<Map<String, dynamic>> filteredRows;
  final OrderBookingViewModel viewModel; // Add reference to the ViewModel

  const OrderMasterProductSearchCard({
    required this.filterData,
    required this.rowsNotifier,
    required this.filteredRows,
    required this.viewModel, // Add the ViewModel to constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    searchController.addListener(() {
      filterData(searchController.text);
    });

    return SizedBox(
      height: 400,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Expanded(
              child: Obx(() {
                final rowsToShow =
                    filteredRows.isNotEmpty ? filteredRows : rowsNotifier.value;

                if (rowsToShow.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'No matching products found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.blue.shade100,
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                      ),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnSpacing: 10,
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 150,
                            child: Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                'Quantity',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                'In Stock',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                'Rate',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                'Amount',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: rowsToShow.map(
                        (row) {
                          final quantityController = TextEditingController(
                            text: (row['Quantity'] ?? '').toString(),
                          );
                          final inStockController = TextEditingController(
                            text: (row['In Stock'] ?? '').toString(),
                          );
                          final rateController = TextEditingController(
                            text: (row['Rate'] ?? '').toString(),
                          );
                          final amountController = TextEditingController(
                            text: (row['Amount'] ?? '').toString(),
                          );

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(row['Product'] ?? '',
                                    overflow: TextOverflow.ellipsis),
                              ),
                              DataCell(
                                TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    row['Quantity'] = int.tryParse(value) ?? 0;
                                    _updateAmount(row, amountController);
                                    viewModel
                                        .updateTotal(); // Update total here
                                    filteredRows.refresh();
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: 8,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: inStockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    row['In Stock'] = int.tryParse(value) ?? 0;
                                    viewModel
                                        .updateTotal(); // Update total here
                                    filteredRows.refresh();
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: 8,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: rateController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d*')),
                                  ],
                                  onChanged: (value) {
                                    row['Rate'] = double.tryParse(value) ?? 0.0;
                                    _updateAmount(row, amountController);
                                    viewModel
                                        .updateTotal(); // Update total here
                                    filteredRows.refresh();
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: 8,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: 8,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAmount(
      Map<String, dynamic> row, TextEditingController amountController) {
    final quantity = row['Quantity'] ?? 0;
    final rate = row['Rate'] ?? 0.0;
    final amount = quantity * rate;
    row['Amount'] = amount;
    amountController.text = amount.toString();
  }
}
