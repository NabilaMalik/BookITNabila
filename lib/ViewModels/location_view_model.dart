////Corrted work code -------15-10-25
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
// import 'package:geocoding/geocoding.dart';
// import '../Tracker/trac.dart';
//
// class LocationViewModel extends GetxController {
//   // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//   var allLocation = <LocationModel>[].obs;
//   LocationRepository locationRepository = LocationRepository();
//   var globalLatitude1 = 0.0.obs;
//   var globalLongitude1 = 0.0.obs;
//   var shopAddress = ''.obs;
//   RxInt secondsPassed = 0.obs; // Reactive variable
//   Timer? _timer;
//   RxBool isClockedIn = false.obs;
//   var isGPSEnabled = false.obs;
//   var newsecondpassed = 0.obs;
//   int locationSerialCounter = 1;
//   String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   @override
//   void onInit() {
//     super.onInit();
//     // requestPermissions();
//     //  saveCurrentLocation();  // Ensure this function is called
//     fetchAllLocation();
//     loadClockStatus();
//     clockRefresh();
//   }
//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the timer to avoid memory leaks
//     super.dispose();
//   }
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial?? 1);
//     locationCurrentMonth =
//         prefs.getString('locationCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $locationSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     debugPrint("Initializing SharedPreferences _saveCounter...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('locationSerialCounter', locationSerialCounter);
//     await prefs.setString('locationCurrentMonth', locationCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       locationSerialCounter = locationHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
//     locationSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//   Future<void> saveCurrentLocation() async {
//     PermissionStatus permission = await Permission.location.request();
//
//     if (permission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         globalLatitude1.value = position.latitude;
//         globalLongitude1.value = position.longitude;
//
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             globalLatitude1.value, globalLongitude1.value);
//
//         if (placemarks.isNotEmpty) {
//           Placemark currentPlace = placemarks[0];
//           String address = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
//           shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
//         }
//
//         debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
//         debugPrint('Address is: ${shopAddress.value}');
//
//       } catch (e) {
//         //  Get.snackbar('Error getting location: $e',backgroundColor: Colors.red);
//       }
//     }
//   }
//   // Function to load clock status from SharedPreferences
//   loadClockStatus() async {
//     debugPrint("Initializing SharedPreferences loadClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
//     if (isClockedIn.value == true) {
//       // startTimerFromSavedTime(); // Commented out as function is missing
//       // locationServicesRepository.startTimerFromSavedTime(); // Commented out as function is missing
//       // Uncomment these lines if needed
//       // final service = FlutterBackgroundService();
//       // service.startService();
//       // _clockRefresh();
//     } else {
//       prefs.setInt('secondsPassed', 0);
//     }
//   }
//
//
//
// // Function to save the current time to SharedPreferences
//   saveCurrentTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime currentTime = DateTime.now();
//     String formattedTime = _formatDateTime(currentTime);
//     prefs.reload();
//     prefs.setString('savedTime', formattedTime);
//
//     debugPrint("Save Current Time");
//
//   }
//   // Function to refresh the clock timer
//   clockRefresh() async {
//     newsecondpassed.value = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       // debugPrint("Initializing SharedPreferences clockRefresh...");
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.reload();
//       newsecondpassed.value = prefs.getInt('secondsPassed')!;
//     });
//
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   Future<String> stopTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _timer?.cancel();
//     String totalTime = _formatDuration(newsecondpassed.value.toString());
//     await prefs.reload();
//     debugPrint("Initializing SharedPreferences stopTimer...");
//     await prefs.setInt('secondsPassed', 0);
//
//     secondsPassed.value = 0;
//
//     await prefs.setString('totalTime', totalTime);
//     return totalTime;
//   }
//   // Function to format DateTime object to a string
//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm:ss');
//     return formatter.format(dateTime);
//   }
// // Function to save clock status to SharedPreferences
//   saveClockStatus(bool clockedIn) async {
//     debugPrint("Initializing SharedPreferences saveClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     await prefs.setBool('isClockedIn', clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     File file = File(filePath);
//     if (!file.existsSync()) {
//       return 0.0;
//     }
//
//     // Read GPX content from file
//     String gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) {
//       return 0.0;
//     }
//
//     // Parse GPX content
//     Gpx gpx;
//     try {
//       gpx = GpxReader().fromString(gpxContent);
//     } catch (e) {
//
//       debugPrint("Error parsing GPX content: $e");
//
//       return 0.0;
//     }
//
//     // Calculate total distance
//     double totalDistance = 0.0;
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           double distance = calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//           totalDistance += distance;
//         }
//       }
//     }
//
//
//     debugPrint("CUT: $totalDistance");
//
//
//     return totalDistance;
//   }
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Multiply the result by 2
//   }
//   saveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//     // Calculate the distance
//     double totalDistance = await calculateTotalDistance("${downloadDirectory?.path}/track$date.gpx");
//
//     // 🔑 Save the calculated distance to SharedPreferences for AttendanceOut
//     await prefs.reload();
//     await prefs.setDouble('totalDistance', totalDistance);
//
//     if (!maingpxFile.existsSync()) {
//
//       debugPrint('GPX file does not exist');
//
//       return;
//     }
//     // Read the GPX file
//     List<int> gpxBytesList = await maingpxFile.readAsBytes();
//     Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
//     await _loadCounter();
//     final orderSerial = generateNewOrderId(user_id);
//     await addLocation(LocationModel(
//       location_id:  orderSerial.toString(),
//       user_id: user_id.toString(),
//       total_distance: totalDistance.toString(),
//       file_name: "$date.gpx",
//       booker_name: userName,
//       body: gpxBytes,
//
//     ));
//     await locationRepository.postDataFromDatabaseToAPI();
//   }
//   Future<void> requestPermissions() async {
//
//
//     debugPrint('Requesting notification permission...');
//
//     if (await Permission.notification.request().isDenied) {
//       // Notification permission not granted
//
//       debugPrint('Notification permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//
//     debugPrint('Requesting location permission...');
//
//     if (await Permission.location.request().isDenied) {
//       // Location permission not granted
//
//       debugPrint('Location permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//     } else if (await Permission.location.request().isGranted) {
//
//       debugPrint('Location permission granted');
//
//       // Check and request background location permission if necessary
//       if (await Permission.locationAlways.request().isDenied) {
//         // Background location permission not granted
//
//         debugPrint('Background location permission denied');
//
//         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       } else {
//
//         debugPrint('All permissions granted');
//
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => const LoginForm(),
//         //   ),
//         // );
//         // Navigate to the login page if all permissions are granted
//       }
//     }
//   }
//   Future<void> fetchAllLocation() async {
//     var location = await locationRepository.getLocation();
//     allLocation.value = location;
//   }
//
//   addLocation(LocationModel locationModel) {
//     locationRepository.add(locationModel);
//     fetchAllLocation();
//   }
//
//   void updateLocation(LocationModel locationModel) {
//     locationRepository.update(locationModel);
//     fetchAllLocation();
//   }
//
//   void deleteLocation(String id) {
//     locationRepository.delete(id);
//     fetchAllLocation();
//   }
//   serialCounterGet()async{
//     await locationRepository.serialNumberGeneratorApi();
//   }
// }

