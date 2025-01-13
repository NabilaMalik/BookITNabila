import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
import '../Models/shop_visit_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';
import '../Repositories/shop_visit_repository.dart';
import '../Screens/order_booking_screen.dart';

class ShopVisitViewModel extends GetxController {
  var allShopVisit = <ShopVisitModel>[].obs;
  ShopVisitRepository shopvisitRepository = ShopVisitRepository();
  ProductsRepository productsRepository = Get.put(ProductsRepository());
  late ShopVisitDetailsViewModel shopVisitDetailsViewModel= Get.put(ShopVisitDetailsViewModel()); // remove direct dependency here
  final _shopVisit = ShopVisitModel().obs;
  final ImagePicker picker = ImagePicker();
  ShopVisitModel get shopVisit => _shopVisit.value;

  GlobalKey<FormState> get formKey => _formKey;
  final _formKey = GlobalKey<FormState>();

  var shopAddress = ''.obs;
  var ownerName = ''.obs;
  var bookerName = ''.obs;
  var feedBack = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var selectedImage = Rx<XFile?>(null);
  // var filteredRows = <Map<String, dynamic>>[].obs;
  var checklistState = List<bool>.filled(4, false).obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final List<String> brands = ['Roxie Color', 'Roxie', 'USHA'];
  final List<String> shops = ['Shop X', 'Shop Y', 'Shop Z'];
  final List<String> checklistLabels = [
    'Performed Store Walkthrough',
    'Updated Store Planogram',
    'Checked Shelf Tags and Price Signage',
    'Reviewed Expiry Dates on Products',
  ];

  @override
  void onInit() {
    // Initialize shopVisitDetailsViewModel here after initial dependencies are ready
  //  shopVisitDetailsViewModel = Get.find<ShopVisitDetailsViewModel>();
    super.onInit();
  }

  Future<void> pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    selectedImage.value = image;
  }

  Future<void> takePicture() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    selectedImage.value = image;
  }

clearFilters() {
    // _shopVisit.value = ShopVisitModel();
    // _formKey.currentState?.reset();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  saveForm() async {

    if (validateForm()) {
      print("Start Savinggggggggggggg");
      // Compress the image
      Uint8List? compressedImageBytes;
      if (selectedImage.value != null) {
        compressedImageBytes = await FlutterImageCompress.compressWithFile(
          selectedImage.value!.path,
          minWidth: 400,
          minHeight: 600,
          quality: 40,
        );
      }

      await addShopVisit(ShopVisitModel(
        shopName: selectedShop.value,
        shopAddress: shopAddress.value,
        shopOwner: ownerName.value,
        brand: selectedBrand.value,
        bookerName: bookerName.value,
        walkthrough: checklistState[0],
        planogram: checklistState[1],
        signage: checklistState[2],
        productReviewed: checklistState[3],
        addPhoto: compressedImageBytes,
        feedback: feedBack.value,
      ));
      await shopvisitRepository.getShopVisit();
      await shopVisitDetailsViewModel.saveFilteredProducts();
      Get.snackbar(
          "Success", "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
      await clearFilters();

      // Navigate to another screen if needed
      Get.to(() => OrderBookingScreen());
    }
  }

  fetchAllShopVisit() async {
    var shopvisit = await shopvisitRepository.getShopVisit();
    allShopVisit.value = shopvisit;
  }

  addShopVisit(ShopVisitModel shopvisitModel) {
    shopvisitRepository.add(shopvisitModel);
    fetchAllShopVisit();
  }

  updateShopVisit(ShopVisitModel shopvisitModel) {
    shopvisitRepository.update(shopvisitModel);
    fetchAllShopVisit();
  }

  deleteShopVisit(int id) {
    shopvisitRepository.delete(id);
    fetchAllShopVisit();
  }
}
