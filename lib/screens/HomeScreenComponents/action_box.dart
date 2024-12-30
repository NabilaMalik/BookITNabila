import 'package:flutter/material.dart';

/// Action box widget with onTap functionality.
class ActionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap; // Callback for the tap event

  const ActionBox({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap, // Required parameter for tap functionality
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Calls the provided onTap function when tapped
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.8),
              spreadRadius: 2,
              blurRadius: 9,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