// ///15-10-25
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
// import 'package:geocoding/geocoding.dart';
// import '../Tracker/trac.dart';
//
// class LocationViewModel extends GetxController {
//   // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//   var allLocation = <LocationModel>[].obs;
//   LocationRepository locationRepository = LocationRepository();
//   var globalLatitude1 = 0.0.obs;
//   var globalLongitude1 = 0.0.obs;
//   var shopAddress = ''.obs;
//   RxInt secondsPassed = 0.obs; // Reactive variable
//   Timer? _timer;
//   RxBool isClockedIn = false.obs;
//   var isGPSEnabled = false.obs;
//   var newsecondpassed = 0.obs;
//   int locationSerialCounter = 1;
//   String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   @override
//   void onInit() {
//     super.onInit();
//     // requestPermissions();
//     //  saveCurrentLocation();  // Ensure this function is called
//     fetchAllLocation();
//     loadClockStatus();
//     clockRefresh();
//   }
//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the timer to avoid memory leaks
//     super.dispose();
//   }
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial?? 1);
//     locationCurrentMonth =
//         prefs.getString('locationCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $locationSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     debugPrint("Initializing SharedPreferences _saveCounter...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('locationSerialCounter', locationSerialCounter);
//     await prefs.setString('locationCurrentMonth', locationCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       locationSerialCounter = locationHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
//     locationSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//   Future<void> saveCurrentLocation() async {
//     PermissionStatus permission = await Permission.location.request();
//
//     if (permission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         globalLatitude1.value = position.latitude;
//         globalLongitude1.value = position.longitude;
//
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             globalLatitude1.value, globalLongitude1.value);
//
//         if (placemarks.isNotEmpty) {
//           Placemark currentPlace = placemarks[0];
//           String address = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
//           shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
//         }
//
//         debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
//         debugPrint('Address is: ${shopAddress.value}');
//
//       } catch (e) {
//         //  Get.snackbar('Error getting location: $e',backgroundColor: Colors.red);
//       }
//     }
//   }
//   // Function to load clock status from SharedPreferences
//   loadClockStatus() async {
//     debugPrint("Initializing SharedPreferences loadClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
//     if (isClockedIn.value == true) {
//       // startTimerFromSavedTime(); // Commented out as function is missing
//       // locationServicesRepository.startTimerFromSavedTime(); // Commented out as function is missing
//       // Uncomment these lines if needed
//       // final service = FlutterBackgroundService();
//       // service.startService();
//       // _clockRefresh();
//     } else {
//       prefs.setInt('secondsPassed', 0);
//     }
//   }
//
//
//
// // Function to save the current time to SharedPreferences
//   saveCurrentTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime currentTime = DateTime.now();
//     String formattedTime = _formatDateTime(currentTime);
//     prefs.reload();
//     prefs.setString('savedTime', formattedTime);
//
//     debugPrint("Save Current Time");
//
//   }
//   // Function to refresh the clock timer
//   clockRefresh() async {
//     newsecondpassed.value = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       // debugPrint("Initializing SharedPreferences clockRefresh...");
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.reload();
//       newsecondpassed.value = prefs.getInt('secondsPassed')!;
//     });
//
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   Future<String> stopTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _timer?.cancel();
//     String totalTime = _formatDuration(newsecondpassed.value.toString());
//     await prefs.reload();
//     debugPrint("Initializing SharedPreferences stopTimer...");
//     await prefs.setInt('secondsPassed', 0);
//
//     secondsPassed.value = 0;
//
//     await prefs.setString('totalTime', totalTime);
//     return totalTime;
//   }
//   // Function to format DateTime object to a string
//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm:ss');
//     return formatter.format(dateTime);
//   }
// // Function to save clock status to SharedPreferences
//   saveClockStatus(bool clockedIn) async {
//     debugPrint("Initializing SharedPreferences saveClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     await prefs.setBool('isClockedIn', clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     File file = File(filePath);
//     if (!file.existsSync()) {
//       return 0.0;
//     }
//
//     // Read GPX content from file
//     String gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) {
//       return 0.0;
//     }
//
//     // Parse GPX content
//     Gpx gpx;
//     try {
//       gpx = GpxReader().fromString(gpxContent);
//     } catch (e) {
//
//       debugPrint("Error parsing GPX content: $e");
//
//       return 0.0;
//     }
//
//     // Calculate total distance
//     double totalDistance = 0.0;
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           double distance = calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//           totalDistance += distance;
//         }
//       }
//     }
//
//
//     debugPrint("CUT: $totalDistance");
//
//
//     return totalDistance;
//   }
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Multiply the result by 2
//   }
//   saveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//     // Calculate the distance
//     double totalDistance = await calculateTotalDistance("${downloadDirectory?.path}/track$date.gpx");
//
//     // 🔑 Save the calculated distance to SharedPreferences for AttendanceOut
//     await prefs.reload();
//     await prefs.setDouble('totalDistance', totalDistance);
//
//     if (!maingpxFile.existsSync()) {
//
//       debugPrint('GPX file does not exist');
//
//       return;
//     }
//     // Read the GPX file
//     List<int> gpxBytesList = await maingpxFile.readAsBytes();
//     Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
//     await _loadCounter();
//     final orderSerial = generateNewOrderId(user_id);
//     await addLocation(LocationModel(
//       location_id:  orderSerial.toString(),
//       user_id: user_id.toString(),
//       total_distance: totalDistance.toString(),
//       file_name: "$date.gpx",
//       booker_name: userName,
//       body: gpxBytes,
//
//     ));
//     await locationRepository.postDataFromDatabaseToAPI();
//   }
//   Future<void> requestPermissions() async {
//
//
//     debugPrint('Requesting notification permission...');
//
//     if (await Permission.notification.request().isDenied) {
//       // Notification permission not granted
//
//       debugPrint('Notification permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//
//     debugPrint('Requesting location permission...');
//
//     if (await Permission.location.request().isDenied) {
//       // Location permission not granted
//
//       debugPrint('Location permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//     } else if (await Permission.location.request().isGranted) {
//
//       debugPrint('Location permission granted');
//
//       // Check and request background location permission if necessary
//       if (await Permission.locationAlways.request().isDenied) {
//         // Background location permission not granted
//
//         debugPrint('Background location permission denied');
//
//         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       } else {
//
//         debugPrint('All permissions granted');
//
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => const LoginForm(),
//         //   ),
//         // );
//         // Navigate to the login page if all permissions are granted
//       }
//     }
//   }
//   Future<void> fetchAllLocation() async {
//     var location = await locationRepository.getLocation();
//     allLocation.value = location;
//   }
//
//   addLocation(LocationModel locationModel) {
//     locationRepository.add(locationModel);
//     fetchAllLocation();
//   }
//
//   void updateLocation(LocationModel locationModel) {
//     locationRepository.update(locationModel);
//     fetchAllLocation();
//   }
//
//   void deleteLocation(String id) {
//     locationRepository.delete(id);
//     fetchAllLocation();
//   }
//   serialCounterGet()async{
//     await locationRepository.serialNumberGeneratorApi();
//   }
// }


