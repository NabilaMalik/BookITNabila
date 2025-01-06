
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/shop_visit_model.dart';
import '../Repositories/shop_visit_repository.dart';
class ShopVisitViewModel extends GetxController{

  var allShopVisit = <ShopVisitModel>[].obs;
  ShopVisitRepository shopvisitRepository = ShopVisitRepository();
  final _shopVisit = ShopVisitModel().obs;
  final ImagePicker picker = ImagePicker();
  ShopVisitModel get shopVisit => _shopVisit.value;

  GlobalKey<FormState> get formKey => _formKey;
  final _formKey = GlobalKey<FormState>();

  var shopAddress = ''.obs;
  var ownerName = ''.obs;
  var bookerName = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var selectedImage = Rx<XFile?>(null);
  var filteredRows = <Map<String, dynamic>>[].obs;
  var checklistState = List<bool>.filled(4, false).obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
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
  // Clear filters
  clearFilters() {
    _shopVisit.value = ShopVisitModel();
   //selectedCity.value = ''; // Reset selected city
    _formKey.currentState?.reset();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void saveForm() async {
    if (validateForm()) {
      print("saveeeeeeeeeeeeeeeeee");
     await addShopVisit(ShopVisitModel(
       shopName: selectedShop.value,
       shopAddress: shopAddress.value,
       shopOwner: ownerName.value,
       brand: selectedBrand.value,
      // addPhoto: selectedImage.value

     ));
      await shopvisitRepository.getShopVisit();
      // Navigate to another screen if needed
      // Get.to(() => HomeScreen());
    }
  }

  Future<void> submitForm() async {
    if (validateForm()) {
      await shopvisitRepository.add(shopVisit);
      await shopvisitRepository.getShopVisit();
      rowsNotifier.value = filteredRows.value;
      Get.snackbar("Success", "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  fetchAllShopVisit() async{
    var shopvisit = await shopvisitRepository.getShopVisit();
    allShopVisit.value = shopvisit;
  }

  addShopVisit(ShopVisitModel shopvisitModel){
    shopvisitRepository.add(shopvisitModel);
    fetchAllShopVisit();
  }

  updateShopVisit(ShopVisitModel shopvisitModel){
    shopvisitRepository.update(shopvisitModel);
    fetchAllShopVisit();
  }

  deleteShopVisit(int id){
    shopvisitRepository.delete(id);
    fetchAllShopVisit();
  }

}