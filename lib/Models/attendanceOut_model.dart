import 'package:intl/intl.dart';

class AttendanceOutModel {
  dynamic attendance_out_id;
  String? user_id;
  dynamic total_time;
  dynamic lat_out;
  dynamic lng_out;
  dynamic total_distance;
  dynamic address;
  DateTime? attendance_out_date;
  DateTime? attendance_out_time;
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
        attendance_out_date: DateTime.now(),
        // Always set live date
        attendance_out_time: DateTime.now(),
        // Always set live time
        address: json['address'],
        posted: json['posted']?? 0
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'attendance_out_id': attendance_out_id,
      'user_id': user_id,
      'total_time':total_time,
      'lat_out': lat_out,
      'lng_out':lng_out,
      'total_distance': total_distance,
      'attendance_out_date': DateFormat('dd-MMM-yyyy').format(attendance_out_date ?? DateTime.now()), // Always set live date
      'attendance_out_time': DateFormat('HH:mm:ss').format(attendance_out_time ?? DateTime.now()), // Always set live time
      'address': address,
      'posted':posted,
    };
  }
}