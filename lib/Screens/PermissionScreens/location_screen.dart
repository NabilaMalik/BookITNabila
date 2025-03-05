import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/PermissionScreens/contact_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';
import 'notification_screen.dart';


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
        "This app collects location data to enable tracking and share your location to server even when the app is closed or not in use.";

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
            child: const ContentWidget(
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
                if (await Permission.location.request().isDenied) {
                  // Location permission not granted
                  if (kDebugMode) {
                    print('Location permission denied');
                  }
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                } else if (await Permission.location.request().isGranted) {
                  if (kDebugMode) {
                    print('Location permission granted');
                  }
                  // Check and request background location permission if necessary
                  if (await Permission.locationAlways.request().isDenied) {
                    // Background location permission not granted
                    if (kDebugMode) {
                      print('Background location permission denied');
                    }
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  } else {
                    // All permissions granted
                    if (kDebugMode) {
                      print('All permissions granted');
                    }
                    Get.to(() => const ContactScreen());
                  }
                }
              },
            )

          ),
        ],
      ),
    );
  }
}
