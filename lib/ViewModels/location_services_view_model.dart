// import 'package:get/get.dart';
// import 'package:order_booking_app/Repositories/location_services_repository.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gpx/gpx.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LocationServicesViewModel extends GetxController {
//   late final LocationServicesRepository locationServicesRepository = Get.put(LocationServicesRepository());
//
//   // String gpxString = "";
// // Timer? _timer;
// //   @override
// //   void onInit() async {
// //     super.onInit();
// //     // Initialize the repository with SharedPreferences
// //     locationServicesRepository = await Get.putAsync(() async {
// //       final prefs = await SharedPreferences.getInstance();
// //       return LocationServicesRepository(prefs);
// //     });
// //   }
//   StreamSubscription<Position>? _positionStream;
//   RxDouble totalDistance = 0.0.obs; // Observable for total distance
//   Position? lastTrackPoint;
//   File? _gpxFile;
//   Gpx gpx = Gpx();
//   Trk track = Trk();
//   Trkseg segment = Trkseg();
//   bool isFirstRun = true;
//
//   // Initialize the service location
//   Future<void> initializeServiceLocation() async {
//     await locationServicesRepository.initializeServiceLocation();
//   }
//
//   // Callback dispatcher for background tasks
//   Future<void> callbackDispatcher() async {
//     await locationServicesRepository.callbackDispatcher();
//   }
//
//   // Start listening to location updates
//   Future<void> startListening() async {
//     _gpxFile = await locationServicesRepository.createOrUpdateGpxFile();
//     if (!_gpxFile!.existsSync()) {
//       isFirstRun = true;
//     } else {
//       final gpxContent = await locationServicesRepository.readGpxFile(_gpxFile!);
//       gpx = GpxReader().fromString(gpxContent);
//       track = gpx.trks[0];
//       segment = Trkseg();
//       track.trksegs.add(segment);
//       isFirstRun = false;
//     }
//
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 9,
//       ),
//     ).listen((Position position) async {
//       final trackPoint = Wpt(
//         lat: position.latitude,
//         lon: position.longitude,
//         time: DateTime.now(),
//       );
//
//       segment.trkpts.add(trackPoint);
//
//       if (isFirstRun) {
//         track.trksegs.add(segment);
//         gpx.trks.add(track);
//         isFirstRun = false;
//       }
//
//       if (lastTrackPoint != null) {
//         // Calculate distance between last and current position
//         final distance = Geolocator.distanceBetween(
//           lastTrackPoint!.latitude,
//           lastTrackPoint!.longitude,
//           position.latitude,
//           position.longitude,
//         );
//         totalDistance.value += distance / 1000; // Convert to kilometers
//       }
//
//       lastTrackPoint = position;
//
//       // Write GPX data to file
//       final gpxString = GpxWriter().asString(gpx, pretty: true);
//       await locationServicesRepository.writeGpxFile(_gpxFile!, gpxString);
//
//       // Save location to Firestore
//       await locationServicesRepository.saveLocationToFirestore(
//         position.latitude,
//         position.longitude,
//       );
//     });
//   }
//
//   // Stop listening to location updates
//   Future<void> stopListening() async {
//     _positionStream?.cancel();
//     await locationServicesRepository.deleteLocationFromFirestore();
//   }  // Stop listening to location updates
//   Future<void>startTimerFromSavedTime () async {
//     _positionStream?.cancel();
//     await locationServicesRepository.startTimerFromSavedTime();
//   }
//
//   // Get total distance from GPX file
//   Future<double> getTotalDistance() async {
//     if (_gpxFile != null) {
//       return await locationServicesRepository.calculateTotalDistance(_gpxFile!.path);
//     }
//     return 0.0;
//   }
//
//   @override
//   void onClose() {
//     _positionStream?.cancel();
//     super.onClose();
//   }
//
// }