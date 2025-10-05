import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:order_booking_app/Databases/dp_helper.dart';


import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io' show File, InternetAddress, SocketException;
import '../../Databases/util.dart';
import '../../Tracker/trac.dart';
import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../../main.dart';
import '../HomeScreenComponents/timer_card.dart';
import 'LIVE_location_page.dart';
import 'BookerStatus.dart';
import 'RSMOrderDetails/rsm_order_details_screen.dart';
import 'RSM_ShopDetails.dart';
import 'RSM_ShopVisit.dart';
import 'RSM_bookerbookingdetails.dart';
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatus, PermissionStatusGetters, openAppSettings;
import 'landing_page.dart';
// Import other pages if needed

class RSMHomepage extends StatefulWidget {
  const RSMHomepage({Key? key}) : super(key: key);

  @override
  _RSMHomepageState createState() => _RSMHomepageState();
}

class _RSMHomepageState extends State<RSMHomepage> {
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());

  late StreamSubscription<ServiceStatus> locationServiceStatusStream;



  @override
  void initState() {
    super.initState();
    addShopViewModel.fetchAllAddShop();
    attendanceViewModel.fetchAllAttendance();
    attendanceOutViewModel.fetchAllAttendanceOut();
    _retrieveSavedValues();
    checkForUpdate(); // Check for updates when the screen opens
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
      userCity= prefs.getString('userCity') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userSM = prefs.getString('userSM') ?? '';
      userNSM = prefs.getString('userNSM') ?? '';
      userRSM= prefs.getString('userRSM') ?? '';
      shopVisitHeadsHighestSerial = prefs.getInt('shopVisitHeadsHighestSerial') ?? 1;
    });
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button press
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
        // Return false to prevent going back
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = 17;
          double iconSize = 24;
          double gridCrossAxisCount = 2;
          double gridSpacing = 16.0;
          double cardHeight = 150.0;
          double buttonFontSize = 16;
          double timerFontSize = 14;

          // Adjust layout based on the screen width
          if (constraints.maxWidth < 360) {
            fontSize = 14;
            iconSize = 20;
            gridCrossAxisCount = 1;
            gridSpacing = 8.0;
            cardHeight = 120.0;
            buttonFontSize = 14;
            timerFontSize = 12;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Center(
                child: Text(
                  '$user_id  $userName',
                  style: TextStyle(
                    fontFamily: 'avenir next',
                    fontSize: fontSize,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1, // Add a subtle shadow
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () {
                    // _handleRefresh();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCrossAxisCount.toInt(),
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                      ),
                      itemCount: 4, // Display the first four cards in the grid
                      itemBuilder: (context, index) {
                        final cardInfo = [
                          {'title': 'SHOP VISIT', 'icon': Icons.store, 'color': Colors.blue},
                          {'title': 'BOOKERS STATUS', 'icon': Icons.person, 'color': Colors.blue},
                          {'title': 'SHOPS DETAILS', 'icon': Icons.info, 'color': Colors.blue},
                          {'title': 'BOOKERS ORDER DETAILS', 'icon': Icons.book, 'color': Colors.blue},
                          {'title': 'Location', 'icon': Icons.location_on},
                        ][index];
                        return _buildCard(
                          context,
                          cardInfo['title'] as String,
                          cardInfo['icon'] as IconData,
                          cardInfo['color'] as Color,
                          iconSize,
                        );
                      },
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: constraints.maxWidth / 2 - gridSpacing * 1.5, // Same width as grid items
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SizedBox(
                          height: cardHeight, // Adjust the height of the card
                          child: _buildCard(
                            context,
                            'LIVE LOCATION',
                            Icons.location_on,
                            Colors.blue,
                            iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 54),
                  // Adjust the spacing after the "LIVE LOCATION" card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [


                      // const SizedBox(width: 50),
                      TimerCard(), // Add the TimerCard here

                    ],
                  ),// Add the TimerCard here

                  const SizedBox(height: 10), // Add some space after the button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        version,
                        style: TextStyle(
                          fontFamily: 'avenir next',
                          fontSize: timerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, double iconSize) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
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
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
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
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'avenir next',
                      fontSize: 12,
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
    // Navigation logic based on the title
    switch (title) {
      case 'SHOP VISIT':
         if (newIsClockedIn==true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShopVisitPage(),
            ),
          );
         }
         else {
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
         }
        break;
      case 'BOOKERS STATUS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RSMBookerStatus()),
        );
        break;
      case 'SHOPS DETAILS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopDetailPage()),
        );
        break;
      case 'BOOKERS ORDER DETAILS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RsmOrderDetailsScreen()),
          // MaterialPageRoute(builder: (context) => RSMBookingBookPage()),
        );
        break;
      case 'LIVE LOCATION':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiveLocationPage()),
        );
        break;
    }
  }
}


