import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/shop_visit_screen.dart';

class ShopVisitViewModel extends GetxController {
  final ImagePicker picker = ImagePicker();

  var shopAddress = ''.obs;
  var ownerName = ''.obs;
  var bookerName = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var selectedImage = Rx<XFile?>(null);
  var filteredRows = <Map<String, dynamic>>[].obs;

  var checklistState = List<bool>.filled(4, false).obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
  ValueNotifier<List<Map<String, dynamic>>>([]);
  final List<String> brands = ['Brand A', 'Brand B', 'Brand C'];
  final List<String> shops = ['Shop X', 'Shop Y', 'Shop Z'];
  final List<String> checklistLabels = [
    'Performed Store Walkthrough',
    'Updated Store Planogram',
    'Checked Shelf Tags and Price Signage',
    'Reviewed Expiry Dates on Products',
  ];
  @override
  void onInit() {
    super.onInit();
    _initializeProductData();
  }
  void _initializeProductData() {
    final productData = [
      {'Product': 'Shampoo', 'Quantity': 20},
      {'Product': 'Soap',  'Quantity': 35},
      {'Product': 'Cookies',  'Quantity': 50},
      {'Product': 'Milk',  'Quantity': 15},
      {'Product': 'Shampoo', 'Quantity': 20},
      {'Product': 'Soap', 'Quantity': 35},
      {'Product': 'Cookies','Quantity': 50},
      {'Product': 'Milk', 'Quantity': 15},
    ];

    rowsNotifier.value = productData;
    filteredRows.value = productData;

    print("Initialized Product Data: $productData");
  }

  // void updateRows(List<DataRow> newRows) {
  //   rowsNotifier.value = newRows;
  // }

  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final tempList = rowsNotifier.value.where((row) {
      return row.values.any((value) =>
          value.toString().toLowerCase().contains(lowerCaseQuery));
    }).toList();
    filteredRows.value = tempList;
  }


  Future<void> pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    selectedImage.value = image;
  }
   Future<void> takePicture() async{
    final image = await picker.pickImage(source: ImageSource.camera);
    selectedImage.value = image;
   }

  void submitForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      rowsNotifier.value = filteredRows.value;

      Get.snackbar("Success", "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}