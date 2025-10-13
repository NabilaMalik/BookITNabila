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

class AttendanceOutViewModel extends GetxController {
  var allAttendanceOut = <AttendanceOutModel>[].obs;
  final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendanceOut();
  }


  Future<void> saveFormAttendanceOut() async {
    // 1. CRITICAL STEP: STOP TIMER AND CALCULATE/SAVE DISTANCE
    // This is necessary to stop writing to the GPX file and calculate the distance
    // from the now-reset file (which only contains data since the last clock-in).
    await locationViewModel.stopTimer();
    await locationViewModel.saveLocation();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // 2. RETRIEVE THE NEWLY CALCULATED DISTANCE
    var totalDistance = prefs.getDouble('totalDistance') ?? 0.0; // Retrieves the fresh calculated value
    final attendanceId = prefs.getString('attendanceId') ?? '';

    if (attendanceId.isEmpty) {
      debugPrint("⚠️ No matching attendanceId found for Clock Out!");
      return;
    }

    // 🕐 Get clock-in time
    String? clockInTime = prefs.getString('attendanceInTime');
    DateTime clockOut = DateTime.now();
    DateTime? clockIn;

    if (clockInTime != null) {
      try {
        clockIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(clockInTime);
      } catch (e) {
        debugPrint("⚠️ Clock-In time parse error: $e");
      }
    }

    // 🕐 Calculate total time
    String totalTime = "00:00:00";
    if (clockIn != null) {
      Duration diff = clockOut.difference(clockIn);
      totalTime =
      "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }

    // Save clock-out time for reference
    await prefs.setString(
      'attendanceOutTime',
      DateFormat("yyyy-MM-dd HH:mm:ss").format(clockOut),
    );

    // ✅ Save to DB
    addAttendanceOut(
      AttendanceOutModel(
        attendance_out_id: attendanceId,
        user_id: user_id,
        total_distance: totalDistance, // This value is now session-specific
        total_time: totalTime,
        lat_out: locationViewModel.globalLatitude1.value,
        lng_out: locationViewModel.globalLongitude1.value,
        address: locationViewModel.shopAddress.value,
      ),
    );

    await attendanceOutRepository.postDataFromDatabaseToAPI();
    debugPrint("✅ Clock-Out Done. Total time: $totalTime, Distance: $totalDistance km");
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


//final code
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
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   // Ensure LocationViewModel is registered globally or just found if already put elsewhere
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//   }
//
//
//   Future<void> saveFormAttendanceOut() async {
//     // 1. CRITICAL STEP: STOP TIMER AND CALCULATE/SAVE DISTANCE
//     await locationViewModel.stopTimer();
//     await locationViewModel.saveLocation(); // This triggers distance calculation and saves it to SharedPreferences.
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     // 2. RETRIEVE THE NEWLY CALCULATED DISTANCE
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0; // Retrieves the calculated value
//     final attendanceId = prefs.getString('attendanceId') ?? '';
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//       return;
//     }
//
//     // 🕐 Get clock-in time
//     String? clockInTime = prefs.getString('attendanceInTime');
//     DateTime clockOut = DateTime.now();
//     DateTime? clockIn;
//
//     if (clockInTime != null) {
//       try {
//         clockIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(clockInTime);
//       } catch (e) {
//         debugPrint("⚠️ Clock-In time parse error: $e");
//       }
//     }
//
//     // 🕐 Calculate total time
//     String totalTime = "00:00:00";
//     if (clockIn != null) {
//       Duration diff = clockOut.difference(clockIn);
//       totalTime =
//       "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
//     }
//
//     // Save clock-out time for reference
//     await prefs.setString(
//       'attendanceOutTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockOut),
//     );
//
//     // ✅ Save to DB (now with the actual totalDistance)
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance, // This value is now correct
//         total_time: totalTime,
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//     debugPrint("✅ Clock-Out Done. Total time: $totalTime, Distance: $totalDistance km");
//   }
//
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
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//   }
//
//
//   Future<void> saveFormAttendanceOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
//     final attendanceId = prefs.getString('attendanceId') ?? '';
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//       return;
//     }
//
//     // 🕐 Get clock-in time
//     String? clockInTime = prefs.getString('attendanceInTime');
//     DateTime clockOut = DateTime.now();
//     DateTime? clockIn;
//
//     if (clockInTime != null) {
//       try {
//         // This DateFormat is correct for parsing the saved time
//         clockIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(clockInTime);
//       } catch (e) {
//         debugPrint("⚠️ Clock-In time parse error: $e");
//       }
//     }
//
//     // 🕐 Calculate total time
//     String totalTime = "00:00:00";
//     if (clockIn != null) {
//       Duration diff = clockOut.difference(clockIn);
//       // This calculation and formatting (HH:mm:ss) is correct
//       totalTime =
//       "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
//     }
//
//     // Save clock-out time for reference
//     await prefs.setString(
//       'attendanceOutTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockOut),
//     );
//
//     // ✅ Save to DB
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance,
//         total_time: totalTime,
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//     debugPrint("✅ Clock-Out Done. Total time: $totalTime");
//   }
//
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
//     // ❌ Error was here: called fetchAllAttendance()
//     fetchAllAttendanceOut(); // ✅ Correct method
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceOutRepository.serialNumberGeneratorApi();
//   }
// }



//final code
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
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//   }
//
//
//   Future<void> saveFormAttendanceOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
//     final attendanceId = prefs.getString('attendanceId') ?? '';
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//       return;
//     }
//
//     // 🕐 Get clock-in time
//     String? clockInTime = prefs.getString('attendanceInTime');
//     DateTime clockOut = DateTime.now();
//     DateTime? clockIn;
//
//     if (clockInTime != null) {
//       try {
//         // This DateFormat is correct for parsing the saved time
//         clockIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(clockInTime);
//       } catch (e) {
//         debugPrint("⚠️ Clock-In time parse error: $e");
//       }
//     }
//
//     // 🕐 Calculate total time
//     String totalTime = "00:00:00";
//     if (clockIn != null) {
//       Duration diff = clockOut.difference(clockIn);
//       // This calculation and formatting (HH:mm:ss) is correct
//       totalTime =
//       "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
//     }
//
//     // Save clock-out time for reference
//     await prefs.setString(
//       'attendanceOutTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockOut),
//     );
//
//     // ✅ Save to DB
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance,
//         total_time: totalTime,
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//     debugPrint("✅ Clock-Out Done. Total time: $totalTime");
//   }
//
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
//




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
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//   }
//
//
//   Future<void> saveFormAttendanceOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
//     final attendanceId = prefs.getString('attendanceId') ?? '';
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//       return;
//     }
//
//     // 🕐 Get clock-in time
//     String? clockInTime = prefs.getString('attendanceInTime');
//     DateTime clockOut = DateTime.now();
//     DateTime? clockIn;
//
//     if (clockInTime != null) {
//       try {
//         clockIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(clockInTime);
//       } catch (e) {
//         debugPrint("⚠️ Clock-In time parse error: $e");
//       }
//     }
//
//     // 🕐 Calculate total time
//     String totalTime = "00:00:00";
//     if (clockIn != null) {
//       Duration diff = clockOut.difference(clockIn);
//       totalTime =
//       "${diff.inHours.toString().padLeft(2, '0')}:${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
//     }
//
//     // Save clock-out time for reference
//     await prefs.setString(
//       'attendanceOutTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockOut),
//     );
//
//     // ✅ Save to DB
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance,
//         total_time: totalTime,
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//     debugPrint("✅ Clock-Out Done. Total time: $totalTime");
//   }
//
//
//
//
//
//   //
//   // Future<void> saveFormAttendanceOut() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   await prefs.reload();
//   //
//   //   var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
//   //   var totalTime = prefs.getString('totalTime') ?? "0";
//   //
//   //   // Reuse same ID from clock-in
//   //   final attendanceId = prefs.getString('attendanceId') ?? '';
//   //
//   //   if (attendanceId.isEmpty) {
//   //     debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//   //     return;
//   //   }
//   //
//   //   addAttendanceOut(
//   //     AttendanceOutModel(
//   //       attendance_out_id: attendanceId,
//   //       user_id: user_id,
//   //       total_distance: totalDistance,
//   //       total_time: totalTime,
//   //       lat_out: locationViewModel.globalLatitude1.value,
//   //       lng_out: locationViewModel.globalLongitude1.value,
//   //       address: locationViewModel.shopAddress.value,
//   //     ),
//   //   );
//   //
//   //   await attendanceOutRepository.postDataFromDatabaseToAPI();
//   // }
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
//
//
//
//
//
//





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
// class AttendanceOutViewModel extends GetxController{
//
//   // var clockedIn = false.obs;
//   // var clockedOut = false.obs;
//   //
//   // void setClockIn(bool value) {
//   //   clockedIn.value = value;
//   //   clockedOut.value = !value;
//   // }
//   //
//   // void setClockOut(bool value) {
//   //   clockedOut.value = value;
//   //   clockedIn.value = !value;
//   // }
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   int attendanceOutSerialCounter = 1;
//   String attendanceOutCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     super.onInit();
//
//     fetchAllAttendanceOut();
//   }
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     attendanceOutSerialCounter = (prefs.getInt('attendanceOutSerialCounter') ?? attendanceOutHighestSerial?? 1);
//     attendanceOutCurrentMonth =
//         prefs.getString('attendanceOutCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (attendanceOutCurrentMonth != currentMonth) {
//       attendanceOutSerialCounter = 1;
//       attendanceOutCurrentMonth = currentMonth;
//     }
//
//       debugPrint('SR: $attendanceOutSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceOutSerialCounter', attendanceOutSerialCounter);
//     await prefs.setString('attendanceOutCurrentMonth', attendanceOutCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       attendanceOutSerialCounter = attendanceOutHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (attendanceOutCurrentMonth != currentMonth) {
//       attendanceOutSerialCounter = 1;
//       attendanceOutCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "ATD-$user_id-$currentMonth-${attendanceOutSerialCounter.toString().padLeft(3, '0')}";
//     attendanceOutSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//
//
//
//   saveFormAttendanceOut() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
//     var totalTime = prefs.getString('totalTime') ?? 0.0;
//
//      // await  _loadCounter();
//     // final orderSerial = generateNewOrderId(user_id);
//     final orderSerial = prefs.getString('attendanceId') ?? '';
//     addAttendanceOut (AttendanceOutModel(
//       attendance_out_id: orderSerial,
//       user_id: user_id,
//       // time_out: ,
//        total_distance: totalDistance,
//        total_time:  totalTime,
//        // total_time:  locationViewModel.newsecondpassed.value,
//       lat_out: locationViewModel.globalLatitude1.value,
//       lng_out: locationViewModel.globalLongitude1.value ,
//       address: locationViewModel.shopAddress.value,
//     ));
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//   }
//   fetchAllAttendanceOut() async{
//     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
//     allAttendanceOut.value = attendanceOut;
//   }
//
//   addAttendanceOut(AttendanceOutModel attendanceOutModel){
//     attendanceOutRepository.add(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   updateAttendanceOut(AttendanceOutModel attendanceOutModel){
//     attendanceOutRepository.update(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   deleteAttendanceOut(String id){
//     attendanceOutRepository.delete(id);
//     fetchAllAttendanceOut();
//   }
//   serialCounterGet()async{
//     await attendanceOutRepository.serialNumberGeneratorApi();
//   }
// }