

import 'package:get/get.dart';
import '../Models/attendanceOut_model.dart';
import '../Repositories/attendance_out_repository.dart';
class AttendanceOutViewModel extends GetxController{

  var allAttendanceOut = <AttendanceOutModel>[].obs;
  AttendanceOutRepository attendanceoutRepository = AttendanceOutRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllAttendanceOut();
  }

  fetchAllAttendanceOut() async{
    var attendanceout = await attendanceoutRepository.getAttendanceOut();
    allAttendanceOut.value = attendanceout;
  }

  addAttendanceOut(AttendanceOutModel attendanceoutModel){
    attendanceoutRepository.add(attendanceoutModel);
    fetchAllAttendanceOut();
  }

  updateAttendanceOut(AttendanceOutModel attendanceoutModel){
    attendanceoutRepository.update(attendanceoutModel);
    fetchAllAttendanceOut();
  }

  deleteAttendanceOut(int id){
    attendanceoutRepository.delete(id);
    fetchAllAttendanceOut();
  }

}