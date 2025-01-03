import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';
import 'storage_screen.dart';


class RecordAudioScreen extends StatelessWidget {
  const RecordAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Static content for the screen
    const IconData icon = Icons.mic_rounded;
    const String headerText = "Mic Permission";
    const String descriptionText =
        "Grant microphone access to record audio during app use.";

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          // Header Widget
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
          // Content Widget
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            child: ContentWidget(
              headerText: headerText,
              descriptionText: descriptionText,
              highlightedIndex: 5,
            ),
          ),
          // Custom Button
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: CustomButton(
              buttonText: 'ALLOW',
              onPressed: () async {
                // Request microphone permission
                PermissionStatus microphoneStatus =
                await Permission.microphone.request();

                if (microphoneStatus.isGranted) {
                  // Navigate to the next screen
                  Get.to(() => const StorageScreen());
                } else {
                  // Show a snackbar if permission is denied
                  Get.snackbar(
                    'Permission Denied',
                    'You need to allow microphone permission to proceed.',
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
