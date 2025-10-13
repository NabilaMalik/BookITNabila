import 'dart:convert';
import 'dart:io'; // CRITICAL: Added for File operations (delete)
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:path_provider/path_provider.dart'; // CRITICAL: Added for getDownloadsDirectory
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/attendance_Model.dart';
import '../Repositories/attendance_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceViewModel extends GetxController {
  var allAttendance = <AttendanceModel>[].obs;
  final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  int attendanceInSerialCounter = 1;
  String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuserId = '';

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
  }

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    attendanceInSerialCounter =
        prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
    attendanceInCurrentMonth =
        prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
    currentuserId = prefs.getString('currentuserId') ?? '';

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
    await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
    await prefs.setString('currentuserId', currentuserId);
  }

  String generateNewAttendanceId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuserId != user_id) {
      attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
      currentuserId = user_id;
    }

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }

    String orderId =
        "ATN-$user_id-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
    attendanceInSerialCounter++;
    _saveCounter();
    return orderId;
  }

  Future<void> saveFormAttendanceIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _loadCounter();

    final attendanceId = generateNewAttendanceId(user_id);
    await prefs.setString('attendanceId', attendanceId);

    // FIX: CLEAR GPX FILE UPON CLOCK-IN
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
    final maingpxFile = File(gpxFilePath);

    // Delete the file to ensure a clean start for the new session's tracking
    if (await maingpxFile.exists()) {
      try {
        await maingpxFile.delete();
        debugPrint("✅ GPX file cleared upon Clock-In: $gpxFilePath");
      } catch (e) {
        debugPrint("⚠️ Error deleting GPX file: $e");
      }
    }
    // END OF FIX

    DateTime clockIn = DateTime.now();
    await prefs.setString(
      'attendanceInTime',
      DateFormat("yyyy-MM-dd HH:mm:ss").format(clockIn),
    );

    addAttendance(
      AttendanceModel(
        attendance_in_id: attendanceId,
        user_id: user_id,
        city: userCity,
        booker_name: userName,
        lat_in: locationViewModel.globalLatitude1.value,
        lng_in: locationViewModel.globalLongitude1.value,
        designation: userDesignation,
        address: locationViewModel.shopAddress.value,
      ),
    );

    await attendanceRepository.postDataFromDatabaseToAPI();
  }

  Future<void> fetchAllAttendance() async {
    var attendance = await attendanceRepository.getAttendance();
    allAttendance.value = attendance;
  }

  void addAttendance(AttendanceModel attendanceModel) {
    attendanceRepository.add(attendanceModel);
    fetchAllAttendance();
  }

  void updateAttendance(AttendanceModel attendanceModel) {
    attendanceRepository.update(attendanceModel);
    fetchAllAttendance();
  }

  void deleteAttendance(String id) {
    attendanceRepository.delete(id);
    fetchAllAttendance();
  }

  Future<void> serialCounterGet() async {
    await attendanceRepository.serialNumberGeneratorApi();
  }
}




//final code
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/attendance_Model.dart';
// import '../Repositories/attendance_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class AttendanceViewModel extends GetxController {
//   var allAttendance = <AttendanceModel>[].obs;
//   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   int attendanceInSerialCounter = 1;
//   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuserId = '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendance();
//   }
//
//   Future<void> _loadCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     attendanceInSerialCounter =
//         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
//     attendanceInCurrentMonth =
//         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
//     currentuserId = prefs.getString('currentuserId') ?? '';
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
//     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
//     await prefs.setString('currentuserId', currentuserId);
//   }
//
//   String generateNewAttendanceId(String userId) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     // If user changes, start from last known highest serial
//     if (currentuserId != userId) {
//       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
//       currentuserId = userId;
//     }
//
//     // Month change — reset counter
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     // Example: ATD-VT0043-Oct-001
//     String attendanceId =
//         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
//
//     // Increment for next time
//     attendanceInSerialCounter++;
//     _saveCounter();
//
//     return attendanceId;
//   }
//
//   Future<void> saveFormAttendanceIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await _loadCounter();
//
//     final attendanceId = generateNewAttendanceId(user_id);
//     await prefs.setString('attendanceId', attendanceId);
//
//     // START OF EDIT: Save the exact Clock-In Time
//     DateTime clockIn = DateTime.now();
//     await prefs.setString(
//       'attendanceInTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockIn),
//     );
//     // END OF EDIT
//
//     addAttendance(
//       AttendanceModel(
//         attendance_in_id: attendanceId,
//         user_id: user_id,
//         city: userCity,
//         booker_name: userName,
//         lat_in: locationViewModel.globalLatitude1.value,
//         lng_in: locationViewModel.globalLongitude1.value,
//         designation: userDesignation,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceRepository.postDataFromDatabaseToAPI();
//   }
//
//   Future<void> fetchAllAttendance() async {
//     var attendance = await attendanceRepository.getAttendance();
//     allAttendance.value = attendance;
//   }
//
//   void addAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.add(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void updateAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.update(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void deleteAttendance(String id) {
//     attendanceRepository.delete(id);
//     fetchAllAttendance();
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceRepository.serialNumberGeneratorApi();
//   }
// }





// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/attendance_Model.dart';
// import '../Repositories/attendance_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class AttendanceViewModel extends GetxController {
//   var allAttendance = <AttendanceModel>[].obs;
//   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   int attendanceInSerialCounter = 1;
//   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuserId = '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendance();
//   }
//
//   Future<void> _loadCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     attendanceInSerialCounter =
//         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
//     attendanceInCurrentMonth =
//         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
//     currentuserId = prefs.getString('currentuserId') ?? '';
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
//     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
//     await prefs.setString('currentuserId', currentuserId);
//   }
//
//   String generateNewAttendanceId(String userId) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     // If user changes, start from last known highest serial
//     if (currentuserId != userId) {
//       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
//       currentuserId = userId;
//     }
//
//     // Month change — reset counter
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     // Example: ATD-VT0043-Oct-001
//     String attendanceId =
//         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
//
//     // Increment for next time
//     attendanceInSerialCounter++;
//     _saveCounter();
//
//     return attendanceId;
//   }
//
//   Future<void> saveFormAttendanceIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await _loadCounter();
//
//     final attendanceId = generateNewAttendanceId(user_id);
//     await prefs.setString('attendanceId', attendanceId);
//
//     addAttendance(
//       AttendanceModel(
//         attendance_in_id: attendanceId,
//         user_id: user_id,
//         city: userCity,
//         booker_name: userName,
//         lat_in: locationViewModel.globalLatitude1.value,
//         lng_in: locationViewModel.globalLongitude1.value,
//         designation: userDesignation,
//         address: locationViewModel.shopAddress.value,
//       ),
//     );
//
//     await attendanceRepository.postDataFromDatabaseToAPI();
//   }
//
//   Future<void> fetchAllAttendance() async {
//     var attendance = await attendanceRepository.getAttendance();
//     allAttendance.value = attendance;
//   }
//
//   void addAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.add(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void updateAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.update(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void deleteAttendance(String id) {
//     attendanceRepository.delete(id);
//     fetchAllAttendance();
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceRepository.serialNumberGeneratorApi();
//   }
// }
//










// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/attendance_Model.dart';
// import '../Repositories/attendance_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
// class AttendanceViewModel extends GetxController{
//
//   //
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
//   //
//  //
//  //  var clockedIn = false.obs;
//  //
//  //  void setClockIn(bool value) {
//  //    clockedIn.value = value;
//  //    debugPrint("ClockedIn State Updated: $value");
//  //  }
//  // // RxBool clockedIn = false.obs;
//  //  RxBool clockedOut = false.obs;
//
//   // void setClockIn(bool value) {
//   //   clockedIn.value = value;
//   //   clockedOut.value = !value;
//   //   print("Clocked In: ${clockedIn.value}, Clocked Out: ${clockedOut.value}");
//   // }
//
//
//
//   // void setClockOut(bool value) {
//   //   clockedOut.value = value;
//   //   clockedIn.value = !value;
//   //   print("Clocked In: ${clockedIn.value}, Clocked Out: ${clockedOut.value}");
//   // }
//
//   var allAttendance = <AttendanceModel>[].obs;
//   AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
// LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   int attendanceInSerialCounter = 1;
//   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     super.onInit();
//     fetchAllAttendance();
//
//   }
//
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     attendanceInSerialCounter = (prefs.getInt('attendanceInSerialCounter') ??attendanceInHighestSerial?? 1);
//     attendanceInCurrentMonth =
//         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//       debugPrint('SR: $attendanceInSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
//     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       attendanceInSerialCounter = attendanceInHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "ATD-$user_id-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
//     attendanceInSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//   saveFormAttendanceIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await   _loadCounter();
//     final orderSerial = generateNewOrderId(user_id);
//     await  prefs.setString('attendanceId', orderSerial);
//    await addAttendance(AttendanceModel(
//       attendance_in_id: orderSerial,
//       user_id: user_id,
//       city: userCity,
//       booker_name: userName,
//       lat_in: locationViewModel.globalLatitude1.value,
//       lng_in: locationViewModel.globalLongitude1.value ,
//       designation: userDesignation,
//        address: locationViewModel.shopAddress.value,
//     ));
//     await attendanceRepository.postDataFromDatabaseToAPI();
//   }
//
//   fetchAllAttendance() async{
//     var attendance = await attendanceRepository.getAttendance();
//     allAttendance.value = attendance;
//   }
//
//   addAttendance(AttendanceModel attendanceModel){
//     attendanceRepository.add(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   updateAttendance(AttendanceModel attendanceModel){
//     attendanceRepository.update(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   deleteAttendance(String id){
//     attendanceRepository.delete(id);
//     fetchAllAttendance();
//   }
//   serialCounterGet()async{
//     await attendanceRepository.serialNumberGeneratorApi();
//   }
// }