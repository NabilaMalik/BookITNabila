class Shop {
  String? name;
  String? address;
  String? ownerName;
  String? ownerCnic;
  String? phoneNumber;
  String? alternativePhoneNumber;
  String? city;
  bool isGpsEnabled;

  Shop({
    this.name,
    this.address,
    this.ownerName,
    this.ownerCnic,
    this.phoneNumber,
    this.alternativePhoneNumber,
    this.city,
    this.isGpsEnabled = false,
  });
}
