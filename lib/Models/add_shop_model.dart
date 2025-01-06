class AddShopModel {
  int? id;
  String? shopName;
  String? city;
  String? shopAddress;
  String? ownerName;
  String? ownerCNIC;
  String? phoneNumber;
  String? alterPhoneNumber;
  bool isGPSEnabled;

  AddShopModel({
    this.id,
    this.shopName,
    this.city,
    this.shopAddress,
    this.ownerName,
    this.ownerCNIC,
    this.phoneNumber,
    this.alterPhoneNumber,
    this.isGPSEnabled = false,
  });

  factory AddShopModel.fromMap(Map<dynamic, dynamic> json) {
    return AddShopModel(
      id: json['id'],
      shopName: json['shopName'],
      city: json['city'],
      shopAddress: json['shopAddress'],
      ownerName: json['ownerName'],
      ownerCNIC: json['ownerCNIC'],
      phoneNumber: json['phoneNumber'],
      alterPhoneNumber: json['alterPhoneNumber'],
      // isGPSEnabled: json['isGPSEnabled'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'city': city,
      'shopAddress': shopAddress,
      'ownerName': ownerName,
      'ownerCNIC': ownerCNIC,
      'phoneNumber': phoneNumber,
      'alterPhoneNumber': alterPhoneNumber,
      // 'isGPSEnabled': isGPSEnabled == true ? 1 : 0,
    };
  }
}
