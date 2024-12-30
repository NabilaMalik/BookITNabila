import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductSearchCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final RxList<Map<String, dynamic>> filteredRows;

  const ProductSearchCard({
    required this.filterData,
    required this.rowsNotifier,
    required this.filteredRows,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // You can adjust this height
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onChanged: filterData,
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: rowsNotifier,
                builder: (context, rows, child) {
                  final rowsToShow = filteredRows.isNotEmpty ? filteredRows : rows;

                  if (rowsToShow.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                      scrollDirection: Axis.vertical, // This will allow vertical scrolling
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.blue.shade100,
                        ),
                        dataRowColor: WidgetStateColor.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                        ),
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnSpacing: 10,
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 200, // Set a fixed width for the product column
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
                              child: Center(// Set a fixed width for the quantity column
                              child: Text(
                                'Quantity',                                    textAlign: TextAlign.center, // Center the text in the field

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),)
                          ),
                        ],
                        rows: rowsToShow.map(
                              (row) {
                            final quantityController = TextEditingController(
                              text: (row['Quantity'] ?? '').toString(),
                            );

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(row['Product'] ?? '', overflow: TextOverflow.ellipsis),
                                ),
                                DataCell(
                                  TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      // Update the row with the new quantity
                                      row['Quantity'] = int.tryParse(value) ?? 0;
                                      filteredRows.refresh();
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 1, // Reduced vertical padding
                                        horizontal: 8, // Reduced horizontal padding
                                      ),
                                    ),
                                    textAlign: TextAlign.center, // Center the text in the field
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
