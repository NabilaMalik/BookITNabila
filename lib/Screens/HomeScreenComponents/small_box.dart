
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
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade50], // Safe, non-null colors
          begin: Alignment.center,       // Gradient starts at center
          end: Alignment.bottomRight,    // Gradient ends at bottom right
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),

        ),
      ),
    );
  }
}