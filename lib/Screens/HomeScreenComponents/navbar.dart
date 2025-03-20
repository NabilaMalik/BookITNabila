import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';

import '../../ViewModels/update_function_view_model.dart';

class Navbar extends StatelessWidget {
  Navbar({super.key});
  late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());

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
                onTap: () => Get.to(
                      () => const SideMenu(),
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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Add your onTap logic for the search icon here
                  print('Search icon tapped');
                },
                child: Icon(Icons.search, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // Add your onTap logic for the refresh icon here
                  debugPrint('Refresh icon tapped');
                  await Future.wait<void>([
                    updateFunctionViewModel.fetchAndSaveUpdatedCities(),
                    updateFunctionViewModel.fetchAndSaveUpdatedProducts(),
                    updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster(),
                    updateFunctionViewModel.checkAndSetInitializationDateTime()
                  ]);
                },
                child: Icon(Icons.refresh_sharp, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}