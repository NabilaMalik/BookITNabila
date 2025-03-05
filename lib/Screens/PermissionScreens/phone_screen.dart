import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';
import 'record_audio_screen.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic content for the screen
    const IconData icon = Icons.phone;
    const String headerText = "Phone Permission";
    const String descriptionText =
        "Grant phone access to make calls directly from the app.";

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          Positioned(
            bottom: screenHeight * 0.6,
            top: 0,
            left: 0,
            right: 0,
            child: HeaderWidget(
              icon: icon,
              screenWidth: screenWidth,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            child: ContentWidget(
              headerText: headerText,
              descriptionText: descriptionText,
              highlightedIndex: 4,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: CustomButton(
              buttonText: 'ALLOW',
              onPressed: () async {
                // Request phone permission
                Get.to(() => const RecordAudioScreen());
                PermissionStatus phoneStatus = await Permission.phone.request();

                if (phoneStatus.isGranted) {
                  // Navigate to RecordAudioScreen
                  Get.to(() => const RecordAudioScreen());
                } else {
                  // Show a snackbar if permission is denied
                  Get.snackbar(
                    'Permission Denied',
                    'You need to allow phone permission to proceed.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
