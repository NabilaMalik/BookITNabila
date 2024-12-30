import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnFormScreen extends StatefulWidget {
  const ReturnFormScreen({super.key});

  @override
  _ReturnformScreenState createState() => _ReturnformScreenState();
}

class _ReturnformScreenState extends State<ReturnFormScreen> {
  // Dropdown items and selected value
  final List<String> _shops = ["Shop 1", "Shop 2", "Shop 3", "Shop 4"];
  String? _selectedShop; // Holds the selected shop value

  // List of rows (each row contains controllers for the text fields)
  final List<Map<String, dynamic>> _rows = [];

  // A helper method to build TextField widgets with custom decoration
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required double width,
    required double height,
    double fontSize = 16.0, // Default font size
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
                'Return Form',
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
                    // Dropdown for selecting shop
                    SizedBox(
                      width: size.width * 0.8, // Adjusts to 80% of screen width
                      child:
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Select Shop",
                          labelStyle: TextStyle(fontSize: 18),
                          border: UnderlineInputBorder(), // Adds a bottom border
                        ),
                        value: _selectedShop, // Selected value
                        items: _shops.map((shop) {
                          return DropdownMenuItem(
                            value: shop,
                            child: Text(shop),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedShop = value; // Update selected shop
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Dynamic rows with text fields and delete icons
                    Column(
                      children: _rows.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> row = entry.value;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTextField(
                              label: "Item",
                              controller: row['itemController'],
                              width: size.width * 0.2, // 20% of screen width
                              height: 50,
                              fontSize: 20.0, // Set font size for Item field
                            ),
                            _buildTextField(
                              label: "Qty",
                              controller: row['qtyController'],
                              width: size.width * 0.2, // 20% of screen width
                              height: 50,
                              fontSize: 20.0, // Set font size for Qty field
                            ),
                            _buildTextField(
                              label: "Reason",
                              controller: row['reasonController'],
                              width: size.width * 0.3, // 30% of screen width
                              height: 50,
                              fontSize: 20.0, // Set font size for Reason field
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _rows.removeAt(index); // Remove the selected row
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // Add Row Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _rows.add({
                                'itemController': TextEditingController(),
                                'qtyController': TextEditingController(),
                                'reasonController': TextEditingController(),
                              });
                            });

                            Get.snackbar("Action", "New row added!",
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 45, vertical: 15),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Border radius
                            ),
                          ),
                          child: const Text(
                            'Add Row',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Submit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Add submit action here
                            Get.snackbar("Action", "Form Submitted!",
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Border radius
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
        );
  }
}