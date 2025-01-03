import 'package:get/get.dart';
import '../Models/shop_visit_details_model.dart';
import '../Repositories/shop_visit_details_repository.dart';
class ShopVisitDetailsViewModel extends GetxController{

  var allShopVisitDetails = <ShopVisitDetailsModel>[].obs;
  ShopVisitDetailsRepository shopvisitdetailsRepository = ShopVisitDetailsRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllShopVisitDetails();
  }

  fetchAllShopVisitDetails() async{
    var shopvisitdetails = await shopvisitdetailsRepository.getShopVisitDetails();
    allShopVisitDetails.value = shopvisitdetails;
  }

  addShopVisitDetails(ShopVisitDetailsModel shopvisitdetailsModel){
    shopvisitdetailsRepository.add(shopvisitdetailsModel);
    fetchAllShopVisitDetails();
  }

  updateShopVisitDetails(ShopVisitDetailsModel shopvisitdetailsModel){
    shopvisitdetailsRepository.update(shopvisitdetailsModel);
    fetchAllShopVisitDetails();
  }

  deleteShopVisitDetails(int id){
    shopvisitdetailsRepository.delete(id);
    fetchAllShopVisitDetails();
  }

}