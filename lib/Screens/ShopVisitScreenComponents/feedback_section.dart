// import 'package:flutter/material.dart';
//
// class FeedbackSection extends StatelessWidget {
//   final TextEditingController? feedBackController;
//   final ValueChanged<String> onChanged;
//
//   const FeedbackSection({
//     super.key,
//     required this.feedBackController,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Feedback/Special Note',
//           style: TextStyle(fontSize: 18, color: Colors.black),
//         ),
//         const SizedBox(height: 10),
//         Container(
//           width: double.infinity,
//           height: 150,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.blue, width: 2.0),
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: TextField(
//             controller: feedBackController,
//             onChanged: onChanged,
//             maxLines: null,
//             textDirection: TextDirection.ltr, // ✅ always left-to-right
//             textAlign: TextAlign.start,        // ✅ cursor starts at correct side
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {
  final TextEditingController? feedBackController;
  final ValueChanged<String> onChanged;

  const FeedbackSection({
    super.key,
    required this.feedBackController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback / Special Note',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: feedBackController,
              onChanged: onChanged,
              maxLines: 6,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              decoration: const InputDecoration(
                hintText: "Write your feedback or note here...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';
//
// class FeedbackSection extends StatelessWidget {
//
//  final TextEditingController? feedBackController;
//  final ValueChanged<String> onChanged;
//  const FeedbackSection({super.key,
//    required this.feedBackController,
//    required this.onChanged,
//  });
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Feedback/Special Note',
//           style: TextStyle(fontSize: 18, color: Colors.black),
//         ),
//         const SizedBox(height: 10),
//         Container(
//           width: double.infinity,
//           height: 150,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.blue, width: 2.0),
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child:  TextField(
//             controller: feedBackController,
//             onChanged: onChanged,
//             maxLines: null,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }