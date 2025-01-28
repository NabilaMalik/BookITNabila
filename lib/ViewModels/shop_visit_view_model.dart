import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Screens/home_screen.dart';
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
  var phone_number =''.obs;
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
  Future<void> onInit() async {
    super.onInit();
    _loadCounter();
    await addShopRepository.fetchAndSaveShops();
    fetchShops(); // Add this line to fetch saved shops
    fetchBrands(); // Add this line to fetch saved shops
  }

  Future<void> fetchBrands() async {
    try {
      var savedBrands = await productsRepository.getProductsModel();
      brands.value = savedBrands.map((product) => product.brand).toSet().toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch Brands: $e');
      }
    }
  }

  Future<void> fetchShops() async {
    try {
      var savedShops = await addShopRepository.getAddShop();
      shops.value = savedShops.map((shop) => shop.shop_name).toList();
      shopDetails.value =
          savedShops; // Update this line to store full shop details
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch shops: $e');
      }
    }
  }

  updateShopDetails(String shopName) {
    var shop = shopDetails.firstWhere((shop) => shop.shop_name == shopName);
    shop_address.value = shop.shop_address!;
    owner_name.value = shop.owner_name!;
    phone_number.value =shop.phone_no!;


    shopAddressController.text = shop.shop_address!;
    ownerNameController.text = shop.owner_name!;
  }


  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    shopVisitsSerialCounter = (prefs.getInt('shopVisitsSerialCounter') ?? 1);
    shopVisitCurrentMonth =
        prefs.getString('shopVisitCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (shopVisitCurrentMonth != currentMonth) {
      shopVisitsSerialCounter = 1;
      shopVisitCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      print('SR: $shopVisitsSerialCounter');
    }
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
      shopVisitsSerialCounter = 1;
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

  Future<void> saveForm() async {
    if (validateForm()) {
      print("Start Savinggggggggggggg");
      Uint8List? compressedImageBytes;
      if (selectedImage.value != null) {
        compressedImageBytes = await FlutterImageCompress.compressWithFile(
          selectedImage.value!.path,
          minWidth: 400,
          minHeight: 600,
          quality: 40,
        );
      }

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
        addPhoto: compressedImageBytes,
        feedback: feedBack.value,
        shop_visit_master_id: shop_visit_master_id, // Add the generated serial here
      ));
      await shopvisitRepository.getShopVisit();
      await shopVisitDetailsViewModel.saveFilteredProducts();
      Get.snackbar("Success", "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
      await clearFilters();

      Get.to(() => const OrderBookingScreen());
    }
  }

  Future<void> saveFormNoOrder() async {
    if (validateForm()) {
      print("Start Savinggggggggggggg");
      Uint8List? compressedImageBytes;
      if (selectedImage.value != null) {
        compressedImageBytes = await FlutterImageCompress.compressWithFile(
          selectedImage.value!.path,
          minWidth: 400,
          minHeight: 600,
          quality: 40,
        );
      }

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
        addPhoto: compressedImageBytes,
        feedback: feedBack.value,
        shop_visit_master_id: shop_visit_master_id, // Add the generated serial here
      ));
      await shopvisitRepository.getShopVisit();
      await shopVisitDetailsViewModel.saveFilteredProducts();
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

  deleteShopVisit(int id) {
    shopvisitRepository.delete(id);
    fetchAllShopVisit();
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
}
