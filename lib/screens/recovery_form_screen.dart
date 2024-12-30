import 'package:flutter/material.dart';
class RecoveryFormScreen extends StatefulWidget {
  const RecoveryFormScreen({super.key});

  @override
  _RecoveryformScreenState createState() => _RecoveryformScreenState();
}

class _RecoveryformScreenState extends State<RecoveryFormScreen> {
  // Dropdown items and selected value
  final List<String> _shops = ["Shop 1", "Shop 2", "Shop 3", "Shop 4"];
  String? _selectedShop; // Holds the selected shop value

  // Controller for date fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Sample data for the data table (replace this with your dynamic data)
  final List<Map<String, String>> _paymentHistory = [
    {"Date": "2024-12-01", "Amount": "\$100", "Status": "Completed"},
    {"Date": "2024-12-05", "Amount": "\$50", "Status": "Pending"},
    {"Date": "2024-12-10", "Amount": "\$200", "Status": "Completed"},
  ];

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
                'Recovery Form',
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
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Shop Name",
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
                    // Row with TextField and text widget aligned on the right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 30),
                        // TextField on the right
                        _buildTextField(
                          label: "",
                          keyboardType: TextInputType.text,
                          width: size.width * 0.36, // Adjusts to 60% of screen width
                          height: 60,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "----- Previous Payment History -----",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // DataTable for displaying payment history
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                      ],
                      rows: _paymentHistory.map((payment) {
                        return DataRow(cells: [
                          DataCell(Text(payment["Date"] ?? "")),
                          DataCell(Text(payment["Amount"] ?? "")),
                          DataCell(Text(payment["Status"] ?? "")),
                        ]);
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // Row with text and a text box with underline border horizontally
                    Row(
                      children: [
                        const Text(
                          "Cash Recovery",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // TextField for Cash Recovery
                        _buildTextField(
                          label: "",
                          keyboardType: TextInputType.text,
                          width: size.width * 0.5, // Adjusts to 60% of screen width
                          height: 40,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "New Balance",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 30),
                        // TextField for New Balance
                        _buildTextField(
                          label: "",
                          keyboardType: TextInputType.text,
                          width: size.width * 0.5, // Adjusts to 60% of screen width
                          height: 60,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        // Implement your submit action here
                        print("Form Submitted");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
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