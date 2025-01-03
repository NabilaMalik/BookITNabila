
import 'package:get/get.dart';
import '../Models/recovery_form_model.dart';
import '../Repositories/recovery_form_repository.dart';

class RecoveryFormViewModel extends GetxController{

  var allRecoveryForm = <RecoveryFormModel>[].obs;
  RecoveryFormRepository recoveryformRepository = RecoveryFormRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllRecoveryForm();
  }

  fetchAllRecoveryForm() async{
    var recoveryform = await recoveryformRepository.getRecoveryForm();
    allRecoveryForm.value = recoveryform;
  }

  addRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.add(recoveryformModel);
    fetchAllRecoveryForm();
  }

  updateRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.update(recoveryformModel);
    fetchAllRecoveryForm();
  }

  deleteRecoveryForm(int id){
    recoveryformRepository.delete(id);
    fetchAllRecoveryForm();
  }

}