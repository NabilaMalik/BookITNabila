
import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/small_box.dart';

/// Overview row widget.
class OverviewRow extends StatelessWidget {
  final List<String> numbers;
  final List<String> labels;

  const OverviewRow({super.key, required this.numbers, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: numbers.map((number) => SmallBox(number: number)).toList(),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: labels.map((label) {
            return SizedBox(
              width: 65,
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

