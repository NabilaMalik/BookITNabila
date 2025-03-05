import 'dart:async';
import 'dart:io';
import 'dart:io' show Directory, InternetAddress, Platform, SocketException;
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
import 'package:order_booking_app/Screens/home_screen.dart';
import 'package:order_booking_app/Screens/login_screen.dart';
import 'package:order_booking_app/Screens/order_booking_screen.dart';
import 'package:order_booking_app/Screens/order_booking_status_screen.dart';
import 'package:order_booking_app/Screens/reconfirm_order_screen.dart';
import 'package:order_booking_app/Screens/recovery_form_screen.dart';
import 'package:order_booking_app/Screens/return_form_screen.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'Databases/util.dart';
import 'Screens/shop_visit_screen.dart';
import 'Services/FirebaseServices/firebase_remote_config.dart';
import 'Services/FirebaseServices/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart'
    show AndroidServiceInstance;
import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        AndroidFlutterLocalNotificationsPlugin,
        AndroidInitializationSettings,
        AndroidNotificationChannel,
        AndroidNotificationDetails,
        DarwinInitializationSettings,
        FlutterLocalNotificationsPlugin,
        Importance,
        InitializationSettings,
        NotificationDetails;
import 'Tracker/location00.dart';
import 'Tracker/trac.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized.");

    debugPrint("Initializing Config...");
    await Config.initialize();
    debugPrint("Config initialized.");

    debugPrint("Initializing SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
     // bool isAuthenticated = true;
    debugPrint("SharedPreferences initialized. isAuthenticated: $isAuthenticated");

    debugPrint("Initializing Workmanager...");
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    debugPrint("Workmanager initialized.");

    // Initialize background service only if needed
    if (isAuthenticated) {
      debugPrint("Initializing Background Service...");
      await initializeServiceLocation();
      debugPrint("Background Service initialized.");
    }

    debugPrint("Running the app...");
    runApp(MyApp(isAuthenticated));
    debugPrint("App is running.");
  }, (error, stackTrace) {
    print('Error: $error');
    print('Stack Trace: $stackTrace');
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print("WorkManager MMM ");
    }
    return Future.value(true);
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  MyApp(this.isAuthenticated);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isAuthenticated ? '/home' : '/cameraScreen',
      // initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        // GetPage(name: '/policy', page: () => PolicyDialog()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/cameraScreen', page: () => const CameraScreen()),
        GetPage(name: '/ShopVisitScreen', page: () => const ShopVisitScreen()),
        GetPage(name: '/OrderBookingScreen', page: () => OrderBookingScreen()),
        GetPage(name: '/RecoveryFormScreen', page: () => RecoveryFormScreen()),
        GetPage(name: '/ReturnFormScreen', page: () => ReturnFormScreen()),
        GetPage(
            name: '/OrderBookingStatusScreen',
            page: () => OrderBookingStatusScreen()),
      ],
      // home: SplashScreen()
    );
  }
}

Future<void> initializeServiceLocation() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
  // monitorInternetConnection(); // Add this line to monitor connectivity changes
}

// void monitorInternetConnection() {
//   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//     if (result == ConnectivityResult.mobile ||
//         result == ConnectivityResult.wifi) {
//       // backgroundTask();
//     }
//   });
// }
@pragma('vm:entry-point')
void onStart1(ServiceInstance service1) async {
  DartPluginRegistrant.ensureInitialized();
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service1 is AndroidServiceInstance) {
      if (await service1.isForegroundService()) {
        // backgroundTask();
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device1;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device1 = androidInfo.model;
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device1 = iosInfo.model;
    }
    service1.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device1,
      },
    );
  });
}

///background foreground services for location
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocationService locationService = LocationService();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      // backgroundTask();
      //ls.listenLocation();
    });
  }

  service.on('stopService').listen((event) async {
    locationService.stopListening();
    locationService.deleteDocument();
    Workmanager().cancelAll();
    service.stopSelf();
    //stopListeningLocation();
    FlutterLocalNotificationsPlugin().cancelAll();
  });
  // monitorInternetConnection(); // Add this line to monitor connectivity changes

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // backgroundTask();
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device1;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device1 = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device1 = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device1,
      },
    );
  });

  Workmanager().registerPeriodicTask("1", "simpleTask",
      frequency: const Duration(minutes: 15));

  if (locationViewModel.isClockedIn.value == false) {
    startTimer();
    locationService.listenLocation();
  }

  ///background timer
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // flutterLocalNotificationsPlugin.show(
        //   888,
        //   'COOL SERVICE',
        //   'Awesome',
        //   const NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       'my_foreground',
        //       'MY FOREGROUND SERVICE',
        //       icon: 'ic_bg_service_small',
        //       ongoing: true,
        //       priority: Priority.high,
        //     ),
        //   ),
        // );

        // flutterLocalNotificationsPlugin.show(
        //   889,
        //   'Location',
        //   'Longitude ${locationService.longi} , Latitute ${locationService.lat}',
        //   const NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       'my_foreground',
        //       'MY FOREGROUND SERVICE',
        //       icon: 'ic_bg_service_small',
        //       ongoing: true,
        //     ),
        //   ),
        // );

        service.setForegroundNotificationInfo(
          title: "ClockIn",
          content:
              "Timer ${_formatDuration(locationViewModel.secondsPassed.toString())}",
        );
      }
    }

    final deviceInfo = DeviceInfoPlugin();
    String? device;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

String _formatDuration(String secondsString) {
  int seconds = int.parse(secondsString);
  Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$secondsFormatted';
}
