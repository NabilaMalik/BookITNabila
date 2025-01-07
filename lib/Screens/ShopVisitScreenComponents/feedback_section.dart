import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {

 final TextEditingController? feedBackController;
 final ValueChanged<String> onChanged;
 const FeedbackSection({super.key,
   required this.feedBackController,
   required this.onChanged,
 });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback/Special Note',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child:  TextField(
            controller: feedBackController,
            onChanged: onChanged,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ),
      ],
    );
  }
}