import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ViewModels/login_view_model.dart';
import 'location_screen.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic data for the widgets
    const IconData icon = Icons.camera_alt_rounded;
    const String headerText = "Camera Permission";
    const String descriptionText = "Allow access to use the camera feature.";

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
              highlightedIndex: 0,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: CustomButton(
              buttonText: 'ALLOW',
              onPressed: () async {
                // Request camera permission
                PermissionStatus cameraStatus = await Permission.camera.request();

                if (cameraStatus.isGranted) {
                  // Navigate to the LocationScreen
                  Get.to(() => const LocationScreen());
                } else {
                  // Show a snackbar if permission is denied
                  Get.snackbar(
                    'Permission Denied',
                    'You need to allow camera permission to continue.',
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
