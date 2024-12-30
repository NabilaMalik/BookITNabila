import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/login_screen.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'ViewModels/WidgetsViewModel/camera_view_model.dart';

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
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Get.put(PermissionController());
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home:SplashScreen()
    );
  }
}

