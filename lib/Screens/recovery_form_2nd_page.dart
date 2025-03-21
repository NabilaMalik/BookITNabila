import 'package:flutter/foundation.dart' show Uint8List, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'home_screen.dart';

class RecoveryForm_2ndPage extends StatelessWidget {

 RecoveryForm_2ndPage({super.key});
  RecoveryFormViewModel recoveryFormViewModel = Get.put(RecoveryFormViewModel());

  @override
  Widget build(BuildContext context) {
    // String recoveryId = formData['recoveryId'];
    // String date = DateFormat('dd-MMM-yyyy : HH-mm-ss').format(DateTime.now());
    // String shopName = formData['shopName'];
    // String cashRecovery = formData['cashRecovery'];
    // String netBalance = formData['netBalance'];


    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  buildTextFieldRow('Receipt:', recoveryFormViewModel.recovery_id.value),
                  buildTextFieldRow('Date:' , DateFormat('dd-MMM-yyyy : HH-mm-ss').format(DateTime.now())),

                  buildTextFieldRow('Shop Name:', recoveryFormViewModel.selectedShop.value),
                  buildTextFieldRow('Payment Amount:', recoveryFormViewModel.cash_recovery.value.toString()),
                  buildTextFieldRow('Net Balance:', recoveryFormViewModel.net_balance.value.toString()),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 80,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          generateAndSharePDF(
                              recoveryFormViewModel.recovery_id.value,
                              DateFormat('dd-MMM-yyyy : HH-mm-ss').format(DateTime.now()),
                              recoveryFormViewModel.selectedShop.value,
                              recoveryFormViewModel.cash_recovery.value.toString(),
                              recoveryFormViewModel.net_balance.value.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(color: Colors.orange),
                          ),
                          elevation: 8.0,
                        ),
                        child: const Text('PDF', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100,
                      height: 30,
                      margin: const EdgeInsets.only(right: 16, bottom: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                        await  recoveryFormViewModel.resetForm();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                          elevation: 8.0,
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldRow(String labelText, String text) {
    TextEditingController controller = TextEditingController(text: text);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              labelText,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: Colors.green),
              ),
              child: TextField(
                readOnly: true,
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generateAndSharePDF(
      String recoveryId,
      String date,
      String shopName,
      String cashRecovery,
      String netBalance,
      ) async {
    final pdf = pw.Document();

    // Load the logo image
    final Uint8List logoBytes =
    (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
    final image = pw.MemoryImage(logoBytes);

    // Define a custom page format with margins
    var pdfPageFormat = PdfPageFormat.a4;  // Use the predefined page size (A4)

    pdf.addPage(
      pw.Page(
        pageFormat: pdfPageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo and Heading
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 10.0),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 120,
                      width: 120,
                      child: pw.Image(image),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Valor Trading',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Recovery Slip',
                style: pw.TextStyle(
                  fontSize: 23,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(horizontal: 60.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Date: ${DateFormat('dd-MMM-yyyy : HH-mm-ss').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 12),
                    pw.Text('Receipt#: $recoveryId', style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Shop Name: $shopName',
                      style: const pw.TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text('Payment Amount: $cashRecovery', style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 12),
                    pw.Text('Net Balance: $netBalance', style: const pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 20.0),
                child: pw.Text(
                  'Developed by MetaXperts',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final output = File('${directory.path}/recovery_form_$recoveryId.pdf');
    await output.writeAsBytes(await pdf.save());
    final xfile = XFile(output.path);
    await Share.shareXFiles([xfile], text: 'PDF Document');
  }
}
