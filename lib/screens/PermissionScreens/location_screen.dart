import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';

import 'contact_screen.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic data for the screen
    const IconData icon = Icons.location_on;
    const String headerText = "Location Permission";
    const String descriptionText =
        "Allow access to use location services for better experience.";

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
              highlightedIndex: 1,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: CustomButton(
              buttonText: 'ALLOW',
              onPressed: () async {
                // Request location permission
                PermissionStatus locationStatus =
                await Permission.location.request();

                if (locationStatus.isGranted) {
                  // Navigate to ContactScreen
                  Get.to(() => const ContactScreen());
                } else {
                  // Show snackbar if permission is denied
                  Get.snackbar(
                    'Permission Denied',
                    'You need to allow location permission to continue.',
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
