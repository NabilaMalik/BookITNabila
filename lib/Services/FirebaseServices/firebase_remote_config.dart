import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class Config {
  static late FirebaseRemoteConfig remoteConfig;

  static Future<void> initialize() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 1),
      // Set to 1 minute for development; change to a larger interval for production
      minimumFetchInterval: Duration(seconds: 1),
    ));
    await fetchLatestConfig(); // Fetch and activate immediately
  }

  static Future<void> fetchLatestConfig() async {
    try {
      bool updated = await remoteConfig.fetchAndActivate();
      if (updated) {
        if (kDebugMode) {
          debugPrint('Remote config updated');
        }
      } else {
        if (kDebugMode) {
          debugPrint('No changes in remote config');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch remote config: $e');
      }
    }
  }

// Static configuration parameters for GET API URLs
  static String get getApiUrlLogin => remoteConfig.getString('LoginGetUrl');

  static String get getApiUrlShops1 => remoteConfig.getString('ShopsGetUrl1');
  static String get getApiUrlShops2 => remoteConfig.getString('ShopsGetUrl2');
  static String get getApiUrlShops3 => remoteConfig.getString('ShopsGetUrl3');
  static String get getApiUrlShops4 => remoteConfig.getString('ShopsGetUrl4');
  static String get getApiUrlShopVisitDetails =>
      remoteConfig.getString('ShopVisitDetailsGetUrl');
  static String get getApiUrlLocation =>
      remoteConfig.getString('LocationGetUrl');
  static String get getApiUrlAttendanceIn =>
      remoteConfig.getString('AttendanceInGetUrl');
  static String get getApiUrlAttendanceOut =>
      remoteConfig.getString('AttendanceOutGetUrl');
  static String get getApiUrlProducts =>
      remoteConfig.getString('ProductsGetUrl');

  static String get getApiUrlBrands => remoteConfig.getString('BrandsGetUrl');

  static String get getApiUrlCities => remoteConfig.getString('CitiesGetUrl');

  static String get getApiUrlOrderMaster =>
      remoteConfig.getString('OrderMasterGetUrl');

  static String get getApiUrlOrderDetails =>
      remoteConfig.getString('OrderDetailsGetUrl');

  static String get getApiUrlRecoveryForm =>
      remoteConfig.getString('RecoveryFormGetUrl');

  static String get getApiUrlReturnForm =>
      remoteConfig.getString('ReturnFormUrl');

  static String get getApiUrlReturnFormDetails =>
      remoteConfig.getString('ReturnFormDetailsGetUrl');

  static String get getApiUrlShopVisit =>
      remoteConfig.getString('ShopVisitGetUrl');

  static String get getApiUrlStockCheckItems =>
      remoteConfig.getString('StockCheckItemsGetUrl');

  static String get getApiUrlOrderBookingStatus =>
      remoteConfig.getString('OrderBookingStatusGetUrl');

// Static configuration parameters for POST API URLs with postApiUrl prefix
  static String get postApiUrlShopVisitDetails =>
      remoteConfig.getString('ShopVisitDetailsPostUrl');
  static String get postApiUrlShops => remoteConfig.getString('ShopsPostUrl');

  static String get postApiUrlProducts =>
      remoteConfig.getString('ProductsPostUrl');

  static String get postApiUrlBrands => remoteConfig.getString('BrandsPostUrl');

  static String get postApiUrlOrderMaster =>
      remoteConfig.getString('OrderMasterPostUrl');

  static String get postApiUrlOrderDetails =>
      remoteConfig.getString('OrderDetailsPostUrl');

  static String get postApiUrlRecoveryForm =>
      remoteConfig.getString('RecoveryFormPostUrl');

  static String get postApiUrlReturnForm =>
      remoteConfig.getString('ReturnFormPostUrl');

  static String get postApiUrlReturnFormDetails =>
      remoteConfig.getString('ReturnFormDetailsPostUrl');

  static String get postApiUrlShopVisit =>
      remoteConfig.getString('ShopVisitPostUrl');

  static String get postApiUrlAttendanceIn =>
      remoteConfig.getString('AttendanceInPostUrl');

  static String get postApiUrlAttendanceOut =>
      remoteConfig.getString('AttendanceOutPostUrl');

  static String get postApiUrlLocation =>
      remoteConfig.getString('LocationPostUrl');
}
