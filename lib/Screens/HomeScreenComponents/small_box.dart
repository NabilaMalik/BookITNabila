
import 'package:flutter/material.dart';

/// Small box widget for overview numbers.
class SmallBox extends StatelessWidget {
  final String number;

  const SmallBox({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient:const LinearGradient(
          colors: [Colors.blue, Colors.white], // List of colors
          begin: Alignment.center, // Starting point
          end: Alignment.bottomRight, // Ending point
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}