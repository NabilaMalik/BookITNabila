import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShopVisitScreenModel {
  String brand;
  String shop;
  String shopAddress;
  String ownerName;
  String bookerName;
  XFile? selectedImage;
  List<DataRow> filteredRows;
  List<bool> checklistState;

  ShopVisitScreenModel({
    required this.brand,
    required this.shop,
    required this.shopAddress,
    required this.ownerName,
    required this.bookerName,
    this.selectedImage,
    required this.filteredRows,
    required this.checklistState,
  });
}
