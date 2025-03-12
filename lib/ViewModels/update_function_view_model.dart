
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/update_functions_repository.dart';

class UpdateFunctionViewModel extends GetxController {
  UpdateFunctionsRepository updateFunctionsRepository = Get.put(UpdateFunctionsRepository());

  bool isUpdate = false;
Future<void> checkAndSetInitializationDateTime() async {
    await updateFunctionsRepository.checkAndSetInitializationDateTime();
  }
Future<void> fetchAndSaveUpdatedOrderMaster() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedOrderMaster();
}

  Future<void> fetchAndSaveUpdatedProducts() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedProducts();
  }
  Future<List<String>> fetchAndSaveUpdatedCities() async {
    return await updateFunctionsRepository.fetchAndSaveUpdatedCities();
  }
}