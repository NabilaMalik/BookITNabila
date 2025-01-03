
import 'package:flutter/material.dart';

/// Profile section widget.
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BOOKIT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text("User Name", style: TextStyle(fontSize: 14)),
                SizedBox(height: 2),
                Text("LOGIN", style: TextStyle(fontSize: 14)),
                SizedBox(height: 2),
                Text("Designation", style: TextStyle(fontSize: 14)),
              ],
            ),
            Spacer(),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ],
        ),
      ),
    );
  }
}
