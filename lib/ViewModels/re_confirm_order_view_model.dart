import 'package:get/get.dart';
import '../Models/re_confirm_order_model.dart';
import '../repositories/re_confirm_order_repository.dart';
class ReConfirmOrderViewModel extends GetxController{
  var allReConfirmOrder = <ReConfirmOrderModel>[].obs;
  ReConfirmOrderRepository reconfirmorderRepository = ReConfirmOrderRepository();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllReConfirmOrder();
  }
  fetchAllReConfirmOrder() async{
    var reconfirmorder = await reconfirmorderRepository.getReConfirmOrder();
    allReConfirmOrder.value = reconfirmorder;
  }
  addReConfirmOrder(ReConfirmOrderModel reconfirmorderModel){
    reconfirmorderRepository.add(reconfirmorderModel);
    fetchAllReConfirmOrder();
  }
  updateReConfirmOrder(ReConfirmOrderModel reconfirmorderModel){
    reconfirmorderRepository.update(reconfirmorderModel);
    fetchAllReConfirmOrder();
  }
  deleteReConfirmOrder(int id){
    reconfirmorderRepository.delete(id);
    fetchAllReConfirmOrder();
  }
}