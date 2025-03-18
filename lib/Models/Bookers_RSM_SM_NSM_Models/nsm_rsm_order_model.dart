class NsmRsmOrderModel {

  final dynamic booker_id;
  final dynamic name;
  final dynamic designation;


  NsmRsmOrderModel({
    required this.booker_id,
    required this.name,
    required this.designation,
  });


  factory NsmRsmOrderModel.fromJson(Map<dynamic, dynamic> json) {
    return NsmRsmOrderModel(
      booker_id: json['rsm_id']??"",
      name: json['rsm']??"",
      designation: json['order_count']??"",
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'rsm_id': booker_id,
      'rsm': name,
      'order_count': designation,

    };
  }
}
