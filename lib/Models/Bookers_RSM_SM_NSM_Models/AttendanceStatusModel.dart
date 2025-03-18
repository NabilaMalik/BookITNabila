class AttendanceStatusModel {
  final dynamic date;
  final dynamic timeIn;
  final dynamic timeOut;
  final dynamic totalTime;
  final dynamic totalDistance;

  AttendanceStatusModel({
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.totalTime,
    required this.totalDistance,
  });

  factory AttendanceStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return AttendanceStatusModel(
      date: json['attendance_in_date'],
      timeIn: json['attendance_in_time'],
      timeOut: json['attendance_out_time'],
      totalTime: json['total_time'],
      totalDistance: json['total_distance'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'attendance_in_date':date,
      'attendance_in_time': timeIn,
      'attendance_out_time': timeOut,
      'total_time': totalTime,
      'total_distance': totalDistance,
    };
  }
}

