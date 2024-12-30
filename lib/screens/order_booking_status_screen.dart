import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderBookingStatusScreen extends StatefulWidget {
  const OrderBookingStatusScreen({super.key});

  @override
  _OrderBookingStatusScreenState createState() =>
      _OrderBookingStatusScreenState();
}

class _OrderBookingStatusScreenState extends State<OrderBookingStatusScreen> {
  // Controller for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Method to show a date picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // A helper method to build TextField widgets with custom decoration
  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    TextEditingController? controller,
    double width = 200,
    double height = 50,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          border: const UnderlineInputBorder(), // Adds a bottom border
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Order Booking Status',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              centerTitle: true,
              backgroundColor: Colors.blue,
            ),
            body: Container(
              color: Colors.white,
              width: size.width,
              height: size.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // First Row: Shop and Order
                    Row(
                      children: [
                        const Text(
                          "Shop:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 7),
                        _buildTextField(
                          label: "Enter shop name",
                          keyboardType: TextInputType.text,
                          width: 130,
                          height: 40,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          "Order:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 7),
                        _buildTextField(
                          label: "Enter order ID",
                          keyboardType: TextInputType.text,
                          width: 130,
                          height: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Second Row: Date Range
                    Row(
                      children: [
                        const Text(
                          "Date Range:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        _buildTextField(
                          label: "Start Date",
                          keyboardType: TextInputType.text,
                          controller: _startDateController,
                          width: 120,
                          height: 40,
                          readOnly: true,
                          onTap: () => _selectDate(context, _startDateController),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "To:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 7),
                        _buildTextField(
                          label: "End Date",
                          keyboardType: TextInputType.text,
                          controller: _endDateController,
                          width: 112,
                          height: 40,
                          readOnly: true,
                          onTap: () => _selectDate(context, _endDateController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Third Row: Status and Button
                    Row(
                      children: [
                        const Text(
                          "Status:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 7),
                        _buildTextField(
                          label: "Enter status",
                          keyboardType: TextInputType.text,
                          width: 120,
                          height: 40,
                        ),
                        const SizedBox(width: 60),
                        SizedBox(
                          width: 128,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              // Button action
                              Get.snackbar("Action", "Filters cleared!");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shadowColor: Colors.black,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Clear Filters",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Two Buttons in Horizontal Layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              // Button action for Order PDF
                              Get.snackbar("Action", "Order PDF pressed!");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              shadowColor: Colors.black,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Order PDF",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              // Button action for Products PDF
                              Get.snackbar("Action", "Products PDF pressed!");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shadowColor: Colors.black,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Products PDF",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Data Table Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('Order ID',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(
                              label: Text('Product Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(
                              label: Text('Quantity',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('12345')),
                            DataCell(Text('Product A')),
                            DataCell(Text('10')),
                            DataCell(Text('Completed')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('12346')),
                            DataCell(Text('Product B')),
                            DataCell(Text('5')),
                            DataCell(Text('Pending')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('12347')),
                            DataCell(Text('Product C')),
                            DataCell(Text('8')),
                            DataCell(Text('Processing')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
        );
    }
}