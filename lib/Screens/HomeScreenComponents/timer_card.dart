import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:rive/rive.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Databases/util.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/location_services_view_model.dart';
import '../../main.dart';
import 'assets.dart ';
import 'menu_item.dart';

class TimerCard extends StatelessWidget {
  final locationViewModel = Get.put(LocationViewModel());
  final attendanceViewModel = Get.put(AttendanceViewModel());
  final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  // final locationServicesViewModel = Get.put(LocationServicesViewModel());
  final loc.Location location = loc.Location();

  void onThemeToggle(bool value) {
    _themeMenuIcon[0].riveIcon.status!.change(value);
  }

  void onThemeRiveIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    if (controller != null) {
      artboard.addController(controller);
      _themeMenuIcon[0].riveIcon.status =
      controller.findInput<bool>("active") as SMIBool?;
    } else {
     debugPrint("StateMachineController not found!");
    }
  }

  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;

  @override
  Widget build(BuildContext context) {
    // final Stopwatch stopwatch = useMemoized(() => Stopwatch());
    // final ValueNotifier<Duration> timerValue = useState(Duration.zero);

    // useEffect(() {
    //   final periodicTimer = Timer.periodic(Duration(seconds: 1), (_) {
    //     if (stopwatch.isRunning) {
    //       timerValue.value = stopwatch.elapsed;
    //     }
    //   });
    //   return periodicTimer.cancel;
    // }, [stopwatch]);

    // String formatDuration(Duration duration) {
    //   String twoDigits(int n) => n.toString().padLeft(2, "0");
    //   String hours = twoDigits(duration.inHours);
    //   String minutes = twoDigits(duration.inMinutes.remainder(60));
    //   String seconds = twoDigits(duration.inSeconds.remainder(60));
    //   return "$hours:$minutes:$seconds";
    // }
    // Function to format duration in seconds to a string
    String _formatDuration(String secondsString) {
      int seconds = int.parse(secondsString);
      Duration duration = Duration(seconds: seconds);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);

      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$secondsFormatted';
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() =>
              Text(
                _formatDuration(
                    locationViewModel.newsecondpassed.value.toString()),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )),
          Obx(() {
            return ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                try {
                  await locationViewModel.saveCurrentLocation();
                  final service = FlutterBackgroundService();
                  newIsClockedIn = locationViewModel.isClockedIn.value;

                  if (newIsClockedIn) {
                    locationViewModel.isClockedIn.value = false;
                    newIsClockedIn = locationViewModel.isClockedIn.value;
                    prefs.setBool('isClockedIn', newIsClockedIn);

                    // await Future(() => service.invoke("stopService"));
                    service.invoke("stopService");
                    // await Future.delayed(const Duration(seconds: 4));

                    // await locationViewModel.saveCurrentLocation();
                    await attendanceOutViewModel.saveFormAttendanceOut();
                    var totalTime = await locationViewModel.stopTimer();

                    await locationViewModel.stopTimer();
                    await locationViewModel.clockRefresh();

                    await locationViewModel.saveLocation();
                    // await Future.delayed(const Duration(seconds: 10));
                    await locationViewModel.saveClockStatus(false);
                    debugPrint("Timer stopped and animation set to inactive.");
                    //locationViewModel.isClockedIn.value = false;
                    _themeMenuIcon[0].riveIcon.status!.value = false;
                    await location.enableBackgroundMode(enable: false);
                  } else {
                    // await locationServicesViewModel.initializeServiceLocation();
                    await initializeServiceLocation();
                    await location.enableBackgroundMode(enable: true);
                    await location.changeSettings(
                        interval: 300, accuracy: loc.LocationAccuracy.high);
                    await service.startService();
                    await locationViewModel.saveCurrentTime();
                    await locationViewModel.saveClockStatus(true);
                    await locationViewModel.clockRefresh();
                    locationViewModel.isClockedIn.value = true;
                    newIsClockedIn = locationViewModel.isClockedIn.value;
                    prefs.setBool('isClockedIn', newIsClockedIn);
                    await attendanceViewModel.saveFormAttendanceIn();

                    _themeMenuIcon[0].riveIcon.status!.value = true;
                    debugPrint("Timer started and animation set to active.");
                  }
                } catch (e) {
                  debugPrint("Error: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: locationViewModel.isClockedIn.value ? Colors
                    .redAccent : Colors.green,
                minimumSize: Size(30, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                padding: EdgeInsets.zero,
              ),
              child: SizedBox(
                width: 35,
                height: 35,
                child: RiveAnimation.asset(
                  iconsRiv,
                  stateMachines: [
                    _themeMenuIcon[0].riveIcon.stateMachine
                  ],
                  artboard: _themeMenuIcon[0].riveIcon.artboard,
                  onInit: onThemeRiveIconInit,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}