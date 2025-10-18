import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Repositories/attendance_out_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'location_view_model.dart';
// Import the Clock-In ViewModel to access the clear state method
import 'attendance_view_model.dart';

class AttendanceOutViewModel extends GetxController {
  var allAttendanceOut = <AttendanceOutModel>[].obs;
  final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());
  // Get the AttendanceViewModel instance to clear clock-in state
  final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendanceOut();
    // NEW: Attempt to post any unsynced data immediately when the app starts.
    attendanceOutRepository.postDataFromDatabaseToAPI();
  }

  ///old code
  Future<void> saveFormAttendanceOut() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Removed: await prefs.reload(); // THIS WAS CAUSING THE LOADING DELAY

    // Retrieve the calculated shift duration and distance from SharedPreferences
    // ...
    await prefs.reload();

    // Retrieve the calculated shift duration and distance.

    String? clockInTimeString = prefs.getString('clockInTime');
    DateTime shiftStartTime = clockInTimeString != null
        ? DateTime.parse(clockInTimeString)
        : DateTime.now();
    double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
    var totalTime = prefs.getString('totalTime') ?? ""; // This holds the H:mm:ss duration string


    // Reuse same ID from clock-in
    final attendanceId = prefs.getString('attendanceId') ?? ''; //


    if (attendanceId.isEmpty) {
      debugPrint("⚠️ No matching attendanceId found for Clock Out!"); //
      // Optional: Show a snackbar error here
      return;


    }

    // 1. Local Save (Instant Clock-Out)
    addAttendanceOut(
      AttendanceOutModel(
        attendance_out_id: attendanceId,
        user_id: user_id,
        total_distance: totalDistance, // Shift distance
        total_time: totalTime, // Shift duration (H:mm:ss)
        lat_out: locationViewModel.globalLatitude1.value,
        lng_out: locationViewModel.globalLongitude1.value,
        address: locationViewModel.shopAddress.value,
      ),
    );

    // 2. Post the Clock-Out data to the API (Non-blocking, handles offline)
    // The repository handles the network check and local saving/syncing.
    await attendanceOutRepository.postDataFromDatabaseToAPI();

    // 3. Clear the Clock-In state and timer after successful clock-out
    await attendanceViewModel.clearClockInState();
  }

  ///added code 18-10-25

  // Future<void> saveFormAttendanceOut() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   // 🚀 GET BASIC DATA INSTANTLY
  //   final attendanceId = prefs.getString('attendanceId') ?? '';
  //   var totalTime = prefs.getString('totalTime') ?? "00:00:00";
  //
  //   if (attendanceId.isEmpty) {
  //     debugPrint("⚠ No matching attendanceId found for Clock Out!");
  //     return;
  //   }
  //
  //   // 🚀 INSTANT CLOCK-OUT - Save to local database immediately
  //   addAttendanceOut(
  //     AttendanceOutModel(
  //       attendance_out_id: attendanceId,
  //       user_id: user_id,
  //       total_distance: 0.0, // 🚀 Use 0.0 initially to avoid delay
  //       total_time: totalTime,
  //       lat_out: locationViewModel.globalLatitude1.value,
  //       lng_out: locationViewModel.globalLongitude1.value,
  //       address: locationViewModel.shopAddress.value,
  //     ),
  //   );
  //
  //   // 🚀 CLEAR CLOCK-IN STATE IMMEDIATELY
  //   await attendanceViewModel.clearClockInState();
  //
  //   // 🛰 BACKGROUND TASKS - FIRE AND FORGET
  //   _handleBackgroundTasks(attendanceId);
  // }

// 🛰 BACKGROUND TASKS - NON-BLOCKING
  void _handleBackgroundTasks(String attendanceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. Calculate distance in background
      String? clockInTimeString = prefs.getString('clockInTime');
      DateTime shiftStartTime = clockInTimeString != null
          ? DateTime.parse(clockInTimeString)
          : DateTime.now();

      double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
      debugPrint("📍 Background: Calculated distance: $totalDistance");

      // 2. Update local record with actual distance
      await _updateDistanceInDatabase(attendanceId, totalDistance);

      // 3. Sync to server
      await attendanceOutRepository.postDataFromDatabaseToAPI();
      debugPrint("✅ Background: Attendance-out synced to server");

    } catch (e) {
      debugPrint("⚠ Background tasks error: $e");
      // Still try to sync even if distance calculation fails
      attendanceOutRepository.postDataFromDatabaseToAPI()
          .catchError((e) => debugPrint("⚠ Final sync failed: $e"));
    }
  }

// 📊 UPDATE DISTANCE IN DATABASE
  Future<void> _updateDistanceInDatabase(String attendanceId, double distance) async {
    try {
      var dbClient = await attendanceOutRepository.dbHelper.db;
      await dbClient.update(
        'attendance_out_table',
        {'total_distance': distance},
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceId],
      );
      debugPrint("✅ Updated distance in database: $distance");
    } catch (e) {
      debugPrint("⚠ Error updating distance: $e");
    }
  }

  Future<void> fetchAllAttendanceOut() async {
    var attendanceOut = await attendanceOutRepository.getAttendanceOut();
    allAttendanceOut.value = attendanceOut;
  }

  void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
    attendanceOutRepository.add(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
    attendanceOutRepository.update(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  void deleteAttendanceOut(String id) {
    attendanceOutRepository.delete(id);
    fetchAllAttendanceOut();
  }

  Future<void> serialCounterGet() async {
    await attendanceOutRepository.serialNumberGeneratorApi();
  }
}









// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/attendanceOut_model.dart';
// import '../Repositories/attendance_out_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
// import 'location_view_model.dart';
// // Import the Clock-In ViewModel to access the clear state method
// import 'attendance_view_model.dart';
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   // Get the AttendanceViewModel instance to clear clock-in state
//   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//   }
//
//   Future<void> saveFormAttendanceOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     // Retrieve the calculated shift duration and distance from SharedPreferences
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0; //
//     var totalTime = prefs.getString('totalTime') ?? "0"; // This holds the H:mm:ss duration string
//
//     // Reuse same ID from clock-in
//     final attendanceId = prefs.getString('attendanceId') ?? ''; //
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!"); //
//       // Optional: Show a snackbar error here
//       return;
//     }
//
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance, // Shift distance
//         total_time: totalTime, // Shift duration (H:mm:ss)
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     // 1. Post the Clock-Out data to the API
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//
//     // 2. Clear the Clock-In state and timer after successful clock-out
//     await attendanceViewModel.clearClockInState();
//   }
//
//   Future<void> fetchAllAttendanceOut() async {
//     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
//     allAttendanceOut.value = attendanceOut;
//   }
//
//   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
//     attendanceOutRepository.add(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
//     attendanceOutRepository.update(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   void deleteAttendanceOut(String id) {
//     attendanceOutRepository.delete(id);
//     fetchAllAttendanceOut();
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceOutRepository.serialNumberGeneratorApi();
//   }
// }

