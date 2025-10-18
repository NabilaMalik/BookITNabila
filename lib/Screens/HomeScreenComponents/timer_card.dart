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
  // ViewModels
  final locationViewModel = Get.put(LocationViewModel());
  final attendanceViewModel = Get.put(AttendanceViewModel());
  final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  final loc.Location location = loc.Location();

  // Rive animation state
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;

  // Location monitoring for auto clock-out
  Timer? _locationMonitorTimer;
  bool _wasLocationAvailable = true;
  bool _autoClockOutInProgress = false;

  TimerCard({super.key});

  // ------------------------------
  // Rive Animation Helper
  // ------------------------------
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

  // ------------------------------
  // Timer formatting
  // ------------------------------
  String _formatDuration(String secondsString) {
    int seconds = int.tryParse(secondsString) ?? 0;
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secondsFormatted';
  }

  // ------------------------------
  // Build Widget
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            _formatDuration(locationViewModel.secondsPassed.value.toString()),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
          Obx(() {
            return ElevatedButton(
              onPressed: () async {
                if (locationViewModel.isClockedIn.value) {
                  await _handleClockOut(context);
                } else {
                  await _handleClockIn(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: locationViewModel.isClockedIn.value
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

  // ------------------------------
  // Clock-In
  // ------------------------------
  Future<void> _handleClockIn(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool locationAvailable = await attendanceViewModel.isLocationAvailable();
      if (!locationAvailable) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        Get.snackbar(
          'Location Required',
          'Please enable location services to clock in.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Save location & start services
      await locationViewModel.saveCurrentLocation();
      final service = FlutterBackgroundService();
      await location.enableBackgroundMode(enable: true);
      await initializeServiceLocation(); // from main.dart
      await location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
      service.startService();
      await locationViewModel.saveCurrentTime();
      await locationViewModel.saveClockStatus(true);
      locationViewModel.startTimer();
      locationViewModel.isClockedIn.value = true;

      await attendanceViewModel.saveFormAttendanceIn();

      _themeMenuIcon[0].riveIcon.status!.value = true;

      _startLocationMonitoring();
    } catch (e) {
      debugPrint("Clock-in error: $e");
      Get.snackbar('Error', 'Failed to clock in: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  // ------------------------------
  // Clock-Out
  // ------------------------------
  Future<void> _handleClockOut(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      _stopLocationMonitoring();
      await locationViewModel.saveCurrentLocation();
      final service = FlutterBackgroundService();

      locationViewModel.isClockedIn.value = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);

      service.invoke("stopService");
      var totalTime = await locationViewModel.stopTimer();
      debugPrint("Total time: $totalTime");

      await attendanceOutViewModel.saveFormAttendanceOut();
      await locationViewModel.saveLocation();
      await locationViewModel.saveClockStatus(false);

      _themeMenuIcon[0].riveIcon.status!.value = false;
      await location.enableBackgroundMode(enable: false);
    } catch (e) {
      debugPrint("Clock-out error: $e");
      Get.snackbar('Error', 'Failed to clock out: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  // ------------------------------
  // Auto Clock-Out
  // ------------------------------
  Future<void> _handleAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;
    debugPrint("Auto Clock-Out triggered due to location OFF");

    try {
      _stopLocationMonitoring();

      await locationViewModel.saveCurrentLocation();
      final service = FlutterBackgroundService();

      locationViewModel.isClockedIn.value = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);

      service.invoke("stopService");
      await locationViewModel.stopTimer();
      await attendanceOutViewModel.saveFormAttendanceOut();
      await locationViewModel.saveLocation();
      await locationViewModel.saveClockStatus(false);

      _themeMenuIcon[0].riveIcon.status!.value = false;
      await location.enableBackgroundMode(enable: false);
      debugPrint("Auto Clock-Out completed");
    } catch (e) {
      debugPrint("Auto clock-out error: $e");
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  // ------------------------------
  // Location Monitoring
  // ------------------------------
  void _startLocationMonitoring() {
    _wasLocationAvailable = true;
    _autoClockOutInProgress = false;

    _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!locationViewModel.isClockedIn.value) {
        _stopLocationMonitoring();
        return;
      }

      bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();

      if (_wasLocationAvailable && !currentLocationAvailable) {
        debugPrint("Location OFF - triggering auto clock-out");
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



// // actuall code====== 18-10-2025========
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:rive/rive.dart';
// import 'package:location/location.dart' as loc;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Databases/util.dart';
// import '../../ViewModels/attendance_out_view_model.dart';
// import '../../ViewModels/location_services_view_model.dart';
// import '../../main.dart';
// import 'assets.dart';
// import 'menu_item.dart';
//
// class TimerCard extends StatelessWidget {
//   // ViewModels initialization (Using Get.put to make them available)
//   final locationViewModel = Get.put(LocationViewModel());
//   final attendanceViewModel = Get.put(AttendanceViewModel());
//   final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//   final loc.Location location = loc.Location();
//
//   // Rive animation state
//   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
//
//   // Location monitoring variables for auto clock-out
//   // These should ideally be managed outside a StatelessWidget (e.g., in a ViewModel or Stateful Widget),
//   // but for merging the provided code, they are added here.
//   Timer? _locationMonitorTimer;
//   bool _wasLocationAvailable = true;
//   bool _autoClockOutInProgress = false;
//
//   TimerCard({super.key});
//
//   // Helper method for Rive animation initialization
//   void onThemeRiveIconInit(Artboard artboard) {
//     final controller = StateMachineController.fromArtboard(
//         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
//     if (controller != null) {
//       artboard.addController(controller);
//       _themeMenuIcon[0].riveIcon.status =
//       controller.findInput<bool>("active") as SMIBool?;
//     } else {
//       debugPrint("StateMachineController not found!");
//     }
//   }
//
//   // Helper method to format time from seconds to HH:MM:SS
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   // ------------------------------------------------------------------------
//   // Widget Build Method
//   // ------------------------------------------------------------------------
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Display Timer (Observable)
//           Obx(() =>
//               Text(
//                 _formatDuration(
//                     locationViewModel.newsecondpassed.value.toString()),
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               )),
//           // Clock-In/Clock-Out Button (Observable)
//           Obx(() {
//             return ElevatedButton(
//               onPressed: () async {
//                 if (locationViewModel.isClockedIn.value) {
//                   // Clock Out Logic
//                   _handleClockOut(context);
//                 } else {
//                   // Clock In Logic
//                   await _handleClockIn(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: locationViewModel.isClockedIn.value
//                     ? Colors.redAccent // Red when clocked in (Clock Out)
//                     : Colors.green, // Green when clocked out (Clock In)
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
//                   iconsRiv, // Asset name from 'assets.dart'
//                   stateMachines: [
//                     _themeMenuIcon[0].riveIcon.stateMachine
//                   ],
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
//   // ------------------------------------------------------------------------
//   // Clock-In Logic (Modularized with Location Check)
//   // ------------------------------------------------------------------------
//
//   Future<void> _handleClockIn(BuildContext context) async {
//     // Show loading indicator immediately
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const PopScope(
//           canPop: false,
//           child: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//
//     try {
//       // 1. **Location Pre-Check** (Crucial addition from Code 2)
//       bool locationAvailable = await attendanceViewModel.isLocationAvailable();
//
//       if (!locationAvailable) {
//         // Location is not available, stop and inform user
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//
//         Get.snackbar(
//           'Location Required',
//           'Please enable location services to clock in.',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//           icon: const Icon(Icons.location_off, color: Colors.white),
//           shouldIconPulse: true,
//           margin: const EdgeInsets.all(10),
//         );
//         return;
//       }
//
//       // 2. Core Clock-In Logic
//       await locationViewModel.saveCurrentLocation();
//       final service = FlutterBackgroundService();
//
//       await location.enableBackgroundMode(enable: true);
//       await initializeServiceLocation(); // Assumes this function is available in main.dart
//       await location.changeSettings(
//           interval: 300, accuracy: loc.LocationAccuracy.high);
//       service.startService();
//       await locationViewModel.saveCurrentTime();
//       await locationViewModel.saveClockStatus(true);
//       await locationViewModel.clockRefresh();
//
//       // Update state and SharedPreferences
//       locationViewModel.isClockedIn.value = true;
//       newIsClockedIn = locationViewModel.isClockedIn.value;
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // Removed: await prefs.reload();
//       await prefs.setBool('isClockedIn', newIsClockedIn);
//
//       // Save attendance
//       await attendanceViewModel.saveFormAttendanceIn();
//
//       // Update Rive animation
//       _themeMenuIcon[0].riveIcon.status!.value = true;
//       debugPrint("Timer started and animation set to active.");
//
//       // 3. Start **Location Monitoring** (From Code 2)
//       _startLocationMonitoring();
//     } catch (e) {
//       debugPrint("Error during clock-in: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to clock in: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       // Hide loading indicator
//       await Future.delayed(const Duration(seconds: 2));
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//     }
//   }
//
//   // ------------------------------------------------------------------------
//   // Clock-Out Logic (Modularized)
//   // ------------------------------------------------------------------------
//
//   Future<void> _handleClockOut(BuildContext context) async {
//     // Show loading indicator immediately
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const PopScope(
//           canPop: false,
//           child: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//
//     try {
//       // 1. Stop **Location Monitoring** (From Code 2)
//       _stopLocationMonitoring();
//
//       // 2. Core Clock-Out Logic
//       await locationViewModel.saveCurrentLocation();
//       final service = FlutterBackgroundService();
//
//       // Update state and SharedPreferences
//       locationViewModel.isClockedIn.value = false;
//       newIsClockedIn = locationViewModel.isClockedIn.value;
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // Removed: await prefs.reload();
//       await prefs.setBool('isClockedIn', newIsClockedIn);
//
//       service.invoke("stopService");
//
//       // Stop timer and save attendance
//       var totalTime = await locationViewModel.stopTimer();
//       debugPrint("⏰ Total time recorded: $totalTime");
//
//       // 🚀 The critical part that saves the data instantly and attempts sync
//       await attendanceOutViewModel.saveFormAttendanceOut();
//
//       await locationViewModel.clockRefresh();
//       await locationViewModel.saveLocation();
//       await locationViewModel.saveClockStatus(false);
//
//       // Update Rive animation and background location
//       debugPrint("Timer stopped and animation set to inactive.");
//       _themeMenuIcon[0].riveIcon.status!.value = false;
//       await location.enableBackgroundMode(enable: false);
//     } catch (e) {
//       debugPrint("Error during clock-out: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to clock out: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       // Hide loading indicator
//       await Future.delayed(const Duration(seconds: 2));
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//     }
//   }
//
//   // ------------------------------------------------------------------------
//   // Auto Clock-Out Logic (From Code 2)
//   // ------------------------------------------------------------------------
//
//   Future<void> _handleAutoClockOut() async {
//     if (_autoClockOutInProgress) {
//       return; // Prevent multiple auto clock-outs
//     }
//
//     _autoClockOutInProgress = true;
//     debugPrint(
//         "🔄 AUTO CLOCK-OUT: Location turned off, automatically clocking out...");
//
//     try {
//       _stopLocationMonitoring(); // Stop the monitor timer
//
//       await locationViewModel.saveCurrentLocation();
//       final service = FlutterBackgroundService();
//
//       // Core Clock-Out Logic (identical to manual clock-out, but without dialogs)
//       locationViewModel.isClockedIn.value = false;
//       newIsClockedIn = locationViewModel.isClockedIn.value;
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // Removed: await prefs.reload();
//       await prefs.setBool('isClockedIn', newIsClockedIn);
//
//       service.invoke("stopService");
//       var totalTime = await locationViewModel.stopTimer();
//       debugPrint("⏰ Auto Clock-Out - Total time recorded: $totalTime");
//       await attendanceOutViewModel.saveFormAttendanceOut();
//       await locationViewModel.clockRefresh();
//       await locationViewModel.saveLocation();
//       await locationViewModel.saveClockStatus(false);
//
//       _themeMenuIcon[0].riveIcon.status!.value = false;
//       await location.enableBackgroundMode(enable: false);
//
//       debugPrint("✅ AUTO CLOCK-OUT: Completed successfully");
//     } catch (e) {
//       debugPrint("❌ Error during auto clock-out: $e");
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   // ------------------------------------------------------------------------
//   // Location Monitoring Methods (From Code 2)
//   // ------------------------------------------------------------------------
//
//   void _startLocationMonitoring() {
//     _wasLocationAvailable = true;
//     _autoClockOutInProgress = false;
//
//     // Check location status every 3 seconds
//     _locationMonitorTimer =
//         Timer.periodic(const Duration(seconds: 3), (timer) async {
//           if (!locationViewModel.isClockedIn.value) {
//             _stopLocationMonitoring();
//             return;
//           }
//
//           bool currentLocationAvailable =
//           await attendanceViewModel.isLocationAvailable();
//
//           // Logic: If location was ON and is now OFF, trigger auto clock-out
//           if (_wasLocationAvailable && !currentLocationAvailable) {
//             debugPrint("📍 Location turned off - Auto clocking out immediately");
//             await _handleAutoClockOut();
//           }
//
//           _wasLocationAvailable = currentLocationAvailable;
//         });
//   }
//
//   void _stopLocationMonitoring() {
//     _locationMonitorTimer?.cancel();
//     _locationMonitorTimer = null;
//     _autoClockOutInProgress = false;
//   }
// }
//
//
//
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:rive/rive.dart';
// // import 'package:location/location.dart' as loc;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../Databases/util.dart';
// // import '../../ViewModels/attendance_out_view_model.dart';
// // import '../../ViewModels/location_services_view_model.dart';
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
// //   void onThemeToggle(bool value) {
// //     _themeMenuIcon[0].riveIcon.status!.change(value);
// //   }
// //
// //   void onThemeRiveIconInit(Artboard artboard) {
// //     final controller = StateMachineController.fromArtboard(
// //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// //     if (controller != null) {
// //       artboard.addController(controller);
// //       _themeMenuIcon[0].riveIcon.status =
// //       controller.findInput<bool>("active") as SMIBool?;
// //     } else {
// //       debugPrint("StateMachineController not found!");
// //     }
// //   }
// //
// //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     String _formatDuration(String secondsString) {
// //       int seconds = int.parse(secondsString);
// //       Duration duration = Duration(seconds: seconds);
// //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// //       String hours = twoDigits(duration.inHours);
// //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// //       String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
// //       return '$hours:$minutes:$secondsFormatted';
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Obx(() =>
// //               Text(
// //                 _formatDuration(
// //                     locationViewModel.newsecondpassed.value.toString()),
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black87,
// //                 ),
// //               )),
// //           Obx(() {
// //             return ElevatedButton(
// //               onPressed: () async {
// //                 // Show loading indicator
// //                 showDialog(
// //                   context: context,
// //                   barrierDismissible: false, // Prevents closing by tapping outside
// //                   builder: (BuildContext context) {
// //                     return PopScope(
// //                       canPop: false, // Prevents closing by back button
// //                       child: Center(
// //                         child: CircularProgressIndicator(),
// //                       ),
// //                     );
// //                   },
// //                 );
// //
// //                 try {
// //                   await locationViewModel.saveCurrentLocation();
// //                   final service = FlutterBackgroundService();
// //                   newIsClockedIn = locationViewModel.isClockedIn.value;
// //
// //                   if (newIsClockedIn) {
// //                     // Clock Out Logic
// //                     locationViewModel.isClockedIn.value = false;
// //                     newIsClockedIn = locationViewModel.isClockedIn.value;
// //                     SharedPreferences prefs = await SharedPreferences.getInstance();
// //                     await prefs.reload();
// //                     await prefs.setBool('isClockedIn', newIsClockedIn);
// //
// //                     service.invoke("stopService");
// //                     await attendanceOutViewModel.saveFormAttendanceOut();
// //                     var totalTime = await locationViewModel.stopTimer();
// //
// //                     await locationViewModel.stopTimer();
// //                     await locationViewModel.clockRefresh();
// //
// //                     await locationViewModel.saveLocation();
// //                     await locationViewModel.saveClockStatus(false);
// //                     debugPrint("Timer stopped and animation set to inactive.");
// //                     _themeMenuIcon[0].riveIcon.status!.value = false;
// //                     await location.enableBackgroundMode(enable: false);
// //                   } else {
// //                     // Clock In Logic
// //                     await location.enableBackgroundMode(enable: true);
// //                     await initializeServiceLocation();
// //                     await location.changeSettings(
// //                         interval: 300, accuracy: loc.LocationAccuracy.high);
// //                     service.startService();
// //                     await locationViewModel.saveCurrentTime();
// //                     await locationViewModel.saveClockStatus(true);
// //                     await locationViewModel.clockRefresh();
// //                     locationViewModel.isClockedIn.value = true;
// //                     newIsClockedIn = locationViewModel.isClockedIn.value;
// //                     SharedPreferences prefs = await SharedPreferences.getInstance();
// //                     await prefs.reload();
// //                     await  prefs.setBool('isClockedIn', newIsClockedIn);
// //                     await attendanceViewModel.saveFormAttendanceIn();
// //
// //                     _themeMenuIcon[0].riveIcon.status!.value = true;
// //                     debugPrint("Timer started and animation set to active.");
// //                   }
// //                 } catch (e) {
// //                   debugPrint("Error: $e");
// //                 } finally {
// //                   // Wait for 5 seconds
// //                   await Future.delayed(Duration(seconds: 10));
// //                   // Hide loading indicator after all tasks are completed
// //                   Navigator.of(context).pop();
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: locationViewModel.isClockedIn.value ? Colors
// //                     .redAccent : Colors.green,
// //                 minimumSize: Size(30, 30),
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
// //                   stateMachines: [
// //                     _themeMenuIcon[0].riveIcon.stateMachine
// //                   ],
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
// // }
//
