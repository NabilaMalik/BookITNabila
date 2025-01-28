import 'dart:async';

import 'package:connectivity/connectivity.dart';

String globalselectedbrand="";
String userBrand="";
String user_id= "BO2";
String? shop_visit_master_id = "";
String? returnMasterId = "";
String? order_master_id = "";
// bool isClockedIn = false;
// late Timer timer;
// int secondsPassed=0;
const addShopTableName = "addShop";
const shopVisitMasterTableName = "shopMasterVisit";
const shopVisitDetailsTableName = "shopVisitDetails";
const orderMasterTableName = "orderMaster";
const orderDetailsTableName = "orderDetails";
const returnFormMasterTableName = "reConfirmOrder";
const returnFormDetailsTableName = "returnFormDetails";
const recoveryFormTableName = "recoveryForm";
const attendanceTableName = "attendance";
const attendanceOutTableName = "attendanceOut";
const locationTableName = "location";
const productsTableName = "products";

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

