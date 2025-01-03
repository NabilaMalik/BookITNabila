import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReconfirmOrderScreen extends StatefulWidget {
  const ReconfirmOrderScreen({super.key});

  @override
  _ReconfirmOrderScreenState createState() => _ReconfirmOrderScreenState();
}

class _ReconfirmOrderScreenState extends State<ReconfirmOrderScreen> {
  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      readOnly: true,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: Colors.blue, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Re-Confirm Order',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildTextField(label: 'Order ID', keyboardType: TextInputType.text),
                const SizedBox(height: 16),
                _buildTextField(label: 'Customer Name', keyboardType: TextInputType.text),
                const SizedBox(height: 16),
                _buildTextField(label: 'Phone Number', keyboardType: TextInputType.phone),
                const SizedBox(height: 32),
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(label: 'Description', keyboardType: TextInputType.text),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(label: 'Qty', keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(label: 'Amount', keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                _buildTotalRow("Total"),
                const SizedBox(height: 16),
                _buildTotalRow("Credit Limit"),
                const SizedBox(height: 16),
                _buildTotalRow("Required"),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar("Action", "Reconfirm Order!",
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Reconfirm',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton("PDF", Colors.blue[900]!),
                    _buildActionButton("Close", Colors.red[700]!),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildTextField(label: "", keyboardType: TextInputType.text),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        Get.snackbar("Action", "$label Button Pressed!",
            snackPosition: SnackPosition.BOTTOM);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
