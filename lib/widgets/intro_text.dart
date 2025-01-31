import 'package:flutter/material.dart';

class IntroText extends StatelessWidget {
  const IntroText({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Text(
          'EcoConnect',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: width * 0.1,
            color: const Color(0xFF1B5E20),
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: height * 0.05),
        Text(
          'Vaš digitalni kompas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: width * 0.05,
            color: const Color(0xFF1B5E20),
          ),
        ),
        SizedBox(height: height * 0.1),
      ],
    );
  }
}
