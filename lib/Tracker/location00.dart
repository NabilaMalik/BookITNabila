
import 'dart:async' show Future, StreamSubscription;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  //late LocationManager locationManager;
  late Gpx gpx;
  late Trk track;
  late Trkseg segment;
  late File file;
  late bool isFirstRun;
  late bool isConnected;
  late var lat, longi;
  //late StreamSubscription<LocationDto> locationSubscription;
  late String userIdForLocation;
  late String userCityForLocatiion;
  late String userDesignationForLocation;

  late String userNameForLocation;
  late String rsmIdForLocation;
  late String nsmIdForLocation;
  late String smIdForLocation;
  late final filepath;
  late final Directory? downloadDirectory;
  late double totalDistance;
  late Position? lastTrackPoint;
  String gpxString = "";

  LocationService() {
    totalDistance = 0.0;
    lastTrackPoint = null;
    init();
    Firebase.initializeApp();
    lat = 0.0;
    longi = 0.0;
    isConnected =false;
  }

  StreamSubscription<Position>? positionStream;
  LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 9,
    forceLocationManager: true,
    // intervalDuration: const Duration(seconds:1 ),
  );

  Future<void> listenLocation() async {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
          if (kDebugMode) {
            print("W100 Repeat");
          }

          longi = position.longitude.toString();
          lat = position.latitude.toString();
          final trackPoint = Wpt(
            lat: position.latitude,
            lon: position.longitude,
            time: DateTime.now(),
          );

          segment.trkpts.add(trackPoint);

          if (isFirstRun) {
            track.trksegs.add(segment);
            gpx.trks.add(track);
            isFirstRun = false;
          }

          if (lastTrackPoint != null) {
            totalDistance += calculateDistance(
              lastTrackPoint!.latitude,
              lastTrackPoint!.longitude,
              position.latitude,
              position.longitude,
            );
          }

          lastTrackPoint = Position(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
            timestamp: DateTime.now(),
          );
          gpxString = GpxWriter().asString(gpx, pretty: true);
          if (kDebugMode) {
            print("W100 $gpxString");
          }
          file.writeAsStringSync(gpxString);

           isConnected = await isNetworkAvailableForFirebase();
           // isConnected = await isNetworkAvailable();
          if (isConnected) {
            debugPrint("FIrebaseeeeeeeeeeeeeeeeeeee");
            await FirebaseFirestore.instance
                .collection('location')
                .doc(userIdForLocation.toString())
                .set({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'name': userNameForLocation.toString(),
              'userId': userIdForLocation.toString(),
              'city': userCityForLocatiion.toString(),
              'designation': userDesignationForLocation.toString(),
              'RSM_ID': rsmIdForLocation.toString(),
              'NSM_ID':nsmIdForLocation.toString(),
              'SM_ID':smIdForLocation.toString() ,
              'isActive': true
            }, SetOptions(merge: true));
            debugPrint("FIrebaseeingggggggggggggggggggg");
          }
        });

    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.reload();
    userNameForLocation = pref.getString("userName") ?? "USERName";
    userIdForLocation = pref.getString("userId") ?? "USERId";
    nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
    rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
    smIdForLocation = pref.getString("userSM") ?? "smUSER";
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
    debugPrint('User ID: $userIdForLocation');
    debugPrint('User Name: $userNameForLocation');
    debugPrint('User City: $userCityForLocatiion');
    debugPrint('User Designation: $userDesignationForLocation');
    debugPrint('User RSM ID: $rsmIdForLocation');
    debugPrint('User NSM ID: $nsmIdForLocation');
    debugPrint('User SM ID: $smIdForLocation');

    try {
      gpx = Gpx();
      track = Trk();
      segment = Trkseg();
      if (kDebugMode) {
        print("W100 Start");
      }
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final downloadDirectory = await getDownloadsDirectory();
      final filePath = "${downloadDirectory!.path}/track$date.gpx";

      file = File(filePath);
      isFirstRun = !file.existsSync();
      if (!file.existsSync()) {
        file.createSync();
      } else {
        Gpx existingGpx = GpxReader().fromString(file.readAsStringSync());
        gpx.trks.add(existingGpx.trks[0]);
        track = gpx.trks[0];
        segment = Trkseg();
        track.trksegs.add(segment);
      }

      if (kDebugMode) {
        print("W100 END");
      }
    } catch (e) {
      if (kDebugMode) {
        print('W100 An error occurred: $e');
      }
    }
  }

  Future<void> init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.reload();
    userNameForLocation = pref.getString("userName") ?? "USERName";
    userIdForLocation = pref.getString("userId") ?? "USERId";
    nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
    rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
    smIdForLocation = pref.getString("userSM") ?? "smUSER";
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
  }
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters =
    Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000); // Multiply the result by 2
  }

  // Future<void> deleteDocument() async {
  //   await FirebaseFirestore.instance
  //       .collection('location')
  //       .doc(userIdForLocation)
  //       .delete()
  //       .then(
  //         (doc) => print("Document deleted"),
  //     onError: (e) => print("Error updating document $e"),
  //   );
  // }

  Future<void> deleteDocument() async {
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(userIdForLocation)
          .delete();

      if (kDebugMode) {
        print("Document deleted");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting document $e");
      }
    }
  }

  Future<void> stopListening() async {
    try {
      //WakelockPlus.disable();
      positionStream?.cancel();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setDouble("TotalDistance", totalDistance);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR ${e.toString()}");
      }
    }
  }
}
// Future<double> calculateTotalDistance(String filePath) async {
//   File file = File(filePath);
//   if (!file.existsSync()) {
//     return 0.0;
//   }
//
//   // Read GPX content from file
//   String gpxContent = await file.readAsString();
//
//   // Parse GPX content
//   Gpx gpx = GpxReader().fromString(gpxContent);
//
//   // Calculate total distance
//   double totalDistance = 0.0;
//
//   // Iterate through each track segment
//   for (var track in gpx.trks) {
//     for (var segment in track.trksegs) {
//       for (int i = 0; i < segment.trkpts.length - 1; i++) {
//         double distance = calculateDistance(
//           segment.trkpts[i].lat!.toDouble(),
//           segment.trkpts[i].lon!.toDouble(),
//           segment.trkpts[i + 1].lat!.toDouble(),
//           segment.trkpts[i + 1].lon!.toDouble(),
//         );
//         totalDistance += distance;
//       }
//     }
//   }
//
//   if (kDebugMode) {
//     print("CUT: $totalDistance");
//   }
//
//   // Ensure totalDistance is not zero
//   return totalDistance != 0.0 ? totalDistance : 0.0;
// }
Future<double> calculateTotalDistance(String filePath) async {
  File file = File(filePath);
  if (!file.existsSync()) {
    return 0.0;
  }

  // Read GPX content from file
  String gpxContent = await file.readAsString();
  if (gpxContent.isEmpty) {
    return 0.0;
  }

  // Parse GPX content
  Gpx gpx;
  try {
    gpx = GpxReader().fromString(gpxContent);
  } catch (e) {
    if (kDebugMode) {
      print("Error parsing GPX content: $e");
    }
    return 0.0;
  }

  // Calculate total distance
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

  if (kDebugMode) {
    print("CUT: $totalDistance");
  }

  return totalDistance;
}
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  return (distanceInMeters / 1000); // Multiply the result by 2
}

// Future<bool> isInternetConnected() async {
//   bool isConnected = await InternetConnectionChecker().hasConnection;
//   if (kDebugMode) {
//     print('Internet Connected: $isConnected');
//   }
//   return isConnected;
// }