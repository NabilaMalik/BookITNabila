import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.8),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap:() => Get.to(() => const SideMenu(),
                  transition: Transition.fade, // Add fade transition
                ),

                child: const Icon(Icons.menu, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              const Text(
                "BookIT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.search, color: Colors.white, size: 28),
              SizedBox(width: 20),
              Icon(Icons.notifications, color: Colors.white, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}
