// import 'dart:convert';
// import 'dart:io'; // CRITICAL: Added for File operations (delete)
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:path_provider/path_provider.dart'; // CRITICAL: Added for getDownloadsDirectory
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
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
//     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
//     await prefs.setString('currentuserId', currentuserId);
//   }
//
//   String generateNewAttendanceId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuserId != user_id) {
//       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
//       currentuserId = user_id;
//     }
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "ATN-$user_id-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
//     attendanceInSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//
//   Future<void> saveFormAttendanceIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await _loadCounter();
//
//     final attendanceId = generateNewAttendanceId(user_id);
//     await prefs.setString('attendanceId', attendanceId);
//
//     // FIX: CLEAR GPX FILE UPON CLOCK-IN
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//
//     // Delete the file to ensure a clean start for the new session's tracking
//     if (await maingpxFile.exists()) {
//       try {
//         await maingpxFile.delete();
//         debugPrint("✅ GPX file cleared upon Clock-In: $gpxFilePath");
//       } catch (e) {
//         debugPrint("⚠️ Error deleting GPX file: $e");
//       }
//     }
//     // END OF FIX
//
//     DateTime clockIn = DateTime.now();
//     await prefs.setString(
//       'attendanceInTime',
//       DateFormat("yyyy-MM-dd HH:mm:ss").format(clockIn),
//     );
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
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/attendance_Model.dart';
import '../Repositories/attendance_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceViewModel extends GetxController {
  var allAttendance = <AttendanceModel>[].obs;
  final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  // --- TIMER AND STATE VARIABLES ---
  var isClockedIn = false.obs; // Tracks if the user is currently clocked in
  DateTime? _clockInTime; // Stores the actual clock-in DateTime
  Timer? _timer; // The timer object
  var elapsedTime = '00:00:00'.obs; // Display string for elapsed time
  // ---------------------------------

  int attendanceInSerialCounter = 1;
  String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuserId = '';

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
    _loadInitialClockState(); // Load clock state on init
  }

  // Handle disposal of the timer
  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  // --- TIMER METHODS ---

  Future<void> _loadInitialClockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if there is a saved clock-in time
    String? clockInTimeString = prefs.getString('clockInTime'); //

    if (clockInTimeString != null) {
      _clockInTime = DateTime.parse(clockInTimeString); //
      isClockedIn.value = true; //
      _startTimer(); // Resume the timer if clocked in
    }
  }

  void _startTimer() {
    if (_clockInTime == null) return;

    // Cancel any existing timer to prevent duplicates
    _timer?.cancel(); //

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final duration = now.difference(_clockInTime!); // Calculate duration

      // Format the duration into H:mm:ss
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));

      elapsedTime.value = '$hours:$minutes:$seconds'; // Update observable elapsed time

      // Saving total time to preferences for use in clock-out
      _saveTotalTime(elapsedTime.value); //
    });
    debugPrint('Timer started.');
  }

  void _stopTimer() {
    _timer?.cancel(); //
    _timer = null;
    debugPrint('Timer stopped.');
  }

  // Save total elapsed time for the AttendanceOutModel
  Future<void> _saveTotalTime(String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('totalTime', time); //
  }

  // Clear clock-in state when clocking out (to be called by the Clock-Out button/logic)
  Future<void> clearClockInState() async {
    _stopTimer(); //
    isClockedIn.value = false; //
    _clockInTime = null; //
    elapsedTime.value = '00:00:00'; //
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockInTime'); //
    await prefs.remove('attendanceId'); // Clear ID for next session
    await prefs.remove('totalTime'); // Clear saved total time
    await prefs.remove('totalDistance'); // Clear distance
  }

  // ---------------------------------

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

    debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
    await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
    await prefs.setString('currentuserId', currentuserId);
  }

  String generateNewAttendanceId(String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    // If user changes, start from last known highest serial
    if (currentuserId != userId) {
      attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
      currentuserId = userId;
    }

    // Month change — reset counter
    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }

    // Example: ATD-VT0043-Oct-001
    String attendanceId =
        "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";

    // Increment for next time
    attendanceInSerialCounter++;
    _saveCounter();

    return attendanceId;
  }

  // ***************************************************************
  // Internet Speed Check
  // ***************************************************************
  Future<String> _checkInternetSpeed() async {
    try {
      final response = await http.head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return 'fast';
      } else {
        return 'slow';
      }
    } on TimeoutException {
      return 'slow';
    } on SocketException {
      return 'none';
    } catch (e) {
      debugPrint('Internet check failed: $e');
      return 'none';
    }
  }

  Future<void> saveFormAttendanceIn() async {
    // Prevent double clock-in
    if (isClockedIn.value) {
      Get.snackbar('Already Clocked In', 'You are already clocked in. Current duration: ${elapsedTime.value}',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final internetStatus = await _checkInternetSpeed();

    if (internetStatus == 'none') {
      Get.snackbar(
        'Offline Mode',
        'No internet connection detected. Clocking in offline.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade500,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } else if (internetStatus == 'slow') {
      Get.snackbar(
        'Internet Slow ⚠️',
        'Your internet is slow. Please find a faster network or turn off internet to clock-in offline.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _loadCounter();

    final attendanceId = generateNewAttendanceId(user_id);
    await prefs.setString('attendanceId', attendanceId);

    // Set clock-in state and start timer
    _clockInTime = DateTime.now(); //
    isClockedIn.value = true; //
    await prefs.setString('clockInTime', _clockInTime!.toIso8601String()); //
    _startTimer(); //

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

    if (internetStatus == 'fast') {
      await attendanceRepository.postDataFromDatabaseToAPI();
    } else {
      debugPrint('Skipping API post. Internet status: $internetStatus');
    }

    Get.snackbar(
      'Clock-In Successful',
      'You are now clocked in.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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