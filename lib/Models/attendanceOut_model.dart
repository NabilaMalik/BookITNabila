class AttendanceOutModel {
  dynamic id;
  String? date;
  String? time_out;
  String? userId;
  dynamic total_time;
  dynamic latOut;
  dynamic lngOut;
  dynamic total_distance;
  dynamic address;

  AttendanceOutModel({
    this.id,
    this.date,
    this.time_out,
    this.userId,
    this.total_time,
    this.latOut,
    this.lngOut,
    this.total_distance,
    this.address
  });
  factory AttendanceOutModel.fromMap(Map<dynamic, dynamic> json) {
    return AttendanceOutModel(
        id: json['id'],
        date : json['date'],
        time_out: json['time_out'],
        userId: json['userId'],
        total_time: json['total_time'],
        latOut: json['latOut'],
        lngOut:json['lngOut'],
        total_distance: json['total_distance'],
        address: json['address']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time_out': time_out,
      'userId': userId,
      'total_time':total_time,
      'latOut': latOut,
      'lngOut':lngOut,
      'total_distance': total_distance,
      'address': address
    };
  }
}