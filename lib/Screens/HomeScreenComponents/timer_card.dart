import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Models/attendanceOut_model.dart';
import 'package:order_booking_app/Models/attendance_Model.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:rive/rive.dart';
import 'package:location/location.dart' as loc;
import '../../Databases/util.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../main.dart';
import 'assets.dart ';
import 'menu_item.dart';

class TimerCard extends StatelessWidget {
  LocationViewModel locationViewModel = Get.put(LocationViewModel());
  final attendanceViewModel = Get.put(AttendanceViewModel());
  final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
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
         Obx(()=> Text(
            _formatDuration(locationViewModel.newsecondpassed.value.toString()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
          ElevatedButton(
            onPressed: () async {
              locationViewModel.saveCurrentLocation();
              final service = FlutterBackgroundService();
              bool newIsClockedIn = locationViewModel.isClockedIn.value;

              if (newIsClockedIn) {

                service.invoke("stopService");
                locationViewModel.saveCurrentLocation();
                attendanceOutViewModel.saveFormAttendanceOut();

                locationViewModel.isClockedIn.value = false;
                await locationViewModel.saveClockStatus(false);
                await locationViewModel.stopTimer();
                await locationViewModel.clockRefresh();
                await location.enableBackgroundMode(enable: false);
                // stopwatch.stop();
                // timerValue.value = Duration.zero;
                _themeMenuIcon[0].riveIcon.status!.value = false;
                debugPrint("Timer stopped and animation set to inactive.");
              } else{
                await initializeServiceLocation();
                await location.enableBackgroundMode(enable: true);
                await location.changeSettings(
                    interval: 300, accuracy: loc.LocationAccuracy.high);
                // locationbool = true;
                service.startService();
                locationViewModel.saveCurrentTime();
                locationViewModel.saveClockStatus(true);
                locationViewModel.clockRefresh();
                locationViewModel.isClockedIn.value = true;
                attendanceViewModel.saveFormAttendanceIn();

                // timerValue.value = Duration.zero;
                 _themeMenuIcon[0].riveIcon.status!.value = true;
                debugPrint("Timer started and animation set to active.");
              }
              // Update state and close the loading indicator dialog

            },

            style: ElevatedButton.styleFrom(
              backgroundColor: locationViewModel.isClockedIn.value ? Colors.redAccent : Colors.green,
              minimumSize: Size(30, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              padding: EdgeInsets.zero,
            ),
            child: SizedBox(
              width: 35,
              height: 35,
              child:RiveAnimation.asset(
                iconsRiv,
                stateMachines: [
                  _themeMenuIcon[0].riveIcon.stateMachine
                ],
                artboard: _themeMenuIcon[0].riveIcon.artboard,
                onInit: onThemeRiveIconInit,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}