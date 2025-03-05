import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Repositories/attendance_out_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'location_view_model.dart';
class AttendanceOutViewModel extends GetxController{

  var allAttendanceOut = <AttendanceOutModel>[].obs;
  AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
  LocationViewModel locationViewModel = Get.put(LocationViewModel());

  int attendanceOutSerialCounter = 1;
  String attendanceOutCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadCounter();
    fetchAllAttendanceOut();
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    attendanceOutSerialCounter = (prefs.getInt('attendanceOutSerialCounter') ?? 1);
    attendanceOutCurrentMonth =
        prefs.getString('attendanceOutCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (attendanceOutCurrentMonth != currentMonth) {
      attendanceOutSerialCounter = 1;
      attendanceOutCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      debugPrint('SR: $attendanceOutSerialCounter');
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceOutSerialCounter', attendanceOutSerialCounter);
    await prefs.setString('attendanceOutCurrentMonth', attendanceOutCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      attendanceOutSerialCounter = 1;
      currentuser_id = user_id;
    }

    if (attendanceOutCurrentMonth != currentMonth) {
      attendanceOutSerialCounter = 1;
      attendanceOutCurrentMonth = currentMonth;
    }

    String orderId =
        "ATD-$user_id-$currentMonth-${attendanceOutSerialCounter.toString().padLeft(3, '0')}";
    attendanceOutSerialCounter++;
    _saveCounter();
    return orderId;
  }


  
  saveFormAttendanceOut() async {
    final orderSerial = generateNewOrderId(user_id);
    // shop_visit_master_id = orderSerial;
    addAttendanceOut (AttendanceOutModel(
      attendance_out_id: orderSerial,
      user_id: user_id,
      // booker_name: ,
      // time_out: ,

       total_distance: user_id,
       total_time: user_id,
      lat_out: locationViewModel.globalLatitude1.value,
      lng_out: locationViewModel.globalLongitude1.value ,
      // designation: ,
      address: locationViewModel.shopAddress.value,
    ));
    await attendanceOutRepository.postDataFromDatabaseToAPI();
  }
  fetchAllAttendanceOut() async{
    var attendanceOut = await attendanceOutRepository.getAttendanceOut();
    allAttendanceOut.value = attendanceOut;
  }

  addAttendanceOut(AttendanceOutModel attendanceOutModel){
    attendanceOutRepository.add(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  updateAttendanceOut(AttendanceOutModel attendanceOutModel){
    attendanceOutRepository.update(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  deleteAttendanceOut(int id){
    attendanceOutRepository.delete(id);
    fetchAllAttendanceOut();
  }

}