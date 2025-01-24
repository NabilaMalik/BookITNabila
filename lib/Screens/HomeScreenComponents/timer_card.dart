import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rive/rive.dart';

import 'assets.dart ';
import 'menu_item.dart';

class TimerCard extends HookWidget {
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
    final Stopwatch stopwatch = useMemoized(() => Stopwatch());
    final ValueNotifier<Duration> timerValue = useState(Duration.zero);

    useEffect(() {
      final periodicTimer = Timer.periodic(Duration(seconds: 1), (_) {
        if (stopwatch.isRunning) {
          timerValue.value = stopwatch.elapsed;
        }
      });
      return periodicTimer.cancel;
    }, [stopwatch]);

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$hours:$minutes:$seconds";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formatDuration(timerValue.value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (stopwatch.isRunning) {
                stopwatch.stop();
                timerValue.value = Duration.zero;
                _themeMenuIcon[0].riveIcon.status!.value = false;
                debugPrint("Timer stopped and animation set to inactive.");
              } else {
                stopwatch
                  ..reset()
                  ..start();
                timerValue.value = Duration.zero;
                _themeMenuIcon[0].riveIcon.status!.value = true;
                debugPrint("Timer started and animation set to active.");
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: stopwatch.isRunning ? Colors.redAccent : Colors.green,
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