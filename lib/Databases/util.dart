import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

// import 'package:connectivity/connectivity.dart';

String globalselectedbrand="";
String userBrand="";
String user_id= "BO2";
String? shop_visit_master_id = "";
String? returnMasterId = "";
String? order_master_id = "";

int? recoveryHighestSerial;
String? recoverySavedMonthCounter;
int? shopVisitHighestSerial;
int? shopVisitDetailsHighestSerial;
int? orderMasterHighestSerial;
int? orderDetailsHighestSerial;
int? returnDetailsHighestSerial;
int? returnMasterHighestSerial;
int? attendanceInHighestSerial;
int? attendanceOutHighestSerial;
int? locationHighestSerial;
int? shopHighestSerial;

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
const tableNameLogin ='login';

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

// Function to check internet connection
Future<bool> checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    return false; // No internet connection
  } else {
    try {
      // Test a network request to verify if internet access is available
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Internet connection is working
      }
    } catch (e) {
      return false; // No internet connection
    }
  }
  return false;
}