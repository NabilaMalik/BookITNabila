
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/attendance_Model.dart';
import '../Repositories/attendance_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
class AttendanceViewModel extends GetxController{

  var allAttendance = <AttendanceModel>[].obs;
  AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
LocationViewModel locationViewModel = Get.put(LocationViewModel());
  int attendanceInSerialCounter = 1;
  String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllAttendance();
    _loadCounter();
  }


  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    attendanceInSerialCounter = (prefs.getInt('attendanceInSerialCounter') ?? 1);
    attendanceInCurrentMonth =
        prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }
    if (kDebugMode) {
      print('SR: $attendanceInSerialCounter');
    }
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
    await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      attendanceInSerialCounter = 1;
      currentuser_id = user_id;
    }

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }

    String orderId =
        "ATD-$user_id-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
    attendanceInSerialCounter++;
    _saveCounter();
    return orderId;
  }
  saveFormAttendanceIn() async {
    final orderSerial = generateNewOrderId(user_id);
   // shop_visit_master_id = orderSerial;
   await addAttendance(AttendanceModel(
      attendance_in_id: orderSerial,
      user_id: user_id,
      // booker_name: ,
      // time_in: ,
      lat_in: locationViewModel.globalLatitude1.value,
      lng_in: locationViewModel.globalLongitude1.value ,
      // designation: ,
       address: locationViewModel.shopAddress.value,
    ));
    await attendanceRepository.postDataFromDatabaseToAPI();
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