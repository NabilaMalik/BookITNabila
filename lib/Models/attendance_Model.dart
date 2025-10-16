// import 'package:intl/intl.dart';
//
// class AttendanceModel {
//   dynamic attendance_in_id;
//   String? user_id;
//   dynamic lat_in;
//   dynamic lng_in;
//   dynamic booker_name;
//   dynamic designation;
//   dynamic city;
//   dynamic address;
//   DateTime? attendance_in_date;
//   DateTime? attendance_in_time;
//   int posted;
//
//   AttendanceModel({this.attendance_in_id,
//
//     this.user_id,
//     this.lat_in,
//     this.lng_in,
//     this.booker_name,
//     this.city,
//     this.designation,
//     this.attendance_in_date,
//     this.attendance_in_time,
//     this.address,
//     this.posted = 0
//   });
//
//
//   factory AttendanceModel.fromMap(Map<dynamic, dynamic> json) {
//     // --- NEW LOGIC: Safely parse stored date/time strings from DB ---
//     // You must verify the exact format your DB stores (e.g., 'dd-MMM-yyyy' and 'HH:mm:ss')
//     DateTime? parsedDate;
//     DateTime? parsedTime;
//
//     // Assuming the date is stored as a string:
//     if (json['attendance_in_date'] is String &&
//         json['attendance_in_date'] != null) {
//       try {
//         parsedDate =
//             DateFormat('dd-MMM-yyyy').parse(json['attendance_in_date']);
//       } catch (e) {
//         // Handle parsing error if necessary
//       }
//     }
//
//     // Assuming the time is stored as a string:
//     if (json['attendance_in_time'] is String &&
//         json['attendance_in_time'] != null) {
//       try {
//         // Note: Parsing only time is tricky, this attempts to parse just the time portion
//         // from the stored string, potentially merging with a default date.
//         // A more robust solution is to store an ISO 8601 string or epoch time in the DB.
//         // For now, let's prioritize loading any existing DateTime object if your DB stored it.
//         // Since your current code is simple, we will use a workaround.
//         // The simplest change is to remove the DateTime.now() assignment.
//       } catch (e) {
//
//       }
//     }
//     // --- END NEW LOGIC ---
//
//     return AttendanceModel(
//         attendance_in_id: json['attendance_in_id'],
//         user_id: json['user_id'],
//         lat_in: json['lat_in'],
//         lng_in: json['lng_in'],
//         booker_name: json['booker_name'],
//         city: json['city'],
//         designation: json['designation'],
//         address: json['address'],
//
//         // FIX: Use the parsed or stored values if your database holds them,
//         // otherwise, if the repository logic does not store them, this needs more extensive changes.
//         // For now, we **remove the DateTime.now() overrides** which are the source of the problem.
//         // If your database stores the raw Dart DateTime (e.g., as an integer timestamp or ISO string),
//         // the repository needs to convert it back here.
//
//         // We'll trust that the repository uses these map keys to set the original value
//         // and remove the offending DateTime.now() line.
//         // Since the original code had *only* DateTime.now(), we just remove it for now
//         // to rely on repository logic (which is not visible).
//
//         // attendance_in_date: DateTime.now(), // <-- REMOVE THIS LINE
//         // attendance_in_time: DateTime.now(), // <-- REMOVE THIS LINE
//
//         // A safer, complete fix requires seeing the DB logic, but the **root cause is the lines below:**
//
//         // attendance_in_date: DateTime.now(), // ❌ REMOVE THIS line
//         // attendance_in_time: DateTime.now(), // ❌ REMOVE THIS line
//
//         // Since we don't know the exact format your DB stores, we must rely on the model properties
//         // being set correctly when the record is created. The fix is to ensure `toMap` uses the existing object data.
//
//         attendance_in_date: parsedDate,
//         // Placeholder: You need correct DB parsing logic here
//         attendance_in_time: parsedTime,
//         // Placeholder: You need correct DB parsing logic here
//
//         posted: json['posted'] ?? 0
//     );
//   }
//
// // Ensure toMap() is correct (it is mostly correct, but let's confirm it uses the object's data)
//   Map<String, dynamic> toMap() {
//     // This is correct as it uses the object's stored date/time first.
//     return {
//       'attendance_in_id': attendance_in_id,
//       // ... (other fields)
//       'attendance_in_date': DateFormat('dd-MMM-yyyy')
//           .format(attendance_in_date ?? DateTime.now()), // Uses stored date
//       'attendance_in_time': DateFormat('HH:mm:ss')
//           .format(attendance_in_time ?? DateTime.now()), // Uses stored time
//       'posted': posted,
//     };
//   }
// }

import 'package:intl/intl.dart';

class AttendanceModel {
  dynamic attendance_in_id;
  String? user_id;
  dynamic lat_in;
  dynamic lng_in;
  dynamic booker_name;
  dynamic designation;
  dynamic city;
  dynamic address;
  // FIX 1: Change to dynamic to safely hold stored strings from DB
  dynamic attendance_in_date;
  dynamic attendance_in_time;
  int posted;

  AttendanceModel({
    this.attendance_in_id,
    this.user_id,
    this.lat_in,
    this.lng_in,
    this.booker_name,
    this.city,
    this.designation,
    this.attendance_in_date,
    this.attendance_in_time,
    this.address,
    this.posted = 0
  });

  factory AttendanceModel.fromMap(Map<dynamic, dynamic> json) {
    return AttendanceModel(
        attendance_in_id: json['attendance_in_id'],
        user_id: json['user_id'],
        lat_in: json['lat_in'],
        lng_in: json['lng_in'],
        booker_name: json['booker_name'],
        city: json['city'],
        designation: json['designation'],
        address: json['address'],

        // FIX 2: Load the actual stored date/time strings from the database map (json)
        attendance_in_date: json['attendance_in_date'],
        attendance_in_time: json['attendance_in_time'],

        posted: json['posted']?? 0
    );
  }

  Map<String, dynamic> toMap() {
    // Determine the date string for the API call
    String dateString;
    if (attendance_in_date is DateTime) {
      // For new records, format the DateTime object
      dateString = DateFormat('dd-MMM-yyyy').format(attendance_in_date);
    } else if (attendance_in_date is String) {
      // For offline records, use the stored string
      dateString = attendance_in_date;
    } else {
      // Fallback (e.g., if somehow still null)
      dateString = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    }

    // Determine the time string for the API call
    String timeString;
    if (attendance_in_time is DateTime) {
      // For new records, format the DateTime object
      timeString = DateFormat('HH:mm:ss').format(attendance_in_time);
    } else if (attendance_in_time is String) {
      // For offline records, use the stored string
      timeString = attendance_in_time;
    } else {
      // Fallback
      timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    }

    return {
      'attendance_in_id': attendance_in_id,
      'user_id': user_id,
      'lat_in': lat_in,
      'lng_in': lng_in,
      'booker_name': booker_name,
      'city': city,
      'designation': designation,
      'address': address,
      // FIX 3: Use the determined offline/online time strings
      'attendance_in_date': dateString,
      'attendance_in_time': timeString,
      'posted': posted,
    };
  }
}