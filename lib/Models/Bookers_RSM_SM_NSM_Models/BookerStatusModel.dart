import 'package:flutter/cupertino.dart';

class BookerStatusModel {
  final String booker_id;
  final String name;
  final String designation;
  final String attendanceStatus;
  final String city;

  BookerStatusModel({
    required this.booker_id,
    required this.name,
    required this.designation,
    required this.attendanceStatus,
    required this.city,
  });

  factory BookerStatusModel.fromJson(Map<String, dynamic> json) {
    debugPrint("Bookerrrrrr JSON: $json");
    return BookerStatusModel(
      booker_id: (json['user_id'] ?? json['UserId'] ?? json['id'] ?? '').toString(),
      name: (json['user_name'] ?? json['UserName'] ?? json['name'] ?? '').toString(),
      designation: (json['designation'] ?? json['Designation'] ?? '').toString(),
      attendanceStatus: (json['status'] ?? json['Status'] ?? '').toString(),
      city: json['city'] is Map
          ? (json['city']['city'] ?? '').toString()
          : (json['city'] ?? '').toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'user_id': booker_id,
      'user_name': name,
      'designation': designation,
      'status': attendanceStatus,
      'city': city,
    };
  }
}


//
// import 'package:flutter/cupertino.dart';
//
// class BookerStatusModel {
//
//   final dynamic booker_id;
//   final dynamic name;
//   final dynamic designation;
//   final dynamic attendanceStatus;
//   final dynamic city;
//
//   BookerStatusModel({
//     required this.booker_id,
//     required this.name,
//     required this.designation,
//     required this.attendanceStatus,
//     required this.city,
//   });
//
//   factory BookerStatusModel.fromJson(Map<dynamic, dynamic> json) {
//     debugPrint("Bookerrrrrrrrrrrrrrrrrrrr JSON: $json");
//     return BookerStatusModel(
//       booker_id: json['user_id'],
//       name: json['user_name'],
//       designation: json['designation'],
//       attendanceStatus: json['status'],
//       city: json['city'],
//     );
//   }
//
//   Map<dynamic, dynamic> toJson() {
//     return {
//       'user_id':booker_id,
//       'user_name': name,
//       'designation': designation,
//       'status': attendanceStatus,
//       'city': city,
//     };
//   }
// }
