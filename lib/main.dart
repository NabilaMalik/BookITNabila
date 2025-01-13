import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/login_screen.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'Services/FirebaseServices/firebase_remote_config.dart';
import 'ViewModels/WidgetsViewModel/camera_view_model.dart';
import 'Services/FirebaseServices/firebase_options.dart';
import 'ViewModels/order_details_view_model.dart';
import 'ViewModels/order_master_view_model.dart';
import 'ViewModels/shop_visit_view_model.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

// void main() {
//   runApp(
//       MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => PermissionViewModel()),
//           ],
//           child:
//           const MyApp(),
//       ),
//   );
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get.put(PermissionController());
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Config.initialize();
    // await FirebaseAppCheck.instance.activate();
    // // Enable automatic token refresh
    // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  } // Lazy instantiation of view models
  // Get.lazyPut(() => OrderMasterViewModel());
  // Get.lazyPut(() => OrderDetailsViewModel());
  // Get.lazyPut(() => ShopVisitViewModel());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
        debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
