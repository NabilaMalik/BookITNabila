import 'package:get/get.dart';
import '../Models/return_form_model.dart';
import '../Repositories/return_form_repository.dart';
class ReturnFormViewModel extends GetxController{

  var allReturnForm = <ReturnFormModel>[].obs;
  ReturnFormRepository returnformRepository = ReturnFormRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllReturnForm();
  }

  fetchAllReturnForm() async{
    var returnform = await returnformRepository.getReturnForm();
    allReturnForm.value = returnform;
  }

  addReturnForm(ReturnFormModel returnformModel){
    returnformRepository.add(returnformModel);
    fetchAllReturnForm();
  }

  updateReturnForm(ReturnFormModel returnformModel){
    returnformRepository.update(returnformModel);
    fetchAllReturnForm();
  }

  deleteReturnForm(int id){
    returnformRepository.delete(id);
    fetchAllReturnForm();
  }

}