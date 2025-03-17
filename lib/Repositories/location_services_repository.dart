// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:workmanager/workmanager.dart';
//
// import '../Tracker/location00.dart';
// import '../Tracker/trac.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../ViewModels/location_services_view_model.dart';
// import '../ViewModels/location_view_model.dart';
// import 'package:order_booking_app/main.dart' as main;
//
//
// class LocationServicesRepository extends GetxService {
//   final locationServicesViewModel = Get.put(LocationServicesViewModel());
//   final locationViewModel = Get.put(LocationViewModel());
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Geolocator _geolocator = Geolocator();
//  // final SharedPreferences _prefs; // Declare _prefs as final
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//
//
//   // Constructor to initialize _prefs
//  // LocationServicesRepository(this._prefs);
//
//   Future<void> saveLocationToFirestore(double latitude, double longitude) async {
//     SharedPreferences _prefs = await SharedPreferences.getInstance();
//     await _prefs.reload();
//     final userId = _prefs.getString("userNames") ?? "USER";
//     final userCity = _prefs.getString("userCitys") ?? "CITY";
//     final userDesignation = _prefs.getString("userDesignation") ?? "DESIGNATION";
//
//     await _firestore.collection('location').doc(userId).set({
//       'latitude': latitude,
//       'longitude': longitude,
//       'name': userId,
//       'city': userCity,
//       'designation': userDesignation,
//       'isActive': true,
//     }, SetOptions(merge: true));
//   }
//
//   Future<void> deleteLocationFromFirestore() async {
//     SharedPreferences _prefs = await SharedPreferences.getInstance();
//     await _prefs.reload();
//     final userId = _prefs.getString("userNames") ?? "USER";
//     await _firestore.collection('location').doc(userId).delete();
//   }
//
//   Future<File> createOrUpdateGpxFile() async {
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final filePath = "${downloadDirectory!.path}/track$date.gpx";
//     final file = File(filePath);
//
//     if (!file.existsSync()) {
//       file.createSync();
//     }
//
//     return file;
//   }
//
//   Future<String> readGpxFile(File file) async {
//     return file.readAsStringSync();
//   }
//
//   Future<void> writeGpxFile(File file, String gpxString) async {
//     file.writeAsStringSync(gpxString);
//   }
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     final file = File(filePath);
//     if (!file.existsSync()) return 0.0;
//
//     final gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) return 0.0;
//
//     final gpx = GpxReader().fromString(gpxContent);
//     double totalDistance = 0.0;
//
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           totalDistance += _calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//         }
//       }
//     }
//
//     return totalDistance;
//   }
//
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
//   }
//
//   callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) async {
//       return Future.value(true);
//     });
//   }
//
//   Future<void> initializeServiceLocation() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'my_foreground',
//       'MY FOREGROUND SERVICE',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.low,
//     );
//
//     if (Platform.isIOS || Platform.isAndroid) {
//       await flutterLocalNotificationsPlugin.initialize(
//         const InitializationSettings(
//           iOS: DarwinInitializationSettings(),
//           android: AndroidInitializationSettings('ic_bg_service_small'),
//         ),
//       );
//     }
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     final service = FlutterBackgroundService();
//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: main.onStart,
//         autoStart: false,
//         autoStartOnBoot: false,
//         isForegroundMode: true,
//         notificationChannelId: 'my_foreground',
//         initialNotificationTitle: 'AWESOME SERVICE',
//         initialNotificationContent: 'Initializing',
//         foregroundServiceNotificationId: 888,
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: false,
//         onForeground: main.onStart,
//       ),
//     );
//   }
// // Top-level function for onServiceStart
// //   @pragma('vm:entry-point')
// //   void onServiceStart(ServiceInstance service) async {
// //     DartPluginRegistrant.ensureInitialized();
// //
// //     // Initialize the repository and ViewModel
// //     final prefs = await SharedPreferences.getInstance();
// //     final locationServicesRepository = LocationServicesRepository();
// //     final locationServicesViewModel = LocationServicesViewModel();
// //     // await locationServicesViewModel.onInit(); // Ensure ViewModel is initialized
// //
// //     if (service is AndroidServiceInstance) {
// //       service.on('setAsForeground').listen((event) {
// //         service.setAsForegroundService();
// //       });
// //
// //       service.on('setAsBackground').listen((event) {
// //         service.setAsBackgroundService();
// //       });
// //     }
// //
// //     service.on('stopService').listen((event) async {
// //       // Stop listening to location updates
// //       locationServicesViewModel.stopListening();
// //
// //       // Delete location from Firestore
// //       await locationServicesRepository.deleteLocationFromFirestore();
// //
// //       // Cancel all background tasks
// //       Workmanager().cancelAll();
// //
// //       // Stop the service
// //       service.stopSelf();
// //
// //       // Cancel all notifications
// //       final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //       await flutterLocalNotificationsPlugin.cancelAll();
// //     });
// //
// //     Timer.periodic(const Duration(minutes: 10), (timer) async {
// //       if (service is AndroidServiceInstance && await service.isForegroundService()) {
// //         // Perform background tasks here
// //       }
// //
// //       final device = await _getDeviceInfo();
// //       service.invoke('update', {
// //         "current_date": DateTime.now().toIso8601String(),
// //         "device": device,
// //       });
// //     });
// //
// //     Workmanager().registerPeriodicTask(
// //       "1",
// //       "simpleTask",
// //       frequency: const Duration(minutes: 15),
// //     );
// //
// //     if (locationViewModel.isClockedIn.value == false) {
// //       startTimer();
// //       locationServicesViewModel.startListening();
// //     }
// //
// //     Timer.periodic(const Duration(seconds: 1), (timer) async {
// //       if (service is AndroidServiceInstance && await service.isForegroundService()) {
// //         service.setForegroundNotificationInfo(
// //           title: "ClockIn",
// //           content: "Timer ${_formatDuration(locationViewModel.secondsPassed.toString())}",
// //         );
// //       }
// //
// //       final device = await _getDeviceInfo();
// //       service.invoke('update', {
// //         "current_date": DateTime.now().toIso8601String(),
// //         "device": device,
// //       });
// //     });
// //   }
//
//
//   // @pragma('vm:entry-point')
//   // void onServiceStart(ServiceInstance service) async {
//   //   DartPluginRegistrant.ensureInitialized();
//   //
//   //   if (service is AndroidServiceInstance) {
//   //     service.on('setAsForeground').listen((event) {
//   //       service.setAsForegroundService();
//   //     });
//   //
//   //     service.on('setAsBackground').listen((event) {
//   //       service.setAsBackgroundService();
//   //     });
//   //   }
//   //
//   //   service.on('stopService').listen((event) async {
//   //     // locationService.stopListening();
//   //     locationServicesViewModel.stopListening();
//   //     await deleteLocationFromFirestore();
//   //    // locationService.deleteDocument();
//   //     Workmanager().cancelAll();
//   //     service.stopSelf();
//   //     await flutterLocalNotificationsPlugin.cancelAll();
//   //   });
//   //
//   //   Timer.periodic(const Duration(minutes: 10), (timer) async {
//   //     if (service is AndroidServiceInstance && await service.isForegroundService()) {
//   //       // Perform background tasks here
//   //     }
//   //
//   //     final device = await _getDeviceInfo();
//   //     service.invoke('update', {
//   //       "current_date": DateTime.now().toIso8601String(),
//   //       "device": device,
//   //     });
//   //   });
//   //
//   //   Workmanager().registerPeriodicTask(
//   //     "1",
//   //     "simpleTask",
//   //     frequency: const Duration(minutes: 15),
//   //   );
//   //
//   //   if (locationViewModel.isClockedIn.value == false) {
//   //     // startTimer();
//   //     await startTimer();
//   //     locationServicesViewModel.startListening();
//   //
//   //     // locationService.listenLocation();
//   //   }
//   //
//   //   Timer.periodic(const Duration(seconds: 1), (timer) async {
//   //     if (service is AndroidServiceInstance && await service.isForegroundService()) {
//   //       service.setForegroundNotificationInfo(
//   //         title: "ClockIn",
//   //         content: "Timer ${_formatDuration(locationViewModel.secondsPassed.toString())}",
//   //       );
//   //     }
//   //
//   //     final device = await _getDeviceInfo();
//   //     service.invoke('update', {
//   //       "current_date": DateTime.now().toIso8601String(),
//   //       "device": device,
//   //     });
//   //   });
//   // }
//
//   Future<String?> _getDeviceInfo() async {
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       return androidInfo.model;
//     } else if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       return iosInfo.model;
//     }
//     return null;
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//   // Function to start a timer
//   Future<void> startTimer() async {
//     startTimerFromSavedTime();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Periodically update the timer every second
//     Timer.periodic(const Duration(seconds: 1), (timer) async {
//       locationViewModel.secondsPassed.value++;
//       await prefs.setInt('secondsPassed', locationViewModel.secondsPassed.value );
//     });
//   }
//
// // Function to start the timer from saved time in SharedPreferences
//  startTimerFromSavedTime() {
//     SharedPreferences.getInstance().then((prefs) async {
//       // Retrieve saved time and calculate the total saved seconds
//       String savedTime = prefs.getString('savedTime') ?? '00:00:00';
//       List<String> timeComponents = savedTime.split(':');
//       int hours = int.parse(timeComponents[0]);
//       int minutes = int.parse(timeComponents[1]);
//       int seconds = int.parse(timeComponents[2]);
//       int totalSavedSeconds = hours * 3600 + minutes * 60 + seconds;
//
//       // Calculate the current time in seconds
//       final now = DateTime.now();
//       int totalCurrentSeconds = now.hour * 3600 + now.minute * 60 + now.second;
//       locationViewModel.secondsPassed.value = totalCurrentSeconds - totalSavedSeconds;
//
//       // Ensure secondsPassed is not negative
//       if (locationViewModel.secondsPassed.value  < 0) {
//         locationViewModel.secondsPassed.value  = 0;
//       }
//       await prefs.setInt('secondsPassed', locationViewModel.secondsPassed.value );
//       if (kDebugMode) {
//         print("Loaded Saved Time");
//       }
//     });
//   }
//
// }