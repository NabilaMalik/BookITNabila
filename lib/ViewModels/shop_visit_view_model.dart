import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
import '../Databases/util.dart';
import '../Models/add_shop_model.dart';
import '../Models/shop_visit_model.dart';
import '../Repositories/ScreenRepositories/products_repository.dart';
import '../Repositories/shop_visit_repository.dart';
import '../Repositories/add_shop_repository.dart';
import '../Screens/order_booking_screen.dart';
import '../Services/ApiServices/serial_number_genterator.dart';

class ShopVisitViewModel extends GetxController {
  var allShopVisit = <ShopVisitModel>[].obs;
  ShopVisitRepository shopvisitRepository = ShopVisitRepository();
  ProductsRepository productsRepository = Get.put(ProductsRepository());
  late ShopVisitDetailsViewModel shopVisitDetailsViewModel =
      Get.put(ShopVisitDetailsViewModel());
  AddShopRepository addShopRepository = Get.put(AddShopRepository());
  final _shopVisit = ShopVisitModel().obs;
  final ImagePicker picker = ImagePicker();
  ShopVisitModel get shopVisit => _shopVisit.value;

  GlobalKey<FormState> get formKey => _formKey;
  final _formKey = GlobalKey<FormState>();
// Add TextEditingControllers
  final TextEditingController shopAddressController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController bookerNameController = TextEditingController();
  var shop_address = ''.obs;
  var owner_name = ''.obs;
  var booker_name = ''.obs;
  var phone_number = ''.obs;
  var feedBack = ''.obs;
  var selectedBrand = ''.obs;
  var selectedShop = ''.obs;
  var selectedImage = Rx<XFile?>(null);
  var checklistState = List<bool>.filled(4, false).obs;
  var rows = <DataRow>[].obs;
  ValueNotifier<List<Map<String, dynamic>>> rowsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  // final List<String?> brands = ['Roxie Color', 'Roxie', 'USHA'];
  var brands = <String?>[].obs; // Change this line
  var shops = <String?>[].obs; // Change this line
  var shopDetails = <AddShopModel>[].obs; // Add this line
  final List<String> checklistLabels = [
    'Performed Store walk_through',
    'Updated Store Planogram',
    'Checked Shelf Tags and Price Signage',
    'Reviewed Expiry Dates on Products',
  ];

  int shopVisitsSerialCounter = 1;
  String shopVisitCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  // Future<void> onInit() async {
  //   super.onInit();
  //
  //   // await addShopRepository.fetchAndSaveShops();
  //   //  fetchShops(); // Add this line to fetch saved shops
  //   // fetchBrands(); // Add this line to fetch saved shops
  // }

  Future<void> fetchBrands() async {
    try {
      var savedBrands = await productsRepository.getProductsModel();
      brands.value =
          savedBrands.map((product) => product.brand).toSet().toList();
    } catch (e) {
      debugPrint('Failed to fetch Brands: $e');
    }
  }

  Future<void> fetchShops() async {
    try {
      var savedShops = await addShopRepository.getAddShop();
      shops.value = savedShops.map((shop) => shop.shop_name).toList();
      shopDetails.value =
          savedShops; // Update this line to store full shop details
    } catch (e) {
      debugPrint('Failed to fetch shops: $e');
    }
  }

