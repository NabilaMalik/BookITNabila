import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/NSM/nsm_order_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Tracker/location00.dart';
import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../HomeScreenComponents/timer_card.dart';
import 'NSMOrderDetails/nsm_order_details_screen.dart';
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
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());


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
          iconTheme: const IconThemeData(color: Colors.blue),
          automaticallyImplyLeading: false,
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
                    Colors.blue,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [


                // const SizedBox(width: 50),
                TimerCard(), // Add the TimerCard here

              ],
            ),// Add the TimerCard here

            const SizedBox(height: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              version,
              style: const TextStyle(
                fontFamily: 'avenir next',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
  ]
        ),

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
        if (newIsClockedIn==true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NSMShopVisitPage(),
            ),
          );
        } else {
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
          // MaterialPageRoute(builder: (context) => NSMBookingBookPage()),
          MaterialPageRoute(builder: (context) => NsmOrderDetailsScreen()),
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
