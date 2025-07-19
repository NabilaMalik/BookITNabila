import 'package:flutter/material.dart';
import 'package:order_booking_app/Screens/NSM/NSMOrderDetails/nsm_sm_order_details_screen.dart';
import 'package:order_booking_app/Screens/RSMS_Views/RSMOrderDetails/rsm_bookers_order_details_screen.dart';
import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_bookers_order_details_screen.dart';
import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_rsm_order_details_screen.dart';




class RsmOrderDetailsScreen extends StatefulWidget {
  @override
  _NSMBookingStatusState createState() => _NSMBookingStatusState();
}

class _NSMBookingStatusState extends State<RsmOrderDetailsScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newIndex = _pageController.page!.round();
      if (_selectedIndex != newIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
      }
    });
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 35),
          Container(
            color: Colors.white,
            height: 55,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onButtonPressed(2),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedIndex == 2 ? Colors.blue : Colors.transparent,
                            width: 3.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'BOOKER',
                        style: TextStyle(
                          color: _selectedIndex == 2 ? Colors.blue : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: const [

                RsmBookersOrderDetailsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}