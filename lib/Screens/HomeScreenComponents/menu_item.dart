import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/tab_item.dart';

import '../home_screen.dart';



class MenuItemModel {
  MenuItemModel({
    this.id,
    this.title = "",
    required this.riveIcon,
    this.screen


  });

  UniqueKey? id = UniqueKey();
  String title;
  TabItem riveIcon;
  Widget? screen;

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Home",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
      screen: const HomeScreen(),
    ),
    MenuItemModel(
      title: "Search",
      riveIcon:
          TabItem(stateMachine: "SEARCH_Interactivity", artboard: "SEARCH"),
    ),
    MenuItemModel(
      title: "Progress",
      riveIcon:
          TabItem(stateMachine: "STAR_Interactivity", artboard: "LIKE/STAR"),
    ),
    MenuItemModel(
      title: "Help",
      riveIcon: TabItem(stateMachine: "CHAT_Interactivity", artboard: "CHAT"),
    ),
  ];
  static List<MenuItemModel> menuItems2 = [
   MenuItemModel(
      title: "History",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
    MenuItemModel(
      title: "Notification",
      riveIcon: TabItem(stateMachine: "BELL_Interactivity", artboard: "BELL"),
    ),
  ];

   static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: "Clock in",
      riveIcon:
          TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
  ];
}