  updateShopDetails(String shopName) {
    var shop = shopDetails.firstWhere((shop) => shop.shop_name == shopName);
    shop_address.value = shop.shop_address!;
    owner_name.value = shop.owner_name!;
    phone_number.value = shop.phone_no!;
    shopAddressController.text = shop.shop_address!;
    ownerNameController.text = shop.owner_name!;
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopVisitsSerialCounter = (prefs.getInt('shopVisitsSerialCounter') ??
        shopVisitHighestSerial ??
        1);
    shopVisitCurrentMonth =
        prefs.getString('shopVisitCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (shopVisitCurrentMonth != currentMonth) {
      shopVisitsSerialCounter = 1;
      shopVisitCurrentMonth = currentMonth;
    }

    debugPrint('SR: $shopVisitsSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shopVisitsSerialCounter', shopVisitsSerialCounter);
    await prefs.setString('shopVisitCurrentMonth', shopVisitCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      shopVisitsSerialCounter = shopVisitHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (shopVisitCurrentMonth != currentMonth) {
      shopVisitsSerialCounter = 1;
      shopVisitCurrentMonth = currentMonth;
    }

    String orderId =
        "SV-$user_id-$currentMonth-${shopVisitsSerialCounter.toString().padLeft(3, '0')}";
    shopVisitsSerialCounter++;
    _saveCounter();
    return orderId;
  }

// Function to save an image
  Future<void> saveImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/captured_image.jpg';

      // Compress the image
      Uint8List? compressedImageBytes =
          await FlutterImageCompress.compressWithFile(
        selectedImage.value!.path,
        minWidth: 400,
        minHeight: 600,
        quality: 40,
      );

      if (compressedImageBytes != null) {
        // Save the compressed image
        await File(filePath).writeAsBytes(compressedImageBytes);

        debugPrint('Compressed image saved successfully at $filePath');
      } else {
        debugPrint('Image compression failed.');
      }
    } catch (e) {
      debugPrint('Error compressing and saving image: $e');
    }
  }

  Future<void> saveForm() async {
    if (validateForm()) {

      debugPrint("Start Savinggggggggggggg");
      Uint8List? compressedImageBytes;
      if (selectedImage.value != null) {
      // await  serialCounterGet();
        SerialNumberGenerator(
          apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/shopvisitserial/get/$user_id',
          maxColumnName: 'max(shop_visit_master_id)',
          serialType: shopVisitDetailsHighestSerial, // Unique identifier for shop visit serials
        );
        debugPrint("Serial: $shopVisitDetailsHighestSerial");
        compressedImageBytes = await FlutterImageCompress.compressWithFile(
          selectedImage.value!.path,
          minWidth: 400,
          minHeight: 600,
          quality: 40,
        );

        await _loadCounter();
        final orderSerial = generateNewOrderId(user_id);
        shop_visit_master_id = orderSerial;

        await addShopVisit(ShopVisitModel(
          shop_name: selectedShop.value,
          shop_address: shop_address.value,
          owner_name: owner_name.value,
          brand: selectedBrand.value,
          booker_name: booker_name.value,
          walk_through: checklistState[0],
          planogram: checklistState[1],
          signage: checklistState[2],
          product_reviewed: checklistState[3],
          body: compressedImageBytes,
          feedback: feedBack.value,
          user_id: user_id.toString(),
          shop_visit_master_id:
          shop_visit_master_id.toString(), // Add the generated serial here
        ));
        await shopvisitRepository.getShopVisit();
        await shopVisitDetailsViewModel.saveFilteredProducts();
        await shopvisitRepository.postDataFromDatabaseToAPI();
        await shopvisitRepository.getShopVisit();

        Get.snackbar("Success", "Form submitted successfully!",
            snackPosition: SnackPosition.BOTTOM);
        await clearFilters();
        // Get.offAllNamed("/OrderBookingScreen");
        Get.to(() => const OrderBookingScreen());
      }
    }
  }

  Future<void> saveFormNoOrder() async {
    if (validateForm()) {
      debugPrint("Start Savinggggggggggggg");
      String? imagePath;
      Uint8List? imageBytes;
      if (selectedImage.value != null) {
        imagePath = selectedImage.value!.path;

        List<int> imageBytesList = await File(imagePath).readAsBytes();
        imageBytes = Uint8List.fromList(imageBytesList);
      }

      List<int> imageBytesList = await File(imagePath!).readAsBytes();
      imageBytes = Uint8List.fromList(imageBytesList);
      final orderSerial = generateNewOrderId(user_id);
      shop_visit_master_id = orderSerial;

      await addShopVisit(ShopVisitModel(
        shop_name: selectedShop.value.toString(),
        shop_address: shop_address.value.toString(),
        owner_name: owner_name.value.toString(),
        brand: selectedBrand.value.toString(),
        booker_name: booker_name.value.toString(),
        walk_through: checklistState[0],
        planogram: checklistState[1],
        signage: checklistState[2],
        product_reviewed: checklistState[3],
        body: imageBytes, // Store the file path
        feedback: feedBack.value,
        shop_visit_master_id: shop_visit_master_id,
      ));

      await shopvisitRepository.getShopVisit();
      await shopVisitDetailsViewModel.saveFilteredProducts();
      await shopvisitRepository.postDataFromDatabaseToAPI();

      Get.snackbar("Success", "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
      await clearFilters();
      Get.to(() => const HomeScreen());
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

  deleteShopVisit(String id) {
    shopvisitRepository.delete(id);
    fetchAllShopVisit();
  }

  Future<void> pickImage() async {
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    selectedImage.value = image;
    await saveImage();
  }

  Future<void> takePicture() async {
    final image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 40);
    selectedImage.value = image;
    await saveImage();
  }

  clearFilters() {
    // _shopVisit.value = ShopVisitModel();

    // _formKey.currentState?.reset();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
serialCounterGet()async{
   await shopvisitRepository.serialNumberGeneratorApi();
}

}
