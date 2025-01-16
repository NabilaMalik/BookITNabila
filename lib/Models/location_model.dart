
import 'dart:convert';
import 'dart:typed_data';

class LocationModel {
  dynamic? id;
  String? date;
  String? fileName;
  String? userId;
  Uint8List? body;
  dynamic? bokker_name;
  dynamic? total_distance;


  LocationModel({
    this.id,
    this.date,
    this.fileName,
    this.userId,
    this.body,
    this.bokker_name,
    this.total_distance
  });

  factory LocationModel.fromMap(Map<dynamic, dynamic> json) {

    return LocationModel(
      id: json['id'],
      date : json['date'],
      fileName: json['fileName'],
      userId: json['userId'],
      bokker_name: json['bokker_name'],
      total_distance: json['total_distance'],
      body: json['body'] != null && json['body'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['body'].toString()))
          : null,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'fileName': fileName,
      'userId': userId,
      'bokker_name':bokker_name,
      'total_distance': total_distance,
      'body':  body != null ? base64Encode(body!) : null,
    };
  }
}