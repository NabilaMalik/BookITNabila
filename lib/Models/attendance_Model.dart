class AttendanceModel{
  dynamic id;
  String? date;
  String? timeIn;
  String? userId;
  dynamic latIn;
  dynamic lngIn;
  dynamic bookerName;
  dynamic designation;
  dynamic city;
  dynamic address;

  AttendanceModel({
    this.id,
    this.date,
    this.timeIn,
    this.userId,
    this.latIn,
    this.lngIn,
    this.bookerName,
    this.city,
    this.designation,
    this.address
  });

  factory AttendanceModel.fromMap(Map<dynamic, dynamic> json) {

    return AttendanceModel(
      id: json['id'],
      date : json['date'],
      timeIn: json['timeIn'],
      userId: json['userId'],
      latIn: json['latIn'],
      lngIn: json['lngIn'],
      bookerName: json['bookerName'],
      city: json['city'],
      designation: json['designation'],
      address: json['address'],


    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'timeIn': timeIn,
      'userId': userId,
      'latIn': latIn,
      'lngIn': lngIn,
      'bookerName': bookerName,
      'city':city,
      'designation':designation,
      'address':address

    };
  }
}

