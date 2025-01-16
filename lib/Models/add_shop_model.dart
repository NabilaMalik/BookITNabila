class AddShopModel {
  String? shopId;
  String? shopName;
  String? city;
  String? shopAddress;
  String? ownerName;
  String? ownerCNIC;
  String? phoneNumber;
  String? alterPhoneNumber;
  bool isGPSEnabled;
  int posted;

  AddShopModel({
    this.shopId,
    this.shopName,
    this.city,
    this.shopAddress,
    this.ownerName,
    this.ownerCNIC,
    this.phoneNumber,
    this.alterPhoneNumber,
    this.isGPSEnabled = false,
    this.posted =0,
  });

  factory AddShopModel.fromMap(Map<dynamic, dynamic> json) {
    return AddShopModel(
      shopId: json['shopId'],
      shopName: json['shopName'],
      city: json['city'],
      shopAddress: json['shopAddress'],
      ownerName: json['ownerName'],
      ownerCNIC: json['ownerCNIC'],
      phoneNumber: json['phoneNumber'],
      alterPhoneNumber: json['alterPhoneNumber'],
      // isGPSEnabled: json['isGPSEnabled'] == 1,
      posted:  json['posted']??0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'city': city,
      'shopAddress': shopAddress,
      'ownerName': ownerName,
      'ownerCNIC': ownerCNIC,
      'phoneNumber': phoneNumber,
      'alterPhoneNumber': alterPhoneNumber,
      'posted': posted
      // 'isGPSEnabled': isGPSEnabled == true ? 1 : 0,
    };
  }
}