////Corrted work code -------15-10-25
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
// import 'package:geocoding/geocoding.dart';
// import '../Tracker/trac.dart';
//
// class LocationViewModel extends GetxController {
//   // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//   var allLocation = <LocationModel>[].obs;
//   LocationRepository locationRepository = LocationRepository();
//   var globalLatitude1 = 0.0.obs;
//   var globalLongitude1 = 0.0.obs;
//   var shopAddress = ''.obs;
//   RxInt secondsPassed = 0.obs; // Reactive variable
//   Timer? _timer;
//   RxBool isClockedIn = false.obs;
//   var isGPSEnabled = false.obs;
//   var newsecondpassed = 0.obs;
//   int locationSerialCounter = 1;
//   String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   @override
//   void onInit() {
//     super.onInit();
//     // requestPermissions();
//     //  saveCurrentLocation();  // Ensure this function is called
//     fetchAllLocation();
//     loadClockStatus();
//     clockRefresh();
//     checkGpsStatus(); // 👈 Added: Check GPS status on initialization
//   }
//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the timer to avoid memory leaks
//     super.dispose();
//   }
//
//   Future<void> checkGpsStatus() async {
//     isGPSEnabled.value = await Geolocator.isLocationServiceEnabled();
//     debugPrint('GPS Enabled Status: ${isGPSEnabled.value}');
//   } // 👈 Added: Function to check GPS status
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial?? 1);
//     locationCurrentMonth =
//         prefs.getString('locationCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $locationSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     debugPrint("Initializing SharedPreferences _saveCounter...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('locationSerialCounter', locationSerialCounter);
//     await prefs.setString('locationCurrentMonth', locationCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       locationSerialCounter = locationHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
//     locationSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//   Future<void> saveCurrentLocation() async {
//     PermissionStatus permission = await Permission.location.request();
//
//     if (permission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         globalLatitude1.value = position.latitude;
//         globalLongitude1.value = position.longitude;
//
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             globalLatitude1.value, globalLongitude1.value);
//
//         if (placemarks.isNotEmpty) {
//           Placemark currentPlace = placemarks[0];
//           String address = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
//           shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
//         }
//
//         debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
//         debugPrint('Address is: ${shopAddress.value}');
//
//       } catch (e) {
//         //  Get.snackbar('Error getting location: $e',backgroundColor: Colors.red);
//       }
//     }
//   }
//   // Function to load clock status from SharedPreferences
//   loadClockStatus() async {
//     debugPrint("Initializing SharedPreferences loadClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
//     if (isClockedIn.value == true) {
//       // startTimerFromSavedTime(); // Commented out as function is missing
//       // locationServicesRepository.startTimerFromSavedTime(); // Commented out as function is missing
//       // Uncomment these lines if needed
//       // final service = FlutterBackgroundService();
//       // service.startService();
//       // _clockRefresh();
//     } else {
//       prefs.setInt('secondsPassed', 0);
//     }
//   }
//
//
//
// // Function to save the current time to SharedPreferences
//   saveCurrentTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime currentTime = DateTime.now();
//     String formattedTime = _formatDateTime(currentTime);
//     prefs.reload();
//     prefs.setString('savedTime', formattedTime);
//
//     debugPrint("Save Current Time");
//
//   }
//   // Function to refresh the clock timer
//   clockRefresh() async {
//     newsecondpassed.value = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       // debugPrint("Initializing SharedPreferences clockRefresh...");
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.reload();
//       newsecondpassed.value = prefs.getInt('secondsPassed')!;
//     });
//
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   Future<String> stopTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _timer?.cancel();
//     String totalTime = _formatDuration(newsecondpassed.value.toString());
//     await prefs.reload();
//     debugPrint("Initializing SharedPreferences stopTimer...");
//     await prefs.setInt('secondsPassed', 0);
//
//     secondsPassed.value = 0;
//
//     await prefs.setString('totalTime', totalTime);
//     return totalTime;
//   }
//   // Function to format DateTime object to a string
//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm:ss');
//     return formatter.format(dateTime);
//   }
// // Function to save clock status to SharedPreferences
//   saveClockStatus(bool clockedIn) async {
//     debugPrint("Initializing SharedPreferences saveClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     await prefs.setBool('isClockedIn', clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     File file = File(filePath);
//     if (!file.existsSync()) {
//       return 0.0;
//     }
//
//     // Read GPX content from file
//     String gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) {
//       return 0.0;
//     }
//
//     // Parse GPX content
//     Gpx gpx;
//     try {
//       gpx = GpxReader().fromString(gpxContent);
//     } catch (e) {
//
//       debugPrint("Error parsing GPX content: $e");
//
//       return 0.0;
//     }
//
//     // Calculate total distance
//     double totalDistance = 0.0;
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           double distance = calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//           totalDistance += distance;
//         }
//       }
//     }
//
//
//     debugPrint("CUT: $totalDistance");
//
//
//     return totalDistance;
//   }
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Multiply the result by 2
//   }
//   saveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//     // Calculate the distance
//     double totalDistance = await calculateTotalDistance("${downloadDirectory?.path}/track$date.gpx");
//
//     // 🔑 Save the calculated distance to SharedPreferences for AttendanceOut
//     await prefs.reload();
//     await prefs.setDouble('totalDistance', totalDistance);
//
//     if (!maingpxFile.existsSync()) {
//
//       debugPrint('GPX file does not exist');
//
//       return;
//     }
//     // Read the GPX file
//     List<int> gpxBytesList = await maingpxFile.readAsBytes();
//     Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
//     await _loadCounter();
//     // 🔑 Assumed: user_id and userName are globally accessible or passed in the real app.
//     // For this demonstration, I'll use placeholders that were in the original file's context.
//     // Replace user_id and userName with actual values in your real app.
//     final user_id = 'USER_ID_PLACEHOLDER';
//     final userName = 'USER_NAME_PLACEHOLDER';
//     final orderSerial = generateNewOrderId(user_id);
//     await addLocation(LocationModel(
//       location_id:  orderSerial.toString(),
//       user_id: user_id.toString(),
//       total_distance: totalDistance.toString(),
//       file_name: "$date.gpx",
//       booker_name: userName,
//       body: gpxBytes,
//
//     ));
//     await locationRepository.postDataFromDatabaseToAPI();
//   }
//   Future<void> requestPermissions() async {
//
//
//     debugPrint('Requesting notification permission...');
//
//     if (await Permission.notification.request().isDenied) {
//       // Notification permission not granted
//
//       debugPrint('Notification permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//
//     debugPrint('Requesting location permission...');
//
//     if (await Permission.location.request().isDenied) {
//       // Location permission not granted
//
//       debugPrint('Location permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//     } else if (await Permission.location.request().isGranted) {
//
//       debugPrint('Location permission granted');
//
//       // Check and request background location permission if necessary
//       if (await Permission.locationAlways.request().isDenied) {
//         // Background location permission not granted
//
//         debugPrint('Background location permission denied');
//
//         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       } else {
//
//         debugPrint('All permissions granted');
//
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => const LoginForm(),
//         //   ),
//         // );
//         // Navigate to the login page if all permissions are granted
//       }
//     }
//   }
//   Future<void> fetchAllLocation() async {
//     var location = await locationRepository.getLocation();
//     allLocation.value = location;
//   }
//
//   addLocation(LocationModel locationModel) {
//     locationRepository.add(locationModel);
//     fetchAllLocation();
//   }
//
//   void updateLocation(LocationModel locationModel) {
//     locationRepository.update(locationModel);
//     fetchAllLocation();
//   }
//
//   void deleteLocation(String id) {
//     locationRepository.delete(id);
//     fetchAllLocation();
//   }
//   serialCounterGet()async{
//     await locationRepository.serialNumberGeneratorApi();
//   }
// }



