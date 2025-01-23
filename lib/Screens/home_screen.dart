import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/add_shop_screen.dart';
import 'package:order_booking_app/screens/order_booking_status_screen.dart';
import 'package:order_booking_app/screens/recovery_form_screen.dart';
import 'package:order_booking_app/screens/return_form_screen.dart';
import 'package:order_booking_app/screens/shop_visit_screen.dart';
import 'package:rive/rive.dart' show Artboard, SMIBool, StateMachineController;
import 'HomeScreenComponents/action_box.dart';
import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/overview_row.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _RiveAppHomeState();
}

class _RiveAppHomeState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;
  late SMIBool _menuBtn;
   Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );
  bool _showOnBoarding = false;
  void _onMenuIconInit(Artboard artboard) {
    final controller =
    StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void _presentOnBoarding(bool show) {
    if (show) {
      setState(() {
        _showOnBoarding = true;
      });
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _onBoardingAnimController?.animateWith(springAnim);
    } else {
      _onBoardingAnimController?.reverse().whenComplete(() => {
        setState(() {
          _showOnBoarding = false;
        })
      });
    }
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }
  // final List<Widget> _screens = [
  //   const HomeTabView(),
  //   commonTabScene("User"),
  //   commonTabScene("User"),
  //   commonTabScene("User"),
  //
  // ];
  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _onBoardingAnimController!,
      curve: Curves.linear,
    ));

    // _tabBody = _screens.first;
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              TimerCard(), // Add the TimerCard here
              const SizedBox(height: 10),
              _buildActionButtons(screenWidth),
              const SizedBox(height: 20),
              _buildOverviewSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header, including navbar and profile section.
  Widget _buildHeader() {
    return Container(
      color: Colors.blue,
      child: const Column(
        children: [
          Navbar(),
          SizedBox(height: 10),
          ProfileSection(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Builds the section with action buttons.
  Widget _buildActionButtons(double screenWidth) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionBox(icon: Icons.add_shopping_cart, label: 'Add Shop',onTap:() => Get.to(() => AddShopScreen()),
    ),
              ActionBox(icon: Icons.business, label: 'Shop Visit',onTap:  () => Get.to(() => ShopVisitScreen()),
              ),
              ActionBox(icon: Icons.assignment, label: 'Return Form',onTap:  () => Get.to(() => const ReturnFormScreen()),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionBox(icon: Icons.remove_circle, label: 'Recovery',onTap:  () => Get.to(() =>  RecoveryFormScreen()),
              ),
              ActionBox(icon: Icons.book, label: 'Booking Status', onTap:  () => Get.to(() =>  OrderBookingStatusScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the overview section with summary boxes.
  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.8),
                  spreadRadius: 3,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              children: [
                OverviewRow(
                  numbers: ["123", "45", "67", "89"],
                  labels: ["Total Bookings", "Shops", "Returns", "Visits"],
                ),
                SizedBox(height: 20),
                OverviewRow(
                  numbers: ["12", "34", "56", "78"],
                  labels: ["Monthly Attendance", "Daily Bookings", "Orders", "Recovery"],
                ),
                SizedBox(height: 20),
                OverviewRow(
                  numbers: ["910", "112"],
                  labels: ["Total Orders", "Dispatched"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class TimerCard extends HookWidget {
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

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${timerValue.value.inHours.toString().padLeft(2, '0')}:${(timerValue.value.inMinutes % 60).toString().padLeft(2, '0')}:${(timerValue.value.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (stopwatch.isRunning) {
                      stopwatch.stop();
                      timerValue.value = Duration.zero;
                    } else {
                      stopwatch
                        ..reset()
                        ..start();
                      timerValue.value = Duration.zero;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stopwatch.isRunning ? Colors.red : Colors.green,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                  child: Icon(
                    stopwatch.isRunning ? Icons.stop : Icons.play_arrow,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


