class AttendanceModel{
  dynamic id;
  String? date;
  String? time_in;
  String? userId;
  dynamic latIn;
  dynamic lngIn;
  dynamic booker_name;
  dynamic designation;
  dynamic city;
  dynamic address;

  AttendanceModel({
    this.id,
    this.date,
    this.time_in,
    this.userId,
    this.latIn,
    this.lngIn,
    this.booker_name,
    this.city,
    this.designation,
    this.address
  });

  factory AttendanceModel.fromMap(Map<dynamic, dynamic> json) {

    return AttendanceModel(
      id: json['id'],
      date : json['date'],
      time_in: json['time_in'],
      userId: json['userId'],
      latIn: json['latIn'],
      lngIn: json['lngIn'],
      booker_name: json['booker_name'],
      city: json['city'],
      designation: json['designation'],
      address: json['address'],


    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time_in': time_in,
      'userId': userId,
      'latIn': latIn,
      'lngIn': lngIn,
      'booker_name': booker_name,
      'city':city,
      'designation':designation,
      'address':address

    };
  }
}

