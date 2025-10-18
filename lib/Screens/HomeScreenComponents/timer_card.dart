// // // // // import 'dart:async';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // // // import 'package:get/get.dart';
// // // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // // // import 'package:rive/rive.dart';
// // // // // import 'package:location/location.dart' as loc;
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // import '../../Tracker/trac.dart';
// // // // // import '../../main.dart';
// // // // // import 'assets.dart';
// // // // // import 'menu_item.dart';
// // // // //
// // // // // class TimerCard extends StatelessWidget {
// // // // //   // ViewModels
// // // // //   final locationViewModel = Get.put(LocationViewModel());
// // // // //   final attendanceViewModel = Get.put(AttendanceViewModel());
// // // // //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // // //   final loc.Location location = loc.Location();
// // // // //
// // // // //   // Rive animation state
// // // // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // // // //
// // // // //   // Location monitoring for auto clock-out
// // // // //   Timer? _locationMonitorTimer;
// // // // //   bool _wasLocationAvailable = true;
// // // // //   bool _autoClockOutInProgress = false;
// // // // //
// // // // //   TimerCard({super.key});
// // // // //
// // // // //   // ------------------------------
// // // // //   // Rive Animation Helper
// // // // //   // ------------------------------
// // // // //   void onThemeRiveIconInit(Artboard artboard) {
// // // // //     final controller =
// // // // //     StateMachineController.fromArtboard(artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // // // //     if (controller != null) {
// // // // //       artboard.addController(controller);
// // // // //       _themeMenuIcon[0].riveIcon.status =
// // // // //       controller.findInput<bool>("active") as SMIBool?;
// // // // //     } else {
// // // // //       debugPrint("StateMachineController not found!");
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Timer formatting
// // // // //   // ------------------------------
// // // // //   String _formatDuration(String secondsString) {
// // // // //     int seconds = int.tryParse(secondsString) ?? 0;
// // // // //     Duration duration = Duration(seconds: seconds);
// // // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // //     String hours = twoDigits(duration.inHours);
// // // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // //     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// // // // //     return '$hours:$minutes:$secondsFormatted';
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Build Widget
// // // // //   // ------------------------------
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// // // // //       child: Row(
// // // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //         children: [
// // // // //           Obx(() => Text(
// // // // //             _formatDuration(locationViewModel.secondsPassed.value.toString()),
// // // // //             style: const TextStyle(
// // // // //               fontSize: 20,
// // // // //               fontWeight: FontWeight.bold,
// // // // //               color: Colors.black87,
// // // // //             ),
// // // // //           )),
// // // // //           Obx(() {
// // // // //             return ElevatedButton(
// // // // //               onPressed: () async {
// // // // //                 if (locationViewModel.isClockedIn.value) {
// // // // //                   await _handleClockOut(context);
// // // // //                 } else {
// // // // //                   await _handleClockIn(context);
// // // // //                 }
// // // // //               },
// // // // //               style: ElevatedButton.styleFrom(
// // // // //                 backgroundColor: locationViewModel.isClockedIn.value
// // // // //                     ? Colors.redAccent
// // // // //                     : Colors.green,
// // // // //                 minimumSize: const Size(30, 30),
// // // // //                 shape: RoundedRectangleBorder(
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                 ),
// // // // //                 padding: EdgeInsets.zero,
// // // // //               ),
// // // // //               child: SizedBox(
// // // // //                 width: 35,
// // // // //                 height: 35,
// // // // //                 child: RiveAnimation.asset(
// // // // //                   iconsRiv,
// // // // //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// // // // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // // // //                   onInit: onThemeRiveIconInit,
// // // // //                   fit: BoxFit.cover,
// // // // //                 ),
// // // // //               ),
// // // // //             );
// // // // //           }),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Clock-In
// // // // //   // ------------------------------
// // // // //   Future<void> _handleClockIn(BuildContext context) async {
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       barrierDismissible: false,
// // // // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // // // //     );
// // // // //
// // // // //     try {
// // // // //       bool locationAvailable = await attendanceViewModel.isLocationAvailable();
// // // // //       if (!locationAvailable) {
// // // // //         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // // //         Get.snackbar(
// // // // //           'Location Required',
// // // // //           'Please enable location services to clock in.',
// // // // //           snackPosition: SnackPosition.TOP,
// // // // //           backgroundColor: Colors.red,
// // // // //           colorText: Colors.white,
// // // // //         );
// // // // //         return;
// // // // //       }
// // // // //
// // // // //       // Save location & start services
// // // // //       await locationViewModel.saveCurrentLocation();
// // // // //       final service = FlutterBackgroundService();
// // // // //       await location.enableBackgroundMode(enable: true);
// // // // //       await initializeServiceLocation(); // from main.dart
// // // // //       await location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
// // // // //       service.startService();
// // // // //       await locationViewModel.saveCurrentTime();
// // // // //       await locationViewModel.saveClockStatus(true);
// // // // //       locationViewModel.startTimer();
// // // // //       locationViewModel.isClockedIn.value = true;
// // // // //
// // // // //       await attendanceViewModel.saveFormAttendanceIn();
// // // // //
// // // // //       _themeMenuIcon[0].riveIcon.status!.value = true;
// // // // //
// // // // //       _startLocationMonitoring();
// // // // //     } catch (e) {
// // // // //       debugPrint("Clock-in error: $e");
// // // // //       Get.snackbar('Error', 'Failed to clock in: $e',
// // // // //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// // // // //     } finally {
// // // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Clock-Out
// // // // //   // ------------------------------
// // // // //   Future<void> _handleClockOut(BuildContext context) async {
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       barrierDismissible: false,
// // // // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // // // //     );
// // // // //
// // // // //     try {
// // // // //       _stopLocationMonitoring();
// // // // //       await locationViewModel.saveCurrentLocation();
// // // // //       final service = FlutterBackgroundService();
// // // // //
// // // // //       locationViewModel.isClockedIn.value = false;
// // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // //       await prefs.setBool('isClockedIn', false);
// // // // //
// // // // //       service.invoke("stopService");
// // // // //       var totalTime = await locationViewModel.stopTimer();
// // // // //       debugPrint("Total time: $totalTime");
// // // // //
// // // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // // //       await locationViewModel.saveLocation();
// // // // //       await locationViewModel.saveClockStatus(false);
// // // // //
// // // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // // //       await location.enableBackgroundMode(enable: false);
// // // // //     } catch (e) {
// // // // //       debugPrint("Clock-out error: $e");
// // // // //       Get.snackbar('Error', 'Failed to clock out: $e',
// // // // //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// // // // //     } finally {
// // // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Auto Clock-Out
// // // // //   // ------------------------------
// // // // //   Future<void> _handleAutoClockOut() async {
// // // // //     if (_autoClockOutInProgress) return;
// // // // //     _autoClockOutInProgress = true;
// // // // //     debugPrint("Auto Clock-Out triggered due to location OFF");
// // // // //
// // // // //     try {
// // // // //       _stopLocationMonitoring();
// // // // //
// // // // //       await locationViewModel.saveCurrentLocation();
// // // // //       final service = FlutterBackgroundService();
// // // // //
// // // // //       locationViewModel.isClockedIn.value = false;
// // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // //       await prefs.setBool('isClockedIn', false);
// // // // //
// // // // //       service.invoke("stopService");
// // // // //       await locationViewModel.stopTimer();
// // // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // // //       await locationViewModel.saveLocation();
// // // // //       await locationViewModel.saveClockStatus(false);
// // // // //
// // // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // // //       await location.enableBackgroundMode(enable: false);
// // // // //       debugPrint("Auto Clock-Out completed");
// // // // //     } catch (e) {
// // // // //       debugPrint("Auto clock-out error: $e");
// // // // //     } finally {
// // // // //       _autoClockOutInProgress = false;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ------------------------------
// // // // //   // Location Monitoring
// // // // //   // ------------------------------
// // // // //   void _startLocationMonitoring() {
// // // // //     _wasLocationAvailable = true;
// // // // //     _autoClockOutInProgress = false;
// // // // //
// // // // //     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
// // // // //       if (!locationViewModel.isClockedIn.value) {
// // // // //         _stopLocationMonitoring();
// // // // //         return;
// // // // //       }
// // // // //
// // // // //       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
// // // // //
// // // // //       if (_wasLocationAvailable && !currentLocationAvailable) {
// // // // //         debugPrint("Location OFF - triggering auto clock-out");
// // // // //         await _handleAutoClockOut();
// // // // //       }
// // // // //
// // // // //       _wasLocationAvailable = currentLocationAvailable;
// // // // //     });
// // // // //   }
// // // // //
// // // // //   void _stopLocationMonitoring() {
// // // // //     _locationMonitorTimer?.cancel();
// // // // //     _locationMonitorTimer = null;
// // // // //     _autoClockOutInProgress = false;
// // // // //   }
// // // // // }
// // // // //
// // // // //
// // // // //
// // // // // // // actuall code====== 18-10-2025========
// // // // // // import 'dart:async';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // // // // import 'package:get/get.dart';
// // // // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // // // import 'package:rive/rive.dart';
// // // // // // import 'package:location/location.dart' as loc;
// // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // import '../../Databases/util.dart';
// // // // // // import '../../ViewModels/attendance_out_view_model.dart';
// // // // // // import '../../ViewModels/location_services_view_model.dart';
// // // // // // import '../../main.dart';
// // // // // // import 'assets.dart';
// // // // // // import 'menu_item.dart';
// // // // // //
// // // // // // class TimerCard extends StatelessWidget {
// // // // // //   // ViewModels initialization (Using Get.put to make them available)
// // // // // //   final locationViewModel = Get.put(LocationViewModel());
// // // // // //   final attendanceViewModel = Get.put(AttendanceViewModel());
// // // // // //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // // // //   final loc.Location location = loc.Location();
// // // // // //
// // // // // //   // Rive animation state
// // // // // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // // // // //
// // // // // //   // Location monitoring variables for auto clock-out
// // // // // //   // These should ideally be managed outside a StatelessWidget (e.g., in a ViewModel or Stateful Widget),
// // // // // //   // but for merging the provided code, they are added here.
// // // // // //   Timer? _locationMonitorTimer;
// // // // // //   bool _wasLocationAvailable = true;
// // // // // //   bool _autoClockOutInProgress = false;
// // // // // //
// // // // // //   TimerCard({super.key});
// // // // // //
// // // // // //   // Helper method for Rive animation initialization
// // // // // //   void onThemeRiveIconInit(Artboard artboard) {
// // // // // //     final controller = StateMachineController.fromArtboard(
// // // // // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // // // // //     if (controller != null) {
// // // // // //       artboard.addController(controller);
// // // // // //       _themeMenuIcon[0].riveIcon.status =
// // // // // //       controller.findInput<bool>("active") as SMIBool?;
// // // // // //     } else {
// // // // // //       debugPrint("StateMachineController not found!");
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // Helper method to format time from seconds to HH:MM:SS
// // // // // //   String _formatDuration(String secondsString) {
// // // // // //     int seconds = int.parse(secondsString);
// // // // // //     Duration duration = Duration(seconds: seconds);
// // // // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // // //     String hours = twoDigits(duration.inHours);
// // // // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // // //     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// // // // // //     return '$hours:$minutes:$secondsFormatted';
// // // // // //   }
// // // // // //
// // // // // //   // ------------------------------------------------------------------------
// // // // // //   // Widget Build Method
// // // // // //   // ------------------------------------------------------------------------
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Padding(
// // // // // //       padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
// // // // // //       child: Row(
// // // // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // //         crossAxisAlignment: CrossAxisAlignment.center,
// // // // // //         children: [
// // // // // //           // Display Timer (Observable)
// // // // // //           Obx(() =>
// // // // // //               Text(
// // // // // //                 _formatDuration(
// // // // // //                     locationViewModel.newsecondpassed.value.toString()),
// // // // // //                 style: const TextStyle(
// // // // // //                   fontSize: 20,
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                   color: Colors.black87,
// // // // // //                 ),
// // // // // //               )),
// // // // // //           // Clock-In/Clock-Out Button (Observable)
// // // // // //           Obx(() {
// // // // // //             return ElevatedButton(
// // // // // //               onPressed: () async {
// // // // // //                 if (locationViewModel.isClockedIn.value) {
// // // // // //                   // Clock Out Logic
// // // // // //                   _handleClockOut(context);
// // // // // //                 } else {
// // // // // //                   // Clock In Logic
// // // // // //                   await _handleClockIn(context);
// // // // // //                 }
// // // // // //               },
// // // // // //               style: ElevatedButton.styleFrom(
// // // // // //                 backgroundColor: locationViewModel.isClockedIn.value
// // // // // //                     ? Colors.redAccent // Red when clocked in (Clock Out)
// // // // // //                     : Colors.green, // Green when clocked out (Clock In)
// // // // // //                 minimumSize: const Size(30, 30),
// // // // // //                 shape: RoundedRectangleBorder(
// // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // //                 ),
// // // // // //                 padding: EdgeInsets.zero,
// // // // // //               ),
// // // // // //               child: SizedBox(
// // // // // //                 width: 35,
// // // // // //                 height: 35,
// // // // // //                 child: RiveAnimation.asset(
// // // // // //                   iconsRiv, // Asset name from 'assets.dart'
// // // // // //                   stateMachines: [
// // // // // //                     _themeMenuIcon[0].riveIcon.stateMachine
// // // // // //                   ],
// // // // // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // // // // //                   onInit: onThemeRiveIconInit,
// // // // // //                   fit: BoxFit.cover,
// // // // // //                 ),
// // // // // //               ),
// // // // // //             );
// // // // // //           }),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   // ------------------------------------------------------------------------
// // // // // //   // Clock-In Logic (Modularized with Location Check)
// // // // // //   // ------------------------------------------------------------------------
// // // // // //
// // // // // //   Future<void> _handleClockIn(BuildContext context) async {
// // // // // //     // Show loading indicator immediately
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       barrierDismissible: false,
// // // // // //       builder: (BuildContext context) {
// // // // // //         return const PopScope(
// // // // // //           canPop: false,
// // // // // //           child: Center(
// // // // // //             child: CircularProgressIndicator(),
// // // // // //           ),
// // // // // //         );
// // // // // //       },
// // // // // //     );
// // // // // //
// // // // // //     try {
// // // // // //       // 1. **Location Pre-Check** (Crucial addition from Code 2)
// // // // // //       bool locationAvailable = await attendanceViewModel.isLocationAvailable();
// // // // // //
// // // // // //       if (!locationAvailable) {
// // // // // //         // Location is not available, stop and inform user
// // // // // //         if (Navigator.of(context).canPop()) {
// // // // // //           Navigator.of(context).pop();
// // // // // //         }
// // // // // //
// // // // // //         Get.snackbar(
// // // // // //           'Location Required',
// // // // // //           'Please enable location services to clock in.',
// // // // // //           snackPosition: SnackPosition.TOP,
// // // // // //           backgroundColor: Colors.red,
// // // // // //           colorText: Colors.white,
// // // // // //           duration: const Duration(seconds: 3),
// // // // // //           icon: const Icon(Icons.location_off, color: Colors.white),
// // // // // //           shouldIconPulse: true,
// // // // // //           margin: const EdgeInsets.all(10),
// // // // // //         );
// // // // // //         return;
// // // // // //       }
// // // // // //
// // // // // //       // 2. Core Clock-In Logic
// // // // // //       await locationViewModel.saveCurrentLocation();
// // // // // //       final service = FlutterBackgroundService();
// // // // // //
// // // // // //       await location.enableBackgroundMode(enable: true);
// // // // // //       await initializeServiceLocation(); // Assumes this function is available in main.dart
// // // // // //       await location.changeSettings(
// // // // // //           interval: 300, accuracy: loc.LocationAccuracy.high);
// // // // // //       service.startService();
// // // // // //       await locationViewModel.saveCurrentTime();
// // // // // //       await locationViewModel.saveClockStatus(true);
// // // // // //       await locationViewModel.clockRefresh();
// // // // // //
// // // // // //       // Update state and SharedPreferences
// // // // // //       locationViewModel.isClockedIn.value = true;
// // // // // //       newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //       // Removed: await prefs.reload();
// // // // // //       await prefs.setBool('isClockedIn', newIsClockedIn);
// // // // // //
// // // // // //       // Save attendance
// // // // // //       await attendanceViewModel.saveFormAttendanceIn();
// // // // // //
// // // // // //       // Update Rive animation
// // // // // //       _themeMenuIcon[0].riveIcon.status!.value = true;
// // // // // //       debugPrint("Timer started and animation set to active.");
// // // // // //
// // // // // //       // 3. Start **Location Monitoring** (From Code 2)
// // // // // //       _startLocationMonitoring();
// // // // // //     } catch (e) {
// // // // // //       debugPrint("Error during clock-in: $e");
// // // // // //       Get.snackbar(
// // // // // //         'Error',
// // // // // //         'Failed to clock in: $e',
// // // // // //         snackPosition: SnackPosition.TOP,
// // // // // //         backgroundColor: Colors.red,
// // // // // //         colorText: Colors.white,
// // // // // //       );
// // // // // //     } finally {
// // // // // //       // Hide loading indicator
// // // // // //       await Future.delayed(const Duration(seconds: 2));
// // // // // //       if (Navigator.of(context).canPop()) {
// // // // // //         Navigator.of(context).pop();
// // // // // //       }
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ------------------------------------------------------------------------
// // // // // //   // Clock-Out Logic (Modularized)
// // // // // //   // ------------------------------------------------------------------------
// // // // // //
// // // // // //   Future<void> _handleClockOut(BuildContext context) async {
// // // // // //     // Show loading indicator immediately
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       barrierDismissible: false,
// // // // // //       builder: (BuildContext context) {
// // // // // //         return const PopScope(
// // // // // //           canPop: false,
// // // // // //           child: Center(
// // // // // //             child: CircularProgressIndicator(),
// // // // // //           ),
// // // // // //         );
// // // // // //       },
// // // // // //     );
// // // // // //
// // // // // //     try {
// // // // // //       // 1. Stop **Location Monitoring** (From Code 2)
// // // // // //       _stopLocationMonitoring();
// // // // // //
// // // // // //       // 2. Core Clock-Out Logic
// // // // // //       await locationViewModel.saveCurrentLocation();
// // // // // //       final service = FlutterBackgroundService();
// // // // // //
// // // // // //       // Update state and SharedPreferences
// // // // // //       locationViewModel.isClockedIn.value = false;
// // // // // //       newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //       // Removed: await prefs.reload();
// // // // // //       await prefs.setBool('isClockedIn', newIsClockedIn);
// // // // // //
// // // // // //       service.invoke("stopService");
// // // // // //
// // // // // //       // Stop timer and save attendance
// // // // // //       var totalTime = await locationViewModel.stopTimer();
// // // // // //       debugPrint("⏰ Total time recorded: $totalTime");
// // // // // //
// // // // // //       // 🚀 The critical part that saves the data instantly and attempts sync
// // // // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // // // //
// // // // // //       await locationViewModel.clockRefresh();
// // // // // //       await locationViewModel.saveLocation();
// // // // // //       await locationViewModel.saveClockStatus(false);
// // // // // //
// // // // // //       // Update Rive animation and background location
// // // // // //       debugPrint("Timer stopped and animation set to inactive.");
// // // // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // // // //       await location.enableBackgroundMode(enable: false);
// // // // // //     } catch (e) {
// // // // // //       debugPrint("Error during clock-out: $e");
// // // // // //       Get.snackbar(
// // // // // //         'Error',
// // // // // //         'Failed to clock out: $e',
// // // // // //         snackPosition: SnackPosition.TOP,
// // // // // //         backgroundColor: Colors.red,
// // // // // //         colorText: Colors.white,
// // // // // //       );
// // // // // //     } finally {
// // // // // //       // Hide loading indicator
// // // // // //       await Future.delayed(const Duration(seconds: 2));
// // // // // //       if (Navigator.of(context).canPop()) {
// // // // // //         Navigator.of(context).pop();
// // // // // //       }
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ------------------------------------------------------------------------
// // // // // //   // Auto Clock-Out Logic (From Code 2)
// // // // // //   // ------------------------------------------------------------------------
// // // // // //
// // // // // //   Future<void> _handleAutoClockOut() async {
// // // // // //     if (_autoClockOutInProgress) {
// // // // // //       return; // Prevent multiple auto clock-outs
// // // // // //     }
// // // // // //
// // // // // //     _autoClockOutInProgress = true;
// // // // // //     debugPrint(
// // // // // //         "🔄 AUTO CLOCK-OUT: Location turned off, automatically clocking out...");
// // // // // //
// // // // // //     try {
// // // // // //       _stopLocationMonitoring(); // Stop the monitor timer
// // // // // //
// // // // // //       await locationViewModel.saveCurrentLocation();
// // // // // //       final service = FlutterBackgroundService();
// // // // // //
// // // // // //       // Core Clock-Out Logic (identical to manual clock-out, but without dialogs)
// // // // // //       locationViewModel.isClockedIn.value = false;
// // // // // //       newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // //
// // // // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //       // Removed: await prefs.reload();
// // // // // //       await prefs.setBool('isClockedIn', newIsClockedIn);
// // // // // //
// // // // // //       service.invoke("stopService");
// // // // // //       var totalTime = await locationViewModel.stopTimer();
// // // // // //       debugPrint("⏰ Auto Clock-Out - Total time recorded: $totalTime");
// // // // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // // // //       await locationViewModel.clockRefresh();
// // // // // //       await locationViewModel.saveLocation();
// // // // // //       await locationViewModel.saveClockStatus(false);
// // // // // //
// // // // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // // // //       await location.enableBackgroundMode(enable: false);
// // // // // //
// // // // // //       debugPrint("✅ AUTO CLOCK-OUT: Completed successfully");
// // // // // //     } catch (e) {
// // // // // //       debugPrint("❌ Error during auto clock-out: $e");
// // // // // //     } finally {
// // // // // //       _autoClockOutInProgress = false;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ------------------------------------------------------------------------
// // // // // //   // Location Monitoring Methods (From Code 2)
// // // // // //   // ------------------------------------------------------------------------
// // // // // //
// // // // // //   void _startLocationMonitoring() {
// // // // // //     _wasLocationAvailable = true;
// // // // // //     _autoClockOutInProgress = false;
// // // // // //
// // // // // //     // Check location status every 3 seconds
// // // // // //     _locationMonitorTimer =
// // // // // //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// // // // // //           if (!locationViewModel.isClockedIn.value) {
// // // // // //             _stopLocationMonitoring();
// // // // // //             return;
// // // // // //           }
// // // // // //
// // // // // //           bool currentLocationAvailable =
// // // // // //           await attendanceViewModel.isLocationAvailable();
// // // // // //
// // // // // //           // Logic: If location was ON and is now OFF, trigger auto clock-out
// // // // // //           if (_wasLocationAvailable && !currentLocationAvailable) {
// // // // // //             debugPrint("📍 Location turned off - Auto clocking out immediately");
// // // // // //             await _handleAutoClockOut();
// // // // // //           }
// // // // // //
// // // // // //           _wasLocationAvailable = currentLocationAvailable;
// // // // // //         });
// // // // // //   }
// // // // // //
// // // // // //   void _stopLocationMonitoring() {
// // // // // //     _locationMonitorTimer?.cancel();
// // // // // //     _locationMonitorTimer = null;
// // // // // //     _autoClockOutInProgress = false;
// // // // // //   }
// // // // // // }
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // //
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:get/get.dart';
// // // // // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // // // // import 'package:rive/rive.dart';
// // // // // // // import 'package:location/location.dart' as loc;
// // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // import '../../Databases/util.dart';
// // // // // // // import '../../ViewModels/attendance_out_view_model.dart';
// // // // // // // import '../../ViewModels/location_services_view_model.dart';
// // // // // // // import '../../main.dart';
// // // // // // // import 'assets.dart';
// // // // // // // import 'menu_item.dart';
// // // // // // //
// // // // // // // class TimerCard extends StatelessWidget {
// // // // // // //   final locationViewModel = Get.put(LocationViewModel());
// // // // // // //   final attendanceViewModel = Get.put(AttendanceViewModel());
// // // // // // //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // // // // //   final loc.Location location = loc.Location();
// // // // // // //
// // // // // // //   void onThemeToggle(bool value) {
// // // // // // //     _themeMenuIcon[0].riveIcon.status!.change(value);
// // // // // // //   }
// // // // // // //
// // // // // // //   void onThemeRiveIconInit(Artboard artboard) {
// // // // // // //     final controller = StateMachineController.fromArtboard(
// // // // // // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // // // // // //     if (controller != null) {
// // // // // // //       artboard.addController(controller);
// // // // // // //       _themeMenuIcon[0].riveIcon.status =
// // // // // // //       controller.findInput<bool>("active") as SMIBool?;
// // // // // // //     } else {
// // // // // // //       debugPrint("StateMachineController not found!");
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     String _formatDuration(String secondsString) {
// // // // // // //       int seconds = int.parse(secondsString);
// // // // // // //       Duration duration = Duration(seconds: seconds);
// // // // // // //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // // // //       String hours = twoDigits(duration.inHours);
// // // // // // //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // // // //       String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// // // // // // //       return '$hours:$minutes:$secondsFormatted';
// // // // // // //     }
// // // // // // //
// // // // // // //     return Padding(
// // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
// // // // // // //       child: Row(
// // // // // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // //         crossAxisAlignment: CrossAxisAlignment.center,
// // // // // // //         children: [
// // // // // // //           Obx(() =>
// // // // // // //               Text(
// // // // // // //                 _formatDuration(
// // // // // // //                     locationViewModel.newsecondpassed.value.toString()),
// // // // // // //                 style: TextStyle(
// // // // // // //                   fontSize: 20,
// // // // // // //                   fontWeight: FontWeight.bold,
// // // // // // //                   color: Colors.black87,
// // // // // // //                 ),
// // // // // // //               )),
// // // // // // //           Obx(() {
// // // // // // //             return ElevatedButton(
// // // // // // //               onPressed: () async {
// // // // // // //                 // Show loading indicator
// // // // // // //                 showDialog(
// // // // // // //                   context: context,
// // // // // // //                   barrierDismissible: false, // Prevents closing by tapping outside
// // // // // // //                   builder: (BuildContext context) {
// // // // // // //                     return PopScope(
// // // // // // //                       canPop: false, // Prevents closing by back button
// // // // // // //                       child: Center(
// // // // // // //                         child: CircularProgressIndicator(),
// // // // // // //                       ),
// // // // // // //                     );
// // // // // // //                   },
// // // // // // //                 );
// // // // // // //
// // // // // // //                 try {
// // // // // // //                   await locationViewModel.saveCurrentLocation();
// // // // // // //                   final service = FlutterBackgroundService();
// // // // // // //                   newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // // //
// // // // // // //                   if (newIsClockedIn) {
// // // // // // //                     // Clock Out Logic
// // // // // // //                     locationViewModel.isClockedIn.value = false;
// // // // // // //                     newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // // //                     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //                     await prefs.reload();
// // // // // // //                     await prefs.setBool('isClockedIn', newIsClockedIn);
// // // // // // //
// // // // // // //                     service.invoke("stopService");
// // // // // // //                     await attendanceOutViewModel.saveFormAttendanceOut();
// // // // // // //                     var totalTime = await locationViewModel.stopTimer();
// // // // // // //
// // // // // // //                     await locationViewModel.stopTimer();
// // // // // // //                     await locationViewModel.clockRefresh();
// // // // // // //
// // // // // // //                     await locationViewModel.saveLocation();
// // // // // // //                     await locationViewModel.saveClockStatus(false);
// // // // // // //                     debugPrint("Timer stopped and animation set to inactive.");
// // // // // // //                     _themeMenuIcon[0].riveIcon.status!.value = false;
// // // // // // //                     await location.enableBackgroundMode(enable: false);
// // // // // // //                   } else {
// // // // // // //                     // Clock In Logic
// // // // // // //                     await location.enableBackgroundMode(enable: true);
// // // // // // //                     await initializeServiceLocation();
// // // // // // //                     await location.changeSettings(
// // // // // // //                         interval: 300, accuracy: loc.LocationAccuracy.high);
// // // // // // //                     service.startService();
// // // // // // //                     await locationViewModel.saveCurrentTime();
// // // // // // //                     await locationViewModel.saveClockStatus(true);
// // // // // // //                     await locationViewModel.clockRefresh();
// // // // // // //                     locationViewModel.isClockedIn.value = true;
// // // // // // //                     newIsClockedIn = locationViewModel.isClockedIn.value;
// // // // // // //                     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //                     await prefs.reload();
// // // // // // //                     await  prefs.setBool('isClockedIn', newIsClockedIn);
// // // // // // //                     await attendanceViewModel.saveFormAttendanceIn();
// // // // // // //
// // // // // // //                     _themeMenuIcon[0].riveIcon.status!.value = true;
// // // // // // //                     debugPrint("Timer started and animation set to active.");
// // // // // // //                   }
// // // // // // //                 } catch (e) {
// // // // // // //                   debugPrint("Error: $e");
// // // // // // //                 } finally {
// // // // // // //                   // Wait for 5 seconds
// // // // // // //                   await Future.delayed(Duration(seconds: 10));
// // // // // // //                   // Hide loading indicator after all tasks are completed
// // // // // // //                   Navigator.of(context).pop();
// // // // // // //                 }
// // // // // // //               },
// // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // //                 backgroundColor: locationViewModel.isClockedIn.value ? Colors
// // // // // // //                     .redAccent : Colors.green,
// // // // // // //                 minimumSize: Size(30, 30),
// // // // // // //                 shape: RoundedRectangleBorder(
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                 ),
// // // // // // //                 padding: EdgeInsets.zero,
// // // // // // //               ),
// // // // // // //               child: SizedBox(
// // // // // // //                 width: 35,
// // // // // // //                 height: 35,
// // // // // // //                 child: RiveAnimation.asset(
// // // // // // //                   iconsRiv,
// // // // // // //                   stateMachines: [
// // // // // // //                     _themeMenuIcon[0].riveIcon.stateMachine
// // // // // // //                   ],
// // // // // // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // // // // // //                   onInit: onThemeRiveIconInit,
// // // // // // //                   fit: BoxFit.cover,
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             );
// // // // // // //           }),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // //
// // // //
// // // //
// // // // import 'dart:async';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // // import 'package:rive/rive.dart';
// // // // import 'package:location/location.dart' as loc;
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import '../../Tracker/trac.dart';
// // // // import '../../main.dart';
// // // // import 'assets.dart';
// // // // import 'menu_item.dart';
// // // //
// // // // class TimerCard extends StatelessWidget {
// // // //   final locationViewModel = Get.put(LocationViewModel());
// // // //   final attendanceViewModel = Get.put(AttendanceViewModel());
// // // //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // //   final loc.Location location = loc.Location();
// // // //
// // // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // // //   Timer? _locationMonitorTimer;
// // // //   bool _wasLocationAvailable = true;
// // // //   bool _autoClockOutInProgress = false;
// // // //
// // // //   TimerCard({super.key});
// // // //
// // // //   void onThemeRiveIconInit(Artboard artboard) {
// // // //     final controller =
// // // //     StateMachineController.fromArtboard(artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // // //     if (controller != null) {
// // // //       artboard.addController(controller);
// // // //       _themeMenuIcon[0].riveIcon.status =
// // // //       controller.findInput<bool>("active") as SMIBool?;
// // // //     } else {
// // // //       debugPrint("StateMachineController not found!");
// // // //     }
// // // //   }
// // // //
// // // //   String _formatDuration(String secondsString) {
// // // //     int seconds = int.tryParse(secondsString) ?? 0;
// // // //     Duration duration = Duration(seconds: seconds);
// // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // //     String hours = twoDigits(duration.inHours);
// // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // //     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// // // //     return '$hours:$minutes:$secondsFormatted';
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// // // //       child: Row(
// // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //         children: [
// // // //           Obx(() => Text(
// // // //             _formatDuration(locationViewModel.secondsPassed.value.toString()),
// // // //             style: const TextStyle(
// // // //               fontSize: 20,
// // // //               fontWeight: FontWeight.bold,
// // // //               color: Colors.black87,
// // // //             ),
// // // //           )),
// // // //           Obx(() {
// // // //             return ElevatedButton(
// // // //               onPressed: () async {
// // // //                 if (locationViewModel.isClockedIn.value) {
// // // //                   await _handleClockOut(context);
// // // //                 } else {
// // // //                   await _handleClockIn(context);
// // // //                 }
// // // //               },
// // // //               style: ElevatedButton.styleFrom(
// // // //                 backgroundColor: locationViewModel.isClockedIn.value
// // // //                     ? Colors.redAccent
// // // //                     : Colors.green,
// // // //                 minimumSize: const Size(30, 30),
// // // //                 shape: RoundedRectangleBorder(
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                 ),
// // // //                 padding: EdgeInsets.zero,
// // // //               ),
// // // //               child: SizedBox(
// // // //                 width: 35,
// // // //                 height: 35,
// // // //                 child: RiveAnimation.asset(
// // // //                   iconsRiv,
// // // //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// // // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // // //                   onInit: onThemeRiveIconInit,
// // // //                   fit: BoxFit.cover,
// // // //                 ),
// // // //               ),
// // // //             );
// // // //           }),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // 🎯 FIXED CLOCK-IN - NO BLOCKING CALLS
// // // //   Future<void> _handleClockIn(BuildContext context) async {
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // // //     );
// // // //
// // // //     try {
// // // //       // 🚀 INSTANT CLOCK-IN - Use the clean method from AttendanceViewModel
// // // //       await attendanceViewModel.saveFormAttendanceIn();
// // // //
// // // //       // 🚀 NON-BLOCKING background tasks
// // // //       _startBackgroundServices();
// // // //
// // // //       // 🎯 UPDATE UI STATE
// // // //       locationViewModel.isClockedIn.value = true;
// // // //       _themeMenuIcon[0].riveIcon.status!.value = true;
// // // //       _startLocationMonitoring();
// // // //
// // // //     } catch (e) {
// // // //       debugPrint("Clock-in error: $e");
// // // //       Get.snackbar('Error', 'Failed to clock in: $e',
// // // //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// // // //     } finally {
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //     }
// // // //   }
// // // //
// // // //   // 🛰 START BACKGROUND SERVICES - NON-BLOCKING
// // // //   void _startBackgroundServices() async {
// // // //     try {
// // // //       // Start background location service without waiting
// // // //       final service = FlutterBackgroundService();
// // // //       await location.enableBackgroundMode(enable: true);
// // // //
// // // //       // Fire and forget - don't wait for these
// // // //       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
// // // //       service.startService().catchError((e) => debugPrint("Service start error: $e"));
// // // //       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
// // // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // // //
// // // //       debugPrint("✅ Background services started");
// // // //     } catch (e) {
// // // //       debugPrint("⚠ Background services error: $e");
// // // //       // Don't block clock-in for background service errors
// // // //     }
// // // //   }
// // // //
// // // //   // 🎯 CLOCK-OUT (Minimal changes needed)
// // // //   Future<void> _handleClockOut(BuildContext context) async {
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // // //     );
// // // //
// // // //     try {
// // // //       _stopLocationMonitoring();
// // // //
// // // //       // 🚀 Save location without blocking
// // // //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       locationViewModel.isClockedIn.value = false;
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('isClockedIn', false);
// // // //
// // // //       service.invoke("stopService");
// // // //       var totalTime = await locationViewModel.stopTimer();
// // // //       debugPrint("Total time: $totalTime");
// // // //
// // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // //
// // // //       // 🚀 Non-blocking location save
// // // //       locationViewModel.saveLocation().catchError((e) => debugPrint("Final location save error: $e"));
// // // //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
// // // //
// // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // //       await location.enableBackgroundMode(enable: false);
// // // //     } catch (e) {
// // // //       debugPrint("Clock-out error: $e");
// // // //       Get.snackbar('Error', 'Failed to clock out: $e',
// // // //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// // // //     } finally {
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //     }
// // // //   }
// // // //
// // // //   // 🎯 AUTO CLOCK-OUT
// // // //   Future<void> _handleAutoClockOut() async {
// // // //     if (_autoClockOutInProgress) return;
// // // //     _autoClockOutInProgress = true;
// // // //     debugPrint("Auto Clock-Out triggered due to location OFF");
// // // //
// // // //     try {
// // // //       _stopLocationMonitoring();
// // // //
// // // //       // 🚀 Non-blocking location save
// // // //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       locationViewModel.isClockedIn.value = false;
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('isClockedIn', false);
// // // //
// // // //       service.invoke("stopService");
// // // //       await locationViewModel.stopTimer();
// // // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // // //
// // // //       // 🚀 Non-blocking saves
// // // //       locationViewModel.saveLocation().catchError((e) => debugPrint("Auto save location error: $e"));
// // // //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));
// // // //
// // // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // // //       await location.enableBackgroundMode(enable: false);
// // // //       debugPrint("Auto Clock-Out completed");
// // // //     } catch (e) {
// // // //       debugPrint("Auto clock-out error: $e");
// // // //     } finally {
// // // //       _autoClockOutInProgress = false;
// // // //     }
// // // //   }
// // // //
// // // //   // 🎯 LOCATION MONITORING (Same as before)
// // // //   void _startLocationMonitoring() {
// // // //     _wasLocationAvailable = true;
// // // //     _autoClockOutInProgress = false;
// // // //
// // // //     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
// // // //       if (!locationViewModel.isClockedIn.value) {
// // // //         _stopLocationMonitoring();
// // // //         return;
// // // //       }
// // // //
// // // //       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
// // // //
// // // //       if (_wasLocationAvailable && !currentLocationAvailable) {
// // // //         debugPrint("Location OFF - triggering auto clock-out");
// // // //         await _handleAutoClockOut();
// // // //       }
// // // //
// // // //       _wasLocationAvailable = currentLocationAvailable;
// // // //     });
// // // //   }
// // // //
// // // //   void _stopLocationMonitoring() {
// // // //     _locationMonitorTimer?.cancel();
// // // //     _locationMonitorTimer = null;
// // // //     _autoClockOutInProgress = false;
// // // //   }
// // // // }
// // //
// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // import 'package:rive/rive.dart';
// // // import 'package:location/location.dart' as loc;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import '../../Tracker/trac.dart';
// // // import '../../main.dart';
// // // import 'assets.dart';
// // // import 'menu_item.dart';
// // //
// // // class TimerCard extends StatelessWidget {
// // //   final locationViewModel = Get.put(LocationViewModel());
// // //   final attendanceViewModel = Get.put(AttendanceViewModel());
// // //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // //   final loc.Location location = loc.Location();
// // //
// // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // //   Timer? _locationMonitorTimer;
// // //   bool _wasLocationAvailable = true;
// // //   bool _autoClockOutInProgress = false;
// // //
// // //   TimerCard({super.key});
// // //
// // //   void onThemeRiveIconInit(Artboard artboard) {
// // //     final controller =
// // //     StateMachineController.fromArtboard(
// // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // //     if (controller != null) {
// // //       artboard.addController(controller);
// // //       _themeMenuIcon[0].riveIcon.status =
// // //       controller.findInput<bool>("active") as SMIBool?;
// // //     } else {
// // //       debugPrint("StateMachineController not found!");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           Obx(() =>
// // //               Text(
// // //                 attendanceViewModel.elapsedTime.value,
// // //                 // ✅ FIXED: Use attendance timer
// // //                 style: const TextStyle(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Colors.black87,
// // //                 ),
// // //               )),
// // //           Obx(() {
// // //             return ElevatedButton(
// // //               onPressed: () async {
// // //                 if (attendanceViewModel.isClockedIn
// // //                     .value) { // ✅ FIXED: Use attendance state
// // //                   await _handleClockOut(context);
// // //                 } else {
// // //                   await _handleClockIn(context);
// // //                 }
// // //               },
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: attendanceViewModel.isClockedIn
// // //                     .value // ✅ FIXED: Use attendance state
// // //                     ? Colors.redAccent
// // //                     : Colors.green,
// // //                 minimumSize: const Size(30, 30),
// // //                 shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(12),
// // //                 ),
// // //                 padding: EdgeInsets.zero,
// // //               ),
// // //               child: SizedBox(
// // //                 width: 35,
// // //                 height: 35,
// // //                 child: RiveAnimation.asset(
// // //                   iconsRiv,
// // //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // //                   onInit: onThemeRiveIconInit,
// // //                   fit: BoxFit.cover,
// // //                 ),
// // //               ),
// // //             );
// // //           }),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // 🎯 FIXED CLOCK-IN - NO BLOCKING CALLS
// // //   Future<void> _handleClockIn(BuildContext context) async {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     try {
// // //       // 🚀 INSTANT CLOCK-IN - Use the clean method from AttendanceViewModel
// // //       await attendanceViewModel.saveFormAttendanceIn();
// // //
// // //       // 🚀 NON-BLOCKING background tasks
// // //       _startBackgroundServices();
// // //
// // //       // 🎯 UPDATE UI STATE
// // //       _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       _startLocationMonitoring();
// // //     } catch (e) {
// // //       debugPrint("Clock-in error: $e");
// // //       Get.snackbar('Error', 'Failed to clock in: $e',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.red,
// // //           colorText: Colors.white);
// // //     } finally {
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //     }
// // //   }
// // //
// // //   // 🛰 START BACKGROUND SERVICES - NON-BLOCKING
// // //   void _startBackgroundServices() async {
// // //     try {
// // //       // Start background location service without waiting
// // //       final service = FlutterBackgroundService();
// // //       await location.enableBackgroundMode(enable: true);
// // //
// // //       // Fire and forget - don't wait for these
// // //       initializeServiceLocation().catchError((e) =>
// // //           debugPrint("Service init error: $e"));
// // //       service.startService().catchError((e) =>
// // //           debugPrint("Service start error: $e"));
// // //       location.changeSettings(
// // //           interval: 300, accuracy: loc.LocationAccuracy.high)
// // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // //
// // //       debugPrint("✅ Background services started");
// // //     } catch (e) {
// // //       debugPrint("⚠ Background services error: $e");
// // //       // Don't block clock-in for background service errors
// // //     }
// // //   }
// // //
// // //   // 🎯 CLOCK-OUT
// // //   Future<void> _handleClockOut(BuildContext context) async {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //
// // //       // 🚀 Save location without blocking
// // //       locationViewModel.saveCurrentLocation().catchError((e) =>
// // //           debugPrint("Location save error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       // ✅ Let AttendanceViewModel handle the clock-out state
// // //       await attendanceViewModel.clearClockInState();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       service.invoke("stopService");
// // //
// // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // //
// // //       // 🚀 Non-blocking location save
// // //       locationViewModel.saveLocation().catchError((e) =>
// // //           debugPrint("Final location save error: $e"));
// // //       locationViewModel.saveClockStatus(false).catchError((e) =>
// // //           debugPrint("Clock status error: $e"));
// // //
// // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       await location.enableBackgroundMode(enable: false);
// // //
// // //       debugPrint("✅ Clock-out completed successfully");
// // //     } catch (e) {
// // //       debugPrint("Clock-out error: $e");
// // //       Get.snackbar('Error', 'Failed to clock out: $e',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.red,
// // //           colorText: Colors.white);
// // //     } finally {
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //     }
// // //   }
// // //
// // //   // 🎯 AUTO CLOCK-OUT
// // //   Future<void> _handleAutoClockOut() async {
// // //     if (_autoClockOutInProgress) return;
// // //     _autoClockOutInProgress = true;
// // //     debugPrint("Auto Clock-Out triggered due to location OFF");
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //
// // //       // 🚀 Non-blocking location save
// // //       locationViewModel.saveCurrentLocation().catchError((e) =>
// // //           debugPrint("Auto clock-out location error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       // ✅ Let AttendanceViewModel handle the clock-out state
// // //       await attendanceViewModel.clearClockInState();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       service.invoke("stopService");
// // //       await attendanceOutViewModel.saveFormAttendanceOut();
// // //
// // //       // 🚀 Non-blocking saves
// // //       locationViewModel.saveLocation().catchError((e) =>
// // //           debugPrint("Auto save location error: $e"));
// // //       locationViewModel.saveClockStatus(false).catchError((e) =>
// // //           debugPrint("Auto clock status error: $e"));
// // //
// // //       _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       await location.enableBackgroundMode(enable: false);
// // //       debugPrint("Auto Clock-Out completed");
// // //     } catch (e) {
// // //       debugPrint("Auto clock-out error: $e");
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   // 🎯 LOCATION MONITORING
// // //   void _startLocationMonitoring() {
// // //     _wasLocationAvailable = true;
// // //     _autoClockOutInProgress = false;
// // //
// // //     _locationMonitorTimer =
// // //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// // //           if (!attendanceViewModel.isClockedIn
// // //               .value) { // ✅ FIXED: Use attendance state
// // //             _stopLocationMonitoring();
// // //             return;
// // //           }
// // //
// // //           bool currentLocationAvailable = await attendanceViewModel
// // //               .isLocationAvailable();
// // //
// // //           if (_wasLocationAvailable && !currentLocationAvailable) {
// // //             debugPrint("Location OFF - triggering auto clock-out");
// // //             await _handleAutoClockOut();
// // //           }
// // //           Future<void> _handleClockOut(BuildContext context) async {
// // //             debugPrint("🎯 [TIMERCARD] Clock-out button pressed"); // ADD THIS LINE
// // //
// // //             showDialog(
// // //               context: context,
// // //               barrierDismissible: false,
// // //               builder: (_) => const Center(child: CircularProgressIndicator()),
// // //             );
// // //             // ... rest of your code
// // //
// // //           _wasLocationAvailable = currentLocationAvailable;
// // //         }});
// // //   }
// // //
// // //   void _stopLocationMonitoring() {
// // //     _locationMonitorTimer?.cancel();
// // //     _locationMonitorTimer = null;
// // //     _autoClockOutInProgress = false;
// // //   }
// // //
// // // }
// //
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_background_service/flutter_background_service.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // import 'package:rive/rive.dart';
// // import 'package:location/location.dart' as loc;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../Tracker/trac.dart';
// // import '../../main.dart';
// // import 'assets.dart';
// // import 'menu_item.dart';
// //
// // class TimerCard extends StatelessWidget {
// //   final locationViewModel = Get.put(LocationViewModel());
// //   final attendanceViewModel = Get.put(AttendanceViewModel());
// //   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// //   final loc.Location location = loc.Location();
// //
// //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// //   Timer? _locationMonitorTimer;
// //   bool _wasLocationAvailable = true;
// //   bool _autoClockOutInProgress = false;
// //
// //   TimerCard({super.key});
// //
// //   void onThemeRiveIconInit(Artboard artboard) {
// //     final controller =
// //     StateMachineController.fromArtboard(artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// //     if (controller != null) {
// //       artboard.addController(controller);
// //       _themeMenuIcon[0].riveIcon.status =
// //       controller.findInput<bool>("active") as SMIBool?;
// //     } else {
// //       debugPrint("StateMachineController not found!");
// //     }
// //   }
// //
// //   String _formatDuration(String secondsString) {
// //     int seconds = int.tryParse(secondsString) ?? 0;
// //     Duration duration = Duration(seconds: seconds);
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     String hours = twoDigits(duration.inHours);
// //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// //     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// //     return '$hours:$minutes:$secondsFormatted';
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Obx(() => Text(
// //             _formatDuration(locationViewModel.secondsPassed.value.toString()),
// //             style: const TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //           )),
// //           Obx(() {
// //             return ElevatedButton(
// //               onPressed: () async {
// //                 if (locationViewModel.isClockedIn.value) {
// //                   await _handleClockOut(context);
// //                 } else {
// //                   await _handleClockIn(context);
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: locationViewModel.isClockedIn.value
// //                     ? Colors.redAccent
// //                     : Colors.green,
// //                 minimumSize: const Size(30, 30),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 padding: EdgeInsets.zero,
// //               ),
// //               child: SizedBox(
// //                 width: 35,
// //                 height: 35,
// //                 child: RiveAnimation.asset(
// //                   iconsRiv,
// //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// //                   onInit: onThemeRiveIconInit,
// //                   fit: BoxFit.cover,
// //                 ),
// //               ),
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // 🎯 FIXED CLOCK-IN - NO BLOCKING CALLS
// //   Future<void> _handleClockIn(BuildContext context) async {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     try {
// //       // 🚀 INSTANT CLOCK-IN - Use the clean method from AttendanceViewModel
// //       await attendanceViewModel.saveFormAttendanceIn();
// //
// //       // 🚀 NON-BLOCKING background tasks
// //       _startBackgroundServices();
// //
// //       // 🎯 UPDATE UI STATE
// //       locationViewModel.isClockedIn.value = true;
// //       _themeMenuIcon[0].riveIcon.status!.value = true;
// //       _startLocationMonitoring();
// //
// //     } catch (e) {
// //       debugPrint("Clock-in error: $e");
// //       Get.snackbar('Error', 'Failed to clock in: $e',
// //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// //     } finally {
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //     }
// //   }
// //
// //   // 🛰 START BACKGROUND SERVICES - NON-BLOCKING
// //   void _startBackgroundServices() async {
// //     try {
// //       // Start background location service without waiting
// //       final service = FlutterBackgroundService();
// //       await location.enableBackgroundMode(enable: true);
// //
// //       // Fire and forget - don't wait for these
// //       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
// //       service.startService().catchError((e) => debugPrint("Service start error: $e"));
// //       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
// //           .catchError((e) => debugPrint("Location settings error: $e"));
// //
// //       debugPrint("✅ Background services started");
// //     } catch (e) {
// //       debugPrint("⚠ Background services error: $e");
// //       // Don't block clock-in for background service errors
// //     }
// //   }
// //
// //   // 🎯 CLOCK-OUT (Minimal changes needed)
// //   Future<void> _handleClockOut(BuildContext context) async {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     try {
// //       _stopLocationMonitoring();
// //
// //       // 🚀 Save location without blocking
// //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //       locationViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //
// //       service.invoke("stopService");
// //       var totalTime = await locationViewModel.stopTimer();
// //       debugPrint("Total time: $totalTime");
// //
// //       await attendanceOutViewModel.saveFormAttendanceOut();
// //
// //       // 🚀 Non-blocking location save
// //       locationViewModel.saveLocation().catchError((e) => debugPrint("Final location save error: $e"));
// //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
// //
// //       _themeMenuIcon[0].riveIcon.status!.value = false;
// //       await location.enableBackgroundMode(enable: false);
// //     } catch (e) {
// //       debugPrint("Clock-out error: $e");
// //       Get.snackbar('Error', 'Failed to clock out: $e',
// //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
// //     } finally {
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //     }
// //   }
// //
// //   // 🎯 AUTO CLOCK-OUT
// //   Future<void> _handleAutoClockOut() async {
// //     if (_autoClockOutInProgress) return;
// //     _autoClockOutInProgress = true;
// //     debugPrint("Auto Clock-Out triggered due to location OFF");
// //
// //     try {
// //       _stopLocationMonitoring();
// //
// //       // 🚀 Non-blocking location save
// //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //       locationViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //
// //       service.invoke("stopService");
// //       await locationViewModel.stopTimer();
// //       await attendanceOutViewModel.saveFormAttendanceOut();
// //
// //       // 🚀 Non-blocking saves
// //       locationViewModel.saveLocation().catchError((e) => debugPrint("Auto save location error: $e"));
// //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));
// //
// //       _themeMenuIcon[0].riveIcon.status!.value = false;
// //       await location.enableBackgroundMode(enable: false);
// //       debugPrint("Auto Clock-Out completed");
// //     } catch (e) {
// //       debugPrint("Auto clock-out error: $e");
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
// //   // 🎯 LOCATION MONITORING (Same as before)
// //   void _startLocationMonitoring() {
// //     _wasLocationAvailable = true;
// //     _autoClockOutInProgress = false;
// //
// //     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
// //       if (!locationViewModel.isClockedIn.value) {
// //         _stopLocationMonitoring();
// //         return;
// //       }
// //
// //       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
// //
// //       if (_wasLocationAvailable && !currentLocationAvailable) {
// //         debugPrint("Location OFF - triggering auto clock-out");
// //         await _handleAutoClockOut();
// //       }
// //
// //       _wasLocationAvailable = currentLocationAvailable;
// //     });
// //   }
// //
// //   void _stopLocationMonitoring() {
// //     _locationMonitorTimer?.cancel();
// //     _locationMonitorTimer = null;
// //     _autoClockOutInProgress = false;
// //   }
// // }
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:rive/rive.dart';
// import 'package:location/location.dart' as loc;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Tracker/trac.dart';
// import '../../main.dart';
// import 'assets.dart';
// import 'menu_item.dart';
//
// class TimerCard extends StatelessWidget {
//   final locationViewModel = Get.put(LocationViewModel());
//   final attendanceViewModel = Get.put(AttendanceViewModel());
//   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//   final loc.Location location = loc.Location();
//
//   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
//   Timer? _locationMonitorTimer;
//   bool _wasLocationAvailable = true;
//   bool _autoClockOutInProgress = false;
//
//   TimerCard({super.key});
//
//   void onThemeRiveIconInit(Artboard artboard) {
//     final controller =
//     StateMachineController.fromArtboard(artboard, _themeMenuIcon[0].riveIcon.stateMachine);
//     if (controller != null) {
//       artboard.addController(controller);
//       _themeMenuIcon[0].riveIcon.status =
//       controller.findInput<bool>("active") as SMIBool?;
//     } else {
//       debugPrint("StateMachineController not found!");
//     }
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.tryParse(secondsString) ?? 0;
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 100.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Obx(() => Text(
//             _formatDuration(locationViewModel.secondsPassed.value.toString()),
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           )),
//           Obx(() {
//             return ElevatedButton(
//               onPressed: () async {
//                 if (locationViewModel.isClockedIn.value) { // ✅ KEEP locationViewModel
//                   await _handleClockOut(context);
//                 } else {
//                   await _handleClockIn(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: locationViewModel.isClockedIn.value // ✅ KEEP locationViewModel
//                     ? Colors.redAccent
//                     : Colors.green,
//                 minimumSize: const Size(30, 30),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: SizedBox(
//                 width: 35,
//                 height: 35,
//                 child: RiveAnimation.asset(
//                   iconsRiv,
//                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
//                   artboard: _themeMenuIcon[0].riveIcon.artboard,
//                   onInit: onThemeRiveIconInit,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // 🎯 CLOCK-IN - ONLY ADD TIMER START
//   Future<void> _handleClockIn(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       // 🚀 INSTANT CLOCK-IN
//       await attendanceViewModel.saveFormAttendanceIn();
//
//       // ✅ START THE TIMER (ONLY CHANGE NEEDED)
//       locationViewModel.startTimer();
//
//       // 🚀 NON-BLOCKING background tasks
//       _startBackgroundServices();
//
//       // 🎯 UPDATE UI STATE
//       _themeMenuIcon[0].riveIcon.status!.value = true;
//       _startLocationMonitoring();
//
//       debugPrint("✅ Clock-in completed with timer started");
//
//     } catch (e) {
//       debugPrint("Clock-in error: $e");
//       Get.snackbar('Error', 'Failed to clock in: $e',
//           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//     }
//   }
//
//   // 🛰 START BACKGROUND SERVICES - NON-BLOCKING (SAME AS YOURS)
//   void _startBackgroundServices() async {
//     try {
//       final service = FlutterBackgroundService();
//       await location.enableBackgroundMode(enable: true);
//
//       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
//       service.startService().catchError((e) => debugPrint("Service start error: $e"));
//       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
//           .catchError((e) => debugPrint("Location settings error: $e"));
//
//       debugPrint("✅ Background services started");
//     } catch (e) {
//       debugPrint("⚠ Background services error: $e");
//     }
//   }
//
//
//
//   // 🎯 CLOCK-OUT - EXACTLY SAME AS YOUR WORKING VERSION
//   Future<void> _handleClockOut(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
//
//
//     try {
//       _stopLocationMonitoring();
//
//       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
//
//       final service = FlutterBackgroundService();
//       locationViewModel.isClockedIn.value = false;
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//
//       service.invoke("stopService");
//       var totalTime = await locationViewModel.stopTimer();
//       debugPrint("Total time: $totalTime");
//
//       await attendanceOutViewModel.saveFormAttendanceOut();
//
//       locationViewModel.saveLocation().catchError((e) => debugPrint("Final location save error: $e"));
//       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
//
//       _themeMenuIcon[0].riveIcon.status!.value = false;
//       await location.enableBackgroundMode(enable: false);
//     } catch (e) {
//       debugPrint("Clock-out error: $e");
//       Get.snackbar('Error', 'Failed to clock out: $e',
//           snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//     }
//     // 🎯 CLOCK-IN - ONLY ADD TIMER START
//     Future<void> _handleClockIn(BuildContext context) async {
//       debugPrint("🔄 [TIMERCARD] Clock-in started");
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );
//
//       try {
//         // 🚀 INSTANT CLOCK-IN
//         debugPrint("1️⃣ Calling attendanceViewModel.saveFormAttendanceIn()");
//         await attendanceViewModel.saveFormAttendanceIn();
//
//         // ✅ START THE TIMER (ONLY CHANGE NEEDED)
//         debugPrint("2️⃣ Starting timer");
//         locationViewModel.startTimer();
//
//         // 🚀 NON-BLOCKING background tasks
//         debugPrint("3️⃣ Starting background services");
//         _startBackgroundServices();
//
//         // 🎯 UPDATE UI STATE
//         debugPrint("4️⃣ Updating UI state");
//         _themeMenuIcon[0].riveIcon.status!.value = true;
//         _startLocationMonitoring();
//
//         debugPrint("✅ Clock-in completed with timer started");
//
//       } catch (e) {
//         debugPrint("Clock-in error: $e");
//         Get.snackbar('Error', 'Failed to clock in: $e',
//             snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
//       } finally {
//         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//       }
//     }
//   }
//
//   // 🎯 AUTO CLOCK-OUT - SAME AS YOURS
//   Future<void> _handleAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//     debugPrint("Auto Clock-Out triggered due to location OFF");
//
//     try {
//       _stopLocationMonitoring();
//
//       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));
//
//       final service = FlutterBackgroundService();
//       locationViewModel.isClockedIn.value = false;
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//
//       service.invoke("stopService");
//       await locationViewModel.stopTimer();
//       await attendanceOutViewModel.saveFormAttendanceOut();
//
//       locationViewModel.saveLocation().catchError((e) => debugPrint("Auto save location error: $e"));
//       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));
//
//       _themeMenuIcon[0].riveIcon.status!.value = false;
//       await location.enableBackgroundMode(enable: false);
//       debugPrint("Auto Clock-Out completed");
//     } catch (e) {
//       debugPrint("Auto clock-out error: $e");
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//     // 🎯 CLOCK-OUT - EXACTLY SAME AS YOUR WORKING VERSION
//     Future<void> _handleClockOut(BuildContext context) async {
//       debugPrint("🔄 [TIMERCARD] Clock-out started");
//
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );
//
//       try {
//         debugPrint("1️⃣ Stopping location monitoring");
//         _stopLocationMonitoring();
//
//         debugPrint("2️⃣ Saving current location");
//         locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
//
//         final service = FlutterBackgroundService();
//
//         debugPrint("3️⃣ Setting isClockedIn to false");
//         locationViewModel.isClockedIn.value = false;
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isClockedIn', false);
//
//         debugPrint("4️⃣ Stopping background service");
//         service.invoke("stopService");
//
//         debugPrint("5️⃣ Stopping timer");
//         var totalTime = await locationViewModel.stopTimer();
//         debugPrint("Total time: $totalTime");
//
//         debugPrint("6️⃣ Calling saveFormAttendanceOut");
//         await attendanceOutViewModel.saveFormAttendanceOut();
//
//         debugPrint("7️⃣ Saving final location");
//         locationViewModel.saveLocation().catchError((e) => debugPrint("Final location save error: $e"));
//         locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
//
//         debugPrint("8️⃣ Updating UI");
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//         await location.enableBackgroundMode(enable: false);
//
//         debugPrint("✅ Clock-out completed successfully");
//
//       } catch (e) {
//         debugPrint("❌ Clock-out error: $e");
//         Get.snackbar('Error', 'Failed to clock out: $e',
//             snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
//       } finally {
//         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//       }
//     }
//   }
//
//   // 🎯 LOCATION MONITORING - SAME AS YOURS
//   void _startLocationMonitoring() {
//     _wasLocationAvailable = true;
//     _autoClockOutInProgress = false;
//
//     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       if (!locationViewModel.isClockedIn.value) {
//         _stopLocationMonitoring();
//         return;
//       }
//
//       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
//
//       if (_wasLocationAvailable && !currentLocationAvailable) {
//         debugPrint("Location OFF - triggering auto clock-out");
//         await _handleAutoClockOut();
//       }
//
//       _wasLocationAvailable = currentLocationAvailable;
//     });
//   }
//
//   void _stopLocationMonitoring() {
//     _locationMonitorTimer?.cancel();
//     _locationMonitorTimer = null;
//     _autoClockOutInProgress = false;
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:rive/rive.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Tracker/trac.dart';
import '../../main.dart';
import 'assets.dart';
import 'menu_item.dart';

