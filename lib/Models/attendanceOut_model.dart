class AttendanceOutModel {
  dynamic id;
  String? date;
  String? timeOut;
  String? userId;
  dynamic totalTime;
  dynamic latOut;
  dynamic lngOut;
  dynamic totalDistance;
  dynamic address;

  AttendanceOutModel({
    this.id,
    this.date,
    this.timeOut,
    this.userId,
    this.totalTime,
    this.latOut,
    this.lngOut,
    this.totalDistance,
    this.address
  });
  factory AttendanceOutModel.fromMap(Map<dynamic, dynamic> json) {
    return AttendanceOutModel(
        id: json['id'],
        date : json['date'],
        timeOut: json['timeOut'],
        userId: json['userId'],
        totalTime: json['totalTime'],
        latOut: json['latOut'],
        lngOut:json['lngOut'],
        totalDistance: json['totalDistance'],
        address: json['address']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'timeOut': timeOut,
      'userId': userId,
      'totalTime':totalTime,
      'latOut': latOut,
      'lngOut':lngOut,
      'totalDistance': totalDistance,
      'address': address
    };
  }
}