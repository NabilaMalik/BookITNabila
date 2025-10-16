// import 'package:intl/intl.dart';
//
// class AttendanceOutModel {
//   dynamic attendance_out_id;
//   String? user_id;
//   dynamic total_time;
//   dynamic lat_out;
//   dynamic lng_out;
//   dynamic total_distance;
//   dynamic address;
//   DateTime? attendance_out_date;
//   DateTime? attendance_out_time;
//   int posted;
//
//   AttendanceOutModel({
//     this.attendance_out_id,
//     this.user_id,
//     this.total_time,
//     this.lat_out,
//     this.lng_out,
//     this.total_distance,
//     this.attendance_out_date,
//     this.attendance_out_time,
//     this.address,
//     this.posted = 0
//
//   });
//   factory AttendanceOutModel.fromMap(Map<dynamic, dynamic> json) {
//
//     // --- NEW LOGIC: Safely parse stored date/time strings from DB ---
//     DateTime? parsedDate;
//     DateTime? parsedTime;
//
//     // ... (Add similar parsing logic here as in AttendanceModel.fromMap)
//
//     // --- END NEW LOGIC ---
//
//     return AttendanceOutModel(
//         attendance_out_id: json['attendance_out_id'],
//         user_id: json['user_id'],
//         total_time: json['total_time'],
//         lat_out: json['lat_out'],
//         lng_out:json['lng_out'],
//         total_distance: json['total_distance'],
//
//         // FIX: **REMOVE THESE TWO LINES** which overwrite the original offline time
//         // attendance_out_date: DateTime.now(), // ❌ REMOVE THIS line
//         // attendance_out_time: DateTime.now(), // ❌ REMOVE THIS line
//
//         attendance_out_date: parsedDate, // Placeholder: You need correct DB parsing logic here
//         attendance_out_time: parsedTime, // Placeholder: You need correct DB parsing logic here
//
//         address: json['address'],
//         posted: json['posted']?? 0
//     );
//   }
//
// // Ensure toMap() is correct (it is mostly correct, but let's confirm it uses the object's data)
//   Map<String, dynamic> toMap() {
//     // This is correct as it uses the object's stored date/time first.
//     return {
//       'attendance_out_id': attendance_out_id,
//       // ... (other fields)
//       'attendance_out_date': DateFormat('dd-MMM-yyyy').format(attendance_out_date ?? DateTime.now()), // Uses stored date
//       'attendance_out_time': DateFormat('HH:mm:ss').format(attendance_out_time ?? DateTime.now()), // Uses stored time
//       'address': address,
//       'posted':posted,
//     };
//   }
//
//
import 'package:intl/intl.dart';

class AttendanceOutModel {
  dynamic attendance_out_id;
  String? user_id;
  dynamic total_time;
  dynamic lat_out;
  dynamic lng_out;
  dynamic total_distance;
  dynamic address;
  // FIX 1: Change to dynamic to safely hold stored strings from DB
  dynamic attendance_out_date;
  dynamic attendance_out_time;
  int posted;

  AttendanceOutModel({
    this.attendance_out_id,
    this.user_id,
    this.total_time,
    this.lat_out,
    this.lng_out,
    this.total_distance,
    this.attendance_out_date,
    this.attendance_out_time,
    this.address,
    this.posted = 0
  });

  factory AttendanceOutModel.fromMap(Map<dynamic, dynamic> json) {
    return AttendanceOutModel(
        attendance_out_id: json['attendance_out_id'],
        user_id: json['user_id'],
        total_time: json['total_time'],
        lat_out: json['lat_out'],
        lng_out:json['lng_out'],
        total_distance: json['total_distance'],

        // FIX 2: Load the actual stored date/time strings from the database map (json)
        attendance_out_date: json['attendance_out_date'],
        attendance_out_time: json['attendance_out_time'],

        address: json['address'],
        posted: json['posted']?? 0
    );
  }

  Map<String, dynamic> toMap() {
    // Determine the date string for the API call
    String dateString;
    if (attendance_out_date is DateTime) {
      // For new records, format the DateTime object
      dateString = DateFormat('dd-MMM-yyyy').format(attendance_out_date);
    } else if (attendance_out_date is String) {
      // For offline records, use the stored string
      dateString = attendance_out_date;
    } else {
      // Fallback
      dateString = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    }

    // Determine the time string for the API call
    String timeString;
    if (attendance_out_time is DateTime) {
      // For new records, format the DateTime object
      timeString = DateFormat('HH:mm:ss').format(attendance_out_time);
    } else if (attendance_out_time is String) {
      // For offline records, use the stored string
      timeString = attendance_out_time;
    } else {
      // Fallback
      timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    }

    return {
      'attendance_out_id': attendance_out_id,
      'user_id': user_id,
      'total_time':total_time,
      'lat_out': lat_out,
      'lng_out':lng_out,
      'total_distance': total_distance,
      // FIX 3: Use the determined offline/online time strings
      'attendance_out_date': dateString,
      'attendance_out_time': timeString,
      'address': address,
      'posted':posted,
    };
  }
}