class TimerCard extends StatelessWidget {
  final locationViewModel = Get.put(LocationViewModel());
  final attendanceViewModel = Get.put(AttendanceViewModel());
  final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  final loc.Location location = loc.Location();

  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  Timer? _locationMonitorTimer;
  bool _wasLocationAvailable = true;
  bool _autoClockOutInProgress = false;

  TimerCard({super.key});

  void onThemeRiveIconInit(Artboard artboard) {
    final controller =
    StateMachineController.fromArtboard(artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    if (controller != null) {
      artboard.addController(controller);
      _themeMenuIcon[0].riveIcon.status =
      controller.findInput<bool>("active") as SMIBool?;
    } else {
      debugPrint("StateMachineController not found!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            attendanceViewModel.elapsedTime.value, // ✅ USE ATTENDANCE TIMER
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
          Obx(() {
            return ElevatedButton(
              onPressed: () async {
                debugPrint("🎯 [BUTTON] Button pressed");
                debugPrint("   - locationViewModel.isClockedIn: ${locationViewModel.isClockedIn.value}");
                debugPrint("   - attendanceViewModel.isClockedIn: ${attendanceViewModel.isClockedIn.value}");

                if (attendanceViewModel.isClockedIn.value) {
                  debugPrint("🔄 [BUTTON] Calling clock-out");
                  await _handleClockOut(context);
                } else {
                  debugPrint("🔄 [BUTTON] Calling clock-in");
                  await _handleClockIn(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: attendanceViewModel.isClockedIn.value
                    ? Colors.redAccent
                    : Colors.green,
                minimumSize: const Size(30, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: SizedBox(
                width: 35,
                height: 35,
                child: RiveAnimation.asset(
                  iconsRiv,
                  stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
                  artboard: _themeMenuIcon[0].riveIcon.artboard,
                  onInit: onThemeRiveIconInit,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🎯 CLOCK-IN
  Future<void> _handleClockIn(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint("1️⃣ [CLOCK-IN] Calling attendanceViewModel.saveFormAttendanceIn()");
      await attendanceViewModel.saveFormAttendanceIn();

      debugPrint("2️⃣ [CLOCK-IN] Starting background services...");
      _startBackgroundServices();

      debugPrint("3️⃣ [CLOCK-IN] Updating UI state...");
      locationViewModel.isClockedIn.value = true;
      attendanceViewModel.isClockedIn.value = true;
      _themeMenuIcon[0].riveIcon.status!.value = true;
      _startLocationMonitoring();

      debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");

    } catch (e) {
      debugPrint("❌ [CLOCK-IN] Error: $e");
      Get.snackbar('Error', 'Failed to clock in: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      debugPrint("🏁 [CLOCK-IN] Finally block reached");
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  // 🛰 START BACKGROUND SERVICES - NON-BLOCKING
  void _startBackgroundServices() async {
    try {
      debugPrint("🛰 [BACKGROUND] Starting services...");

      final service = FlutterBackgroundService();
      await location.enableBackgroundMode(enable: true);

      initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
      service.startService().catchError((e) => debugPrint("Service start error: $e"));
      location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
          .catchError((e) => debugPrint("Location settings error: $e"));

      debugPrint("✅ [BACKGROUND] Services started");
    } catch (e) {
      debugPrint("⚠ [BACKGROUND] Services error: $e");
    }
  }

  // 🎯 CLOCK-OUT
  Future<void> _handleClockOut(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== CLOCK-OUT STARTED =====");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint("1️⃣ [CLOCK-OUT] Stopping location monitoring...");
      _stopLocationMonitoring();

      debugPrint("2️⃣ [CLOCK-OUT] Saving current location...");
      locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));

      final service = FlutterBackgroundService();

      debugPrint("3️⃣ [CLOCK-OUT] Setting clock-in state to false...");
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);

      debugPrint("4️⃣ [CLOCK-OUT] Stopping background service...");
      service.invoke("stopService");

      debugPrint("5️⃣ [CLOCK-OUT] Getting total time from attendance timer...");
      var totalTime = attendanceViewModel.elapsedTime.value; // ✅ USE ATTENDANCE TIMER
      debugPrint("   - Total time: $totalTime");

      debugPrint("6️⃣ [CLOCK-OUT] Calling saveFormAttendanceOut...");
      await attendanceOutViewModel.saveFormAttendanceOut();

      debugPrint("7️⃣ [CLOCK-OUT] Saving final location...");
      locationViewModel.saveLocation().catchError((e) => debugPrint("Final location save error: $e"));
      locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));

      debugPrint("8️⃣ [CLOCK-OUT] Updating UI...");
      _themeMenuIcon[0].riveIcon.status!.value = false;
      await location.enableBackgroundMode(enable: false);

      debugPrint("✅ [CLOCK-OUT] ===== COMPLETED SUCCESSFULLY =====");

    } catch (e) {
      debugPrint("❌ [CLOCK-OUT] Error: $e");
      Get.snackbar('Error', 'Failed to clock out: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      debugPrint("🏁 [CLOCK-OUT] Finally block reached");
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  // 🎯 AUTO CLOCK-OUT
  Future<void> _handleAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;
    debugPrint("🔄 [AUTO] Auto Clock-Out triggered due to location OFF");

    try {
      _stopLocationMonitoring();

      locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));

      final service = FlutterBackgroundService();
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);

      service.invoke("stopService");
      await attendanceOutViewModel.saveFormAttendanceOut();

      locationViewModel.saveLocation().catchError((e) => debugPrint("Auto save location error: $e"));
      locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));

      _themeMenuIcon[0].riveIcon.status!.value = false;
      await location.enableBackgroundMode(enable: false);
      debugPrint("✅ [AUTO] Auto Clock-Out completed");
    } catch (e) {
      debugPrint("❌ [AUTO] Auto clock-out error: $e");
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  // 🎯 LOCATION MONITORING
  void _startLocationMonitoring() {
    _wasLocationAvailable = true;
    _autoClockOutInProgress = false;

    _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!attendanceViewModel.isClockedIn.value) { // ✅ USE ATTENDANCE VIEW MODEL
        _stopLocationMonitoring();
        return;
      }

      bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();

      if (_wasLocationAvailable && !currentLocationAvailable) {
        debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
        await _handleAutoClockOut();
      }

      _wasLocationAvailable = currentLocationAvailable;
    });
  }

  void _stopLocationMonitoring() {
    _locationMonitorTimer?.cancel();
    _locationMonitorTimer = null;
    _autoClockOutInProgress = false;
  }
}