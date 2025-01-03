
import 'package:get/get.dart';
import '../Models/returnform_details_model.dart';
import '../Repositories/return_form_details_repository.dart';
class ReturnFormDetailsViewModel extends GetxController{

  var allReturnFormDetails = <ReturnFormDetailsModel>[].obs;
  ReturnFormDetailsRepository returnformdetailsRepository = ReturnFormDetailsRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllReturnFormDetails();
  }

  fetchAllReturnFormDetails() async{
    var returnformdetails = await returnformdetailsRepository.getReturnFormDetails();
    allReturnFormDetails.value = returnformdetails;
  }

  addReturnFormDetails(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.add(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  updateReturnFormDetails(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.update(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  deleteReturnFormDetails(int id){
    returnformdetailsRepository.delete(id);
    fetchAllReturnFormDetails();
  }

}