//
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
// import 'package:geocoding/geocoding.dart';
// import '../Tracker/trac.dart';
//
// class LocationViewModel extends GetxController {
//   // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//   var allLocation = <LocationModel>[].obs;
//   LocationRepository locationRepository = LocationRepository();
//   var globalLatitude1 = 0.0.obs;
//   var globalLongitude1 = 0.0.obs;
//   var shopAddress = ''.obs;
//   RxInt secondsPassed = 0.obs; // Reactive variable
//   Timer? _timer;
//   RxBool isClockedIn = false.obs;
//   var isGPSEnabled = false.obs;
//   var newsecondpassed = 0.obs;
//   int locationSerialCounter = 1;
//   String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   @override
//   void onInit() {
//     super.onInit();
//     // requestPermissions();
//     //  saveCurrentLocation();  // Ensure this function is called
//     fetchAllLocation();
//     loadClockStatus();
//     clockRefresh();
//   }
//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the timer to avoid memory leaks
//     super.dispose();
//   }
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial?? 1);
//     locationCurrentMonth =
//         prefs.getString('locationCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $locationSerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     debugPrint("Initializing SharedPreferences _saveCounter...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('locationSerialCounter', locationSerialCounter);
//     await prefs.setString('locationCurrentMonth', locationCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       locationSerialCounter = locationHighestSerial??1;
//       currentuser_id = user_id;
//     }
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
//     locationSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//   Future<void> saveCurrentLocation() async {
//     PermissionStatus permission = await Permission.location.request();
//
//     if (permission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         globalLatitude1.value = position.latitude;
//         globalLongitude1.value = position.longitude;
//
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             globalLatitude1.value, globalLongitude1.value);
//
//         if (placemarks.isNotEmpty) {
//           Placemark currentPlace = placemarks[0];
//           String address = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
//           shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
//         }
//
//         debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
//         debugPrint('Address is: ${shopAddress.value}');
//
//       } catch (e) {
//         //  Get.snackbar('Error getting location: $e',backgroundColor: Colors.red);
//       }
//     }
//   }
//   // Function to load clock status from SharedPreferences
//   loadClockStatus() async {
//     debugPrint("Initializing SharedPreferences loadClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
//     if (isClockedIn.value == true) {
//       // startTimerFromSavedTime(); // Commented out as function is missing
//       // locationServicesRepository.startTimerFromSavedTime(); // Commented out as function is missing
//       // Uncomment these lines if needed
//       // final service = FlutterBackgroundService();
//       // service.startService();
//       // _clockRefresh();
//     } else {
//       prefs.setInt('secondsPassed', 0);
//     }
//   }
//
//
//
// // Function to save the current time to SharedPreferences
//   saveCurrentTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime currentTime = DateTime.now();
//     String formattedTime = _formatDateTime(currentTime);
//     prefs.reload();
//     prefs.setString('savedTime', formattedTime);
//
//     debugPrint("Save Current Time");
//
//   }
//   // Function to refresh the clock timer
//   clockRefresh() async {
//     newsecondpassed.value = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       // debugPrint("Initializing SharedPreferences clockRefresh...");
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.reload();
//       newsecondpassed.value = prefs.getInt('secondsPassed')!;
//     });
//
//   }
//
//   String _formatDuration(String secondsString) {
//     int seconds = int.parse(secondsString);
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$secondsFormatted';
//   }
//
//   Future<String> stopTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _timer?.cancel();
//     String totalTime = _formatDuration(newsecondpassed.value.toString());
//     await prefs.reload();
//     debugPrint("Initializing SharedPreferences stopTimer...");
//     await prefs.setInt('secondsPassed', 0);
//
//     secondsPassed.value = 0;
//
//     await prefs.setString('totalTime', totalTime);
//     return totalTime;
//   }
//   // Function to format DateTime object to a string
//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm:ss');
//     return formatter.format(dateTime);
//   }
// // Function to save clock status to SharedPreferences
//   saveClockStatus(bool clockedIn) async {
//     debugPrint("Initializing SharedPreferences saveClockStatus...");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     await prefs.setBool('isClockedIn', clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     File file = File(filePath);
//     if (!file.existsSync()) {
//       return 0.0;
//     }
//
//     // Read GPX content from file
//     String gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) {
//       return 0.0;
//     }
//
//     // Parse GPX content
//     Gpx gpx;
//     try {
//       gpx = GpxReader().fromString(gpxContent);
//     } catch (e) {
//
//       debugPrint("Error parsing GPX content: $e");
//
//       return 0.0;
//     }
//
//     // Calculate total distance
//     double totalDistance = 0.0;
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           double distance = calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//           totalDistance += distance;
//         }
//       }
//     }
//
//
//     debugPrint("CUT: $totalDistance");
//
//
//     return totalDistance;
//   }
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Multiply the result by 2
//   }
//   saveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//     // Calculate the distance
//     double totalDistance = await calculateTotalDistance("${downloadDirectory?.path}/track$date.gpx");
//
//     // 🔑 Save the calculated distance to SharedPreferences for AttendanceOut
//     await prefs.reload();
//     await prefs.setDouble('totalDistance', totalDistance);
//
//     if (!maingpxFile.existsSync()) {
//
//       debugPrint('GPX file does not exist');
//
//       return;
//     }
//     // Read the GPX file
//     List<int> gpxBytesList = await maingpxFile.readAsBytes();
//     Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
//     await _loadCounter();
//     final orderSerial = generateNewOrderId(user_id);
//     await addLocation(LocationModel(
//       location_id:  orderSerial.toString(),
//       user_id: user_id.toString(),
//       total_distance: totalDistance.toString(),
//       file_name: "$date.gpx",
//       booker_name: userName,
//       body: gpxBytes,
//
//     ));
//     await locationRepository.postDataFromDatabaseToAPI();
//   }
//   Future<void> requestPermissions() async {
//
//
//     debugPrint('Requesting notification permission...');
//
//     if (await Permission.notification.request().isDenied) {
//       // Notification permission not granted
//
//       debugPrint('Notification permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//
//     debugPrint('Requesting location permission...');
//
//     if (await Permission.location.request().isDenied) {
//       // Location permission not granted
//
//       debugPrint('Location permission denied');
//
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//     } else if (await Permission.location.request().isGranted) {
//
//       debugPrint('Location permission granted');
//
//       // Check and request background location permission if necessary
//       if (await Permission.locationAlways.request().isDenied) {
//         // Background location permission not granted
//
//         debugPrint('Background location permission denied');
//
//         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       } else {
//
//         debugPrint('All permissions granted');
//
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => const LoginForm(),
//         //   ),
//         // );
//         // Navigate to the login page if all permissions are granted
//       }
//     }
//   }
//   Future<void> fetchAllLocation() async {
//     var location = await locationRepository.getLocation();
//     allLocation.value = location;
//   }
//
//   addLocation(LocationModel locationModel) {
//     locationRepository.add(locationModel);
//     fetchAllLocation();
//   }
//
//   void updateLocation(LocationModel locationModel) {
//     locationRepository.update(locationModel);
//     fetchAllLocation();
//   }
//
//   void deleteLocation(String id) {
//     locationRepository.delete(id);
//     fetchAllLocation();
//   }
//   serialCounterGet()async{
//     await locationRepository.serialNumberGeneratorApi();
//   }
// }


