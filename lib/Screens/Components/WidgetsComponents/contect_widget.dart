import 'package:flutter/material.dart';

class ContentWidget extends StatelessWidget {
  final String headerText;
  final String descriptionText;
  final int highlightedIndex;

  const ContentWidget({
    Key? key,
    required this.headerText,
    required this.descriptionText,
    required this.highlightedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.06),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            return Container(
              width: screenWidth * 0.033,
              height: screenWidth * 0.033,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              decoration: BoxDecoration(
                color: index == highlightedIndex ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (index == highlightedIndex ? Colors.blue : Colors.grey)
                        .withOpacity(0.4),
                    offset: const Offset(2, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: screenHeight * 0.03),
        Text(
          headerText,
          style: TextStyle(
            color: Colors.black87,
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            descriptionText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: screenWidth * 0.045,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
