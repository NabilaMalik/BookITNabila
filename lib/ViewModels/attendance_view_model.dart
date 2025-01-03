

import 'package:get/get.dart';
import '../Models/attendance_Model.dart';
import '../Repositories/attendance_repository.dart';
class AttendanceViewModel extends GetxController{

  var allAttendance = <AttendanceModel>[].obs;
  AttendanceRepository attendanceRepository = AttendanceRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllAttendance();
  }

  fetchAllAttendance() async{
    var attendance = await attendanceRepository.getAttendance();
    allAttendance.value = attendance;
  }

  addAttendance(AttendanceModel attendanceModel){
    attendanceRepository.add(attendanceModel);
    fetchAllAttendance();
  }

  updateAttendance(AttendanceModel attendanceModel){
    attendanceRepository.update(attendanceModel);
    fetchAllAttendance();
  }

  deleteAttendance(int id){
    attendanceRepository.delete(id);
    fetchAllAttendance();
  }

}