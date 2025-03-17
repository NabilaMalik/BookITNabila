import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Tracker/location00.dart';
import 'NSM_ShopVisit.dart';
import 'NSM_bookerbookingdetails.dart';
import 'nsm_bookingStatus.dart';
import 'NSM LOCATIONS/nsm_location_navigation.dart';
import 'nsm_shopdetails.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io' show File, InternetAddress, SocketException;

import '../../Tracker/trac.dart';

import '../../main.dart';

import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatus, PermissionStatusGetters, openAppSettings;
class NSMHomepage extends StatefulWidget {
  const NSMHomepage({super.key});

  @override
  NSMHomepageState createState() => NSMHomepageState();
}

class NSMHomepageState extends State<NSMHomepage> {
  int? attendanceId;
  int? attendanceId1;
  double? globalLatitude1;
  double? globalLongitude1;
  DBHelper dbHelper = DBHelper();
  bool isLoadingReturn= false;
  final loc.Location location = loc.Location();
  bool isLoading = false; // Define isLoading variable
  Timer? _timer;
  bool pressClockIn = false;
  late StreamSubscription<ServiceStatus> locationServiceStatusStream;


  @override
  void initState() {
    super.initState();
    // checkAndSetInitializationDateTime();
    // backgroundTask();
    // WidgetsBinding.instance.addObserver(this);

    _retrieveSavedValues();


    //_requestPermission();
    // location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);

    _checkForUpdate(); // Check for updates when the screen opens
  }
  void _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'TASK_FAILURE' && e.message?.contains('Install Error(-10)') == true) {
        if (kDebugMode) {
          print("The app is not owned by any user on this device. Update check skipped.");
        }
      } else {
        if (kDebugMode) {
          print("Failed to check for updates: $e");
        }
      }
    }
  }
  @override
  void dispose() {
    locationServiceStatusStream.cancel();
    super.dispose();
  }
  // void _monitorLocationService() {
  //   locationServiceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
  //     if (status == ServiceStatus.disabled && isClockedIn) {
  //       await _handleClockOut();
  //     }
  //   });
  // }






  _retrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      userCity = prefs.getString('userCity') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userNSM= prefs.getString('userNSM') ?? 'NULL';
      userSM= prefs.getString('userSM') ?? 'NULL';
      userRSM= prefs.getString('userRSM') ?? 'NULL';
    });
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Please Wait..."),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              '$user_id  $userName',
              style: const TextStyle(
                  fontFamily: 'avenir next',
                  fontSize: 17
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.green),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: () {
                // _handleRefresh();
              },
            ),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Grid view for cards
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: 5, // Updated item count
                itemBuilder: (context, index) {
                  final cardInfo = [
                    {'title': 'Shop Visit', 'icon': Icons.store},
                    {'title': 'Booker Status', 'icon': Icons.person},
                    {'title': 'Shop Details', 'icon': Icons.info},
                    {'title': 'Booker Order Details', 'icon': Icons.book},
                    {'title': 'Location', 'icon': Icons.location_on}, // New card
                  ][index];
                  return _buildCard(
                    context,
                    cardInfo['title'] as String,
                    cardInfo['icon'] as IconData,
                    Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       'Timer: ${_formatDuration(newsecondpassed.toString())}',
            //       style: const TextStyle(
            //         fontFamily: 'avenir next',
            //         fontSize: 14,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     const SizedBox(width: 55),
            //     ElevatedButton.icon(
            //       onPressed: _toggleClockInOut,
            //       icon: Icon(isClockedIn ? Icons.timer_off : Icons.timer,color: isClockedIn ? Colors.red : Colors.white),
            //       label: Text(
            //         isClockedIn ? 'Clock Out' : 'Clock In',
            //         style: const TextStyle(
            //           fontFamily: 'avenir next',
            //           fontSize: 14,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: isClockedIn ? Colors.red : Colors.white,
            //         backgroundColor: Colors.green, // Background color
            //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //       ),
            //     ),
            //   ],
            // ),
        const SizedBox(height: 0),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Text(
  //             version,
  //             style: const TextStyle(
  //               fontFamily: 'avenir next',
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  // ]
  //       ),

          ],
        ),
      ),
    )
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4, // Slightly reduced elevation for a smaller card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Slightly smaller border radius
      ),
      child: InkWell(
        onTap: () {
          _navigateToPage(context, title);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(10.0), // Match border radius
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 24, // Slightly smaller icon size
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced space between icon and title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'avenir next',
                      fontSize: 12, // Slightly smaller font size
                      fontWeight: FontWeight.bold,
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

  void _navigateToPage(BuildContext context, String title) {
    switch (title) {
      case 'Shop Visit':
        // if (isClockedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NSMShopVisitPage(),
            ),
          );
        // } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clock In Required'),
              content: const Text('Please clock in before visiting a shop.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        // }
        break;
      case 'Booker Status':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NSMBookingStatus()),
        );
        break;
      case 'Shop Details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NSMShopDetailPage()),
        );
        break;
      case 'Booker Order Details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NSMBookingBookPage()),
        );
        break;
      case 'Location':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NsmLocationNavigation()),
        );
        break;
    }
  }
}
