import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
import 'package:firebase_app_check/firebase_app_check.dart';

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Config.initialize();

  // You should have the Functions Emulator running locally to use it
  // https://firebase.google.com/docs/functions/local-emulator
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);
  // // Enable automatic token refresh
  // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  // Lazy instantiation of view models
  // Get.lazyPut(() => OrderMasterViewModel());
  // Get.lazyPut(() => OrderDetailsViewModel());
  // Get.lazyPut(() => ShopVisitViewModel());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // home: SplashScreen());
        home: OtpScreen());
  }
}

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _statusMessage = '';

  Future<void> sendOtpEmail(String email) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'us-central1')
            .httpsCallable('sendOtpEmail');
    try {
      final result = await callable.call(<String, dynamic>{
        'email': email,
      });
      print('OTP sent successfully: ${result.data}');
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  sendOtpEmail(_emailController.text);
                } else {
                  setState(() {
                    _statusMessage = 'Please enter a valid email.';
                  });
                }
              },
              child: Text("Send OTP"),
            ),
            SizedBox(height: 16),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
