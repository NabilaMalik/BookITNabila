class NsmSmOrderModel {

  final dynamic booker_id;
  final dynamic name;
  final dynamic designation;


  NsmSmOrderModel({
    required this.booker_id,
    required this.name,
    required this.designation,
  });


  factory NsmSmOrderModel.fromJson(Map<dynamic, dynamic> json) {
    return NsmSmOrderModel(
      booker_id: json['sm_id']??"",
      name: json['sm']??"",
      designation: json['order_count']??"",
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'sm_id': booker_id,
      'sm': name,
      'order_count': designation,

    };
  }
}
