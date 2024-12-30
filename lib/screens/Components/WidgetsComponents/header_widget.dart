import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final IconData icon;
  final double screenWidth;

  const HeaderWidget({
    Key? key,
    required this.icon,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35.0),
          bottomRight: Radius.circular(35.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: screenWidth * 0.4,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}
