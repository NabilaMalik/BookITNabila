class NsmBookersOrderModel {

  final dynamic booker_id;
  final dynamic name;
  final dynamic designation;


  NsmBookersOrderModel({
    required this.booker_id,
    required this.name,
    required this.designation,
  });


  factory NsmBookersOrderModel.fromJson(Map<dynamic, dynamic> json) {
    return NsmBookersOrderModel(
      booker_id: json['user_id']??"",
      name: json['user_name']??"",
      designation: json['order_count']??"",
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'user_id': booker_id,
      'user_name': name,
      'order_count': designation,

    };
  }
}