////////////Fully working code 16-10-25
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart'; // Added to use AlertDialog
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
// import 'package:geocoding/geocoding.dart';
// import '../Tracker/trac.dart';
//
// class LocationViewModel extends GetxController {
//   // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//   var allLocation = <LocationModel>[].obs;
//   LocationRepository locationRepository = LocationRepository();
//   var globalLatitude1 = 0.0.obs;
//   var globalLongitude1 = 0.0.obs;
//   var shopAddress = ''.obs;
//   RxInt secondsPassed = 0.obs;
//   Timer? _timer;
//   RxBool isClockedIn = false.obs;
//   var isGPSEnabled = false.obs;
//   var newsecondpassed = 0.obs;
//   int locationSerialCounter = 1;
//   String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     // The commented out line below is present in the first code snippet
//     // requestPermissions();
//     fetchAllLocation();
//     loadClockStatus();
//     clockRefresh();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // --- Counter Logic ---
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial ?? 1);
//     locationCurrentMonth =
//         prefs.getString('locationCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     debugPrint('SR: $locationSerialCounter');
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('locationSerialCounter', locationSerialCounter);
//     await prefs.setString('locationCurrentMonth', locationCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       locationSerialCounter = locationHighestSerial ?? 1;
//       currentuser_id = user_id;
//     }
//
//     if (locationCurrentMonth != currentMonth) {
//       locationSerialCounter = 1;
//       locationCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
//     locationSerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//
//   // --- Location and Clock Status ---
//
//   Future<void> saveCurrentLocation() async {
//     PermissionStatus permission = await Permission.location.request();
//
//     if (permission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         globalLatitude1.value = position.latitude;
//         globalLongitude1.value = position.longitude;
//
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             globalLatitude1.value, globalLongitude1.value);
//
//         if (placemarks.isNotEmpty) {
//           Placemark currentPlace = placemarks[0];
//           String address =
//               "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
//           shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
//         }
//
//         debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
//         debugPrint('Address is: ${shopAddress.value}');
//       } catch (e) {
//         debugPrint("Error getting location: $e");
//       }
//     }
//   }
//
//   loadClockStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
//     if (!isClockedIn.value) {
//       prefs.setInt('secondsPassed', 0);
//     }
//   }
//
//   saveCurrentTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     DateTime currentTime = DateTime.now();
//     String formattedTime = _formatDateTime(currentTime);
//     prefs.reload();
//     prefs.setString('savedTime', formattedTime);
//     debugPrint("Save Current Time");
//   }
//
//   clockRefresh() async {
//     newsecondpassed.value = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.reload();
//       // Use the null-safe check from the second snippet
//       newsecondpassed.value = prefs.getInt('secondsPassed') ?? 0;
//     });
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
//
//   Future<String> stopTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _timer?.cancel();
//
//     // The second code has a better approach for the final value (though it relies on another ViewModel to set 'totalTime')
//     // We'll use the final value from the counter for consistency with the first code's logic, but clean up the logic.
//     String totalTime = _formatDuration(newsecondpassed.value.toString());
//
//     await prefs.reload();
//     await prefs.setInt('secondsPassed', 0);
//
//     secondsPassed.value = 0;
//     newsecondpassed.value = 0; // Reset reactive timer
//
//     await prefs.setString('totalTime', totalTime);
//     return totalTime;
//   }
//
//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm:ss');
//     return formatter.format(dateTime);
//   }
//
//   saveClockStatus(bool clockedIn) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     await prefs.setBool('isClockedIn', clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//   // --- GPX and Distance Calculation ---
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     File file = File(filePath);
//     if (!file.existsSync()) {
//       return 0.0;
//     }
//
//     String gpxContent = await file.readAsString();
//     if (gpxContent.isEmpty) {
//       return 0.0;
//     }
//
//     Gpx gpx;
//     try {
//       gpx = GpxReader().fromString(gpxContent);
//     } catch (e) {
//       debugPrint("Error parsing GPX content: $e");
//       return 0.0;
//     }
//
//     double totalDistance = 0.0;
//     for (var track in gpx.trks) {
//       for (var segment in track.trksegs) {
//         for (int i = 0; i < segment.trkpts.length - 1; i++) {
//           double distance = calculateDistance(
//             segment.trkpts[i].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i].lon?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//             segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//           );
//           totalDistance += distance;
//         }
//       }
//     }
//
//     debugPrint("CUT: $totalDistance");
//     return totalDistance;
//   }
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Distance in kilometers
//   }
//
//   saveLocation() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     final downloadDirectory = await getDownloadsDirectory();
//     final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
//     final maingpxFile = File(gpxFilePath);
//
//     double totalDistance = await calculateTotalDistance(gpxFilePath);
//
//     await prefs.reload();
//     await prefs.setDouble('totalDistance', totalDistance);
//
//     if (!maingpxFile.existsSync()) {
//       debugPrint('GPX file does not exist');
//       return;
//     }
//
//     List<int> gpxBytesList = await maingpxFile.readAsBytes();
//     Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
//     await _loadCounter();
//     final orderSerial = generateNewOrderId(user_id);
//     await addLocation(LocationModel(
//       location_id: orderSerial.toString(),
//       user_id: user_id.toString(),
//       total_distance: totalDistance.toString(),
//       file_name: "$date.gpx",
//       booker_name: userName,
//       body: gpxBytes,
//     ));
//     await locationRepository.postDataFromDatabaseToAPI();
//   }
//
//   // --- Permissions and Dialog (Adopted from Code 2) ---
//
//   Future<void> requestPermissions() async {
//     // 1. Notification Permission (from Code 1)
//     debugPrint('Requesting notification permission...');
//     if (await Permission.notification.request().isDenied) {
//       debugPrint('Notification permission denied');
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//     debugPrint('Requesting location permission...');
//
//     // 2. Location Permission Check & Request (Improved logic from Code 2 using Geolocator)
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       debugPrint('Location permission denied or denied forever');
//       _showLocationRequiredDialog();
//       return;
//     }
//
//     // 3. Location Service Status Check (from Code 2)
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       debugPrint('Location service is disabled');
//       _showLocationRequiredDialog();
//       return;
//     }
//
//     // 4. Background Location Permission (from Code 1, using permission_handler)
//     if (await Permission.locationAlways.request().isDenied) {
//       debugPrint('Background location permission denied');
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//     debugPrint('All permissions granted');
//   }
//
//   void _showLocationRequiredDialog() {
//     // Dialog logic from Code 2
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: AlertDialog(
//           title: const Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
//                 const SizedBox(height: 16),
//                 const Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
//                     const SizedBox(width: 8),
//                     const Text('Device location'),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
//                     const SizedBox(width: 8),
//                     const Text('Location Accuracy'),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//               ],
//             ),
//           ),
//           actions: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await Geolocator.openLocationSettings();
//                   Get.back();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('TURN ON'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   // --- Database Operations ---
//
//   Future<void> fetchAllLocation() async {
//     var location = await locationRepository.getLocation();
//     allLocation.value = location;
//   }
//
//   addLocation(LocationModel locationModel) {
//     locationRepository.add(locationModel);
//     fetchAllLocation();
//   }
//
//   void updateLocation(LocationModel locationModel) {
//     locationRepository.update(locationModel);
//     fetchAllLocation();
//   }
//
//   void deleteLocation(String id) {
//     locationRepository.delete(id);
//     fetchAllLocation();
//   }
//
//   serialCounterGet() async {
//     await locationRepository.serialNumberGeneratorApi();
//   }





import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added to use AlertDialog
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Repositories/location_services_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/location_model.dart';
import '../Repositories/location_repository.dart';
import 'package:geocoding/geocoding.dart';
import '../Tracker/trac.dart';

class LocationViewModel extends GetxController {
  // late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
  var allLocation = <LocationModel>[].obs;
  LocationRepository locationRepository = LocationRepository();
  var globalLatitude1 = 0.0.obs;
  var globalLongitude1 = 0.0.obs;
  var shopAddress = ''.obs;
  RxInt secondsPassed = 0.obs;
  Timer? _timer;
  RxBool isClockedIn = false.obs;
  var isGPSEnabled = false.obs;
  var newsecondpassed = 0.obs;
  int locationSerialCounter = 1;
  String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  void onInit() {
    super.onInit();
    // The commented out line below is present in the first code snippet
    // requestPermissions();
    fetchAllLocation();
    loadClockStatus();
    clockRefresh();


  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Counter Logic ---

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial ?? 1);
    locationCurrentMonth =
        prefs.getString('locationCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (locationCurrentMonth != currentMonth) {
      locationSerialCounter = 1;
      locationCurrentMonth = currentMonth;
    }

    debugPrint('SR: $locationSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('locationSerialCounter', locationSerialCounter);
    await prefs.setString('locationCurrentMonth', locationCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      locationSerialCounter = locationHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (locationCurrentMonth != currentMonth) {
      locationSerialCounter = 1;
      locationCurrentMonth = currentMonth;
    }

    String orderId =
        "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
    locationSerialCounter++;
    _saveCounter();
    return orderId;
  }

  // --- Location and Clock Status ---

  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude1.value = position.latitude;
        globalLongitude1.value = position.longitude;

        List<Placemark> placemarks = await placemarkFromCoordinates(
            globalLatitude1.value, globalLongitude1.value);

        if (placemarks.isNotEmpty) {
          Placemark currentPlace = placemarks[0];
          String address =
              "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
          shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
        }

        debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
        debugPrint('Address is: ${shopAddress.value}');
      } catch (e) {
        debugPrint("Error getting location: $e");
      }
    }
  }

  loadClockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
    if (!isClockedIn.value) {
      prefs.setInt('secondsPassed', 0);
    }
  }

  saveCurrentTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    String formattedTime = _formatDateTime(currentTime);
    prefs.reload();
    prefs.setString('savedTime', formattedTime);
    debugPrint("Save Current Time");
  }

  clockRefresh() async {
    newsecondpassed.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.reload();
      // Use the null-safe check from the second snippet
      newsecondpassed.value = prefs.getInt('secondsPassed') ?? 0;
    });
  }

  String _formatDuration(String secondsString) {
    int seconds = int.parse(secondsString);
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secondsFormatted';
  }

  Future<String> stopTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _timer?.cancel();

    // The second code has a better approach for the final value (though it relies on another ViewModel to set 'totalTime')
    // We'll use the final value from the counter for consistency with the first code's logic, but clean up the logic.
    String totalTime = _formatDuration(newsecondpassed.value.toString());

    await prefs.reload();
    await prefs.setInt('secondsPassed', 0);

    secondsPassed.value = 0;
    newsecondpassed.value = 0; // Reset reactive timer

    await prefs.setString('totalTime', totalTime);
    return totalTime;
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }

  saveClockStatus(bool clockedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setBool('isClockedIn', clockedIn);
    isClockedIn.value = clockedIn;
  }

  // --- GPX and Distance Calculation ---

  Future<double> calculateTotalDistance(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      return 0.0;
    }

    String gpxContent = await file.readAsString();
    if (gpxContent.isEmpty) {
      return 0.0;
    }

    Gpx gpx;
    try {
      gpx = GpxReader().fromString(gpxContent);
    } catch (e) {
      debugPrint("Error parsing GPX content: $e");
      return 0.0;
    }

    double totalDistance = 0.0;
    for (var track in gpx.trks) {
      for (var segment in track.trksegs) {
        for (int i = 0; i < segment.trkpts.length - 1; i++) {
          double distance = calculateDistance(
            segment.trkpts[i].lat?.toDouble() ?? 0.0,
            segment.trkpts[i].lon?.toDouble() ?? 0.0,
            segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
            segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
          );
          totalDistance += distance;
        }
      }
    }

    debugPrint("CUT: $totalDistance");
    return totalDistance;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000); // Distance in kilometers
  }

  /**
   * Calculates the total distance traveled since a specific shift start time.
   * * It reads the GPX file for the current day and only includes points
   * that were recorded after the `shiftStartTime`.
   * * @param shiftStartTime The DateTime object representing the start of the shift.
   * @return The total distance in kilometers recorded during the shift.
   */
  Future<double> calculateShiftDistance(DateTime shiftStartTime) async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      File file = File(gpxFilePath);
      if (!file.existsSync()) return 0.0;

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return 0.0;

      Gpx gpx = GpxReader().fromString(gpxContent);
      double shiftDistance = 0.0;

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          List<Wpt> shiftPoints = [];

          // Filter points to include only those recorded after shiftStartTime
          for (var point in segment.trkpts) {
            if (point.time != null && point.time!.isAfter(shiftStartTime)) {
              shiftPoints.add(point);
            }
          }

          // Calculate distance between sequential points in the filtered list
          for (int i = 0; i < shiftPoints.length - 1; i++) {
            double distance = calculateDistance(
              shiftPoints[i].lat?.toDouble() ?? 0.0,
              shiftPoints[i].lon?.toDouble() ?? 0.0,
              shiftPoints[i + 1].lat?.toDouble() ?? 0.0,
              shiftPoints[i + 1].lon?.toDouble() ?? 0.0,
            );
            shiftDistance += distance;
          }
        }
      }

      debugPrint("📍 Shift Distance: $shiftDistance km");
      return shiftDistance;
    } catch (e) {
      debugPrint("❌ Error calculating shift distance: $e");
      return 0.0;
    }
  }

  saveLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
    final maingpxFile = File(gpxFilePath);

    double totalDistance = await calculateTotalDistance(gpxFilePath);

    await prefs.reload();
    await prefs.setDouble('totalDistance', totalDistance);

    if (!maingpxFile.existsSync()) {
      debugPrint('GPX file does not exist');
      return;
    }
  //   List<int> gpxBytesList = await maingpxFile.readAsBytes();
  //   Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
  //   await _loadCounter();
  //   final orderSerial = generateNewOrderId(user_id);
  //   await addLocation(LocationModel(
  //     location_id: orderSerial.toString(),
  //     user_id: user_id.toString(),
  //     total_distance: totalDistance.toString(),
  //     file_name: "$date.gpx",
  //     booker_name: userName,
  //     body: gpxBytes,
  //   ));
  //   await locationRepository.postDataFromDatabaseToAPI();
  // }


    List<int> gpxBytesList = await maingpxFile.readAsBytes();
    Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);
    await _loadCounter();
    // // Assuming user_id and userName are globally accessible or available in this context
    // const user_id = 'USER_ID_PLACEHOLDER';
    // const userName = 'USER_NAME_PLACEHOLDER';
    final orderSerial = generateNewOrderId(user_id);
    await addLocation(LocationModel(
      location_id: orderSerial.toString(),
      user_id: user_id.toString(),
      total_distance: totalDistance.toString(),
      file_name: "$date.gpx",
      booker_name: userName,
      body: gpxBytes,
    ));
    await locationRepository.postDataFromDatabaseToAPI();
  }

  // --- Permissions and Dialog (Adopted from Code 2) ---

  Future<void> requestPermissions() async {
    // 1. Notification Permission (from Code 1)
    debugPrint('Requesting notification permission...');
    if (await Permission.notification.request().isDenied) {
      debugPrint('Notification permission denied');
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }

    debugPrint('Requesting location permission...');

    // 2. Location Permission Check & Request (Improved logic from Code 2 using Geolocator)
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied or denied forever');
      _showLocationRequiredDialog();
      return;
    }

    // 3. Location Service Status Check (from Code 2)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location service is disabled');
      _showLocationRequiredDialog();
      return;
    }

    // 4. Background Location Permission (from Code 1, using permission_handler)
    if (await Permission.locationAlways.request().isDenied) {
      debugPrint('Background location permission denied');
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }

    debugPrint('All permissions granted');
  }

  void _showLocationRequiredDialog() {
    // Dialog logic from Code 2
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Device location'),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Location Accuracy'),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('TURN ON'),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- Database Operations ---

  Future<void> fetchAllLocation() async {
    var location = await locationRepository.getLocation();
    allLocation.value = location;
  }

  addLocation(LocationModel locationModel) {
    locationRepository.add(locationModel);
    fetchAllLocation();
  }

  void updateLocation(LocationModel locationModel) {
    locationRepository.update(locationModel);
    fetchAllLocation();
  }

  void deleteLocation(String id) {
    locationRepository.delete(id);
    fetchAllLocation();
  }

  serialCounterGet() async {
    await locationRepository.serialNumberGeneratorApi();
  }
}