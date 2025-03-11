import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/assets.dart' as app_assets;
import 'package:rive/rive.dart'  show Artboard, RiveAnimation, SMIBool, StateMachineController;

import 'menu_button_section.dart';
import 'menu_item.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>  with SingleTickerProviderStateMixin{
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  String _selectedMenu = MenuItemModel.menuItems[0].title;
  bool _isDarkMode = false;

  // ignore: unused_field
  late Animation<LinearGradient> _gradientAnimation;
  void onThemeRiveIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    artboard.addController(controller!);
    _themeMenuIcon[0].riveIcon.status =
    controller.findInput<bool>("active") as SMIBool;
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;
    });
  }

  void onThemeToggle(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _themeMenuIcon[0].riveIcon.status!.change(value);
  }

  late AnimationController _controller;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;
  late Animation<Alignment> _beginAnimation;
  late Animation<Alignment> _endAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Animate individual gradient properties
    _color1Animation = ColorTween(
      begin: Colors.blue,
      end: Colors.blue,
    ).animate(_controller);

    _color2Animation = ColorTween(
      begin: Colors.blue,
      end: Colors.blue,
    ).animate(_controller);

    _beginAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_controller);

    _endAnimation = AlignmentTween(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.64,
            heightFactor: 1,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom - 60 >= 0 ? MediaQuery.of(context).padding.bottom - 60 : 0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                   colors: [_color1Animation.value!, _color2Animation.value!],
                  // colors: const [Colors.orange, Colors.blue],
                  begin: _beginAnimation.value,
                  end: _endAnimation.value,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), // Rounded right side
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "MetaXperts",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontFamily: "Inter"),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Software Engineer",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  fontFamily: "Inter"),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          MenuButtonSection(
                            title: "BROWSE",
                            selectedMenu: _selectedMenu,
                            menuIcons: _browseMenuIcons,
                            onMenuPress: onMenuPress,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Opacity(
                            opacity: 0.99,
                            child: RiveAnimation.asset(
                              app_assets.iconsRiv,
                              stateMachines: [
                                _themeMenuIcon[0].riveIcon.stateMachine
                              ],
                              artboard: _themeMenuIcon[0].riveIcon.artboard,
                              onInit: onThemeRiveIconInit,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _themeMenuIcon[0].title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        CupertinoSwitch(value: _isDarkMode, onChanged: onThemeToggle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}


