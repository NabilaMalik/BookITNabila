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
  DateTime? attendance_in_date;
  DateTime? attendance_in_time;
  int posted;

  AttendanceModel(
      {this.attendance_in_id,


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
      attendance_in_date: DateTime.now(),
      // Always set live date
      attendance_in_time: DateTime.now(),
        posted: json['posted']?? 0
      // Always set live time
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attendance_in_id': attendance_in_id,
      'user_id': user_id,
      'lat_in': lat_in,
      'lng_in': lng_in,
      'booker_name': booker_name,
      'city': city,
      'designation': designation,
      'address': address,
      'attendance_in_date': DateFormat('dd-MMM-yyyy')
          .format(attendance_in_date ?? DateTime.now()), // Always set live date
      'attendance_in_time': DateFormat('HH:mm:ss')
          .format(attendance_in_time ?? DateTime.now()), // Always set live time
      'posted':posted,
    };
  }
}
