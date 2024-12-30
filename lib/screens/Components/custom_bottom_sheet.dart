import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomSheet Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15.0),
                ),
              ),
              builder: (context) => _buildBottomSheetContent(context),
            );
          },
          child: const Text('Show BottomSheet'),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'BottomSheet Content',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is an example of a bottom sheet. You can place any content here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
// Widget _buildBottomSheetContent(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.all(30.0),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 50,
//           height: 5,
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         const Text(
//           'Quick Support',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         CustomButton(
//           top: MediaQuery
//               .of(context)
//               .size
//               .height * 0.8,
//           left: MediaQuery
//               .of(context)
//               .size
//               .width * 0.05,
//           width: MediaQuery
//               .of(context)
//               .size
//               .width * 0.9,
//           height: 55,
//           buttonText: 'CONTINUE',
//           icon: Icons.report_gmailerrorred,
//           iconSize: 25,
//           iconColor: Colors.black,
//           textStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           gradientColors: [ Colors.white54, Colors.white54],
//           // Custom gradient
//           onTap: () {
//             debugPrint("Navigating to Past Promo Page");
//             Get.offNamed('/viewProfile');
//           },
//           borderRadius: 15.0,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               offset: Offset(0, 5),
//               blurRadius: 10,
//             ),
//           ],
//         ), const SizedBox(height: 10),
//         CustomButton(
//           top: MediaQuery
//               .of(context)
//               .size
//               .height * 0.8,
//           left: MediaQuery
//               .of(context)
//               .size
//               .width * 0.05,
//           width: MediaQuery
//               .of(context)
//               .size
//               .width * 0.9,
//           height: 55,
//           buttonText: 'CONTINUE',
//           icon: Icons.edit,
//           iconSize: 16,
//           // iconColor: Colors.white,
//           textStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           gradientColors: const [buttonColorGreen, buttonColorGreen],
//           // Custom gradient
//           onTap: () {
//             debugPrint("Navigating to Past Promo Page");
//             Get.offNamed('/viewProfile');
//           },
//           borderRadius: 15.0,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               offset: Offset(0, 5),
//               blurRadius: 10,
//             ),
//           ],
//         ), const SizedBox(height: 10),
//         CustomButton(
//           top: MediaQuery
//               .of(context)
//               .size
//               .height * 0.8,
//           left: MediaQuery
//               .of(context)
//               .size
//               .width * 0.05,
//           width: MediaQuery
//               .of(context)
//               .size
//               .width * 0.9,
//           height: 55,
//           buttonText: 'CONTINUE',
//           icon: Icons.edit,
//           iconSize: 16,
//           // iconColor: Colors.white,
//           textStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           gradientColors: const [buttonColorGreen, buttonColorGreen],
//           // Custom gradient
//           onTap: () {
//             debugPrint("Navigating to Past Promo Page");
//             Get.offNamed('/viewProfile');
//           },
//           borderRadius: 15.0,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               offset: Offset(0, 5),
//               blurRadius: 10,
//             ),
//           ],
//         ), const SizedBox(height: 10),
//         CustomButton(
//           top: MediaQuery
//               .of(context)
//               .size
//               .height * 0.8,
//           left: MediaQuery
//               .of(context)
//               .size
//               .width * 0.05,
//           width: MediaQuery
//               .of(context)
//               .size
//               .width * 0.9,
//           height: 55,
//           buttonText: 'CONTINUE',
//           icon: Icons.edit,
//           iconSize: 16,
//           // iconColor: Colors.white,
//           textStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           gradientColors: const [buttonColorGreen, buttonColorGreen],
//           // Custom gradient
//           onTap: () {
//             debugPrint("Navigating to Past Promo Page");
//             Get.offNamed('/viewProfile');
//           },
//           borderRadius: 15.0,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               offset: Offset(0, 5),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